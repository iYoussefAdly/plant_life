import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/sensor_enums.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../domain/entities/sensor_detail_entity.dart';
import '../../domain/entities/sensor_notification_feed.dart';
import '../../domain/entities/sensors_data_entity.dart';
import '../../domain/repos/sensors_repository.dart';
import '../datasources/sensors_data_source.dart';
import '../models/sensor_reading_model.dart';

class SensorsRepositoryImpl implements SensorsRepository {
  final SensorsDataSource _dataSource;

  SensorsRepositoryImpl(this._dataSource);

  @override
  Future<ApiResult<SensorsDataEntity>> getSensorsData(String deviceId) async {
    try {
      // Notifications are the core content (and surface auth errors). Unread
      // count and reading history degrade gracefully so a single non-critical
      // failure doesn't blank the screen.
      final notifications = await _dataSource.getNotifications(
        deviceId: deviceId,
      );
      final unread =
          await _dataSource.getUnreadCount().catchError((_) => 0);
      final readings = await _dataSource
          .getHistory(deviceId)
          .catchError((_) => <SensorReadingModel>[]);

      return Success(
        SensorsDataEntity(
          sensors: _buildSensors(readings),
          notifications: notifications,
          unreadCount: unread,
          lastReadingAt: readings.isNotEmpty ? _latest(readings).timestamp : null,
        ),
      );
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> registerDevice(String deviceId) async {
    try {
      await _dataSource.registerDevice(deviceId);
      return const Success(null);
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SensorNotificationFeed>> getNotificationFeed(
    String deviceId,
  ) async {
    try {
      final notifications = await _dataSource.getNotifications(
        deviceId: deviceId,
      );
      final unread = await _dataSource.getUnreadCount().catchError((_) => 0);
      return Success(
        SensorNotificationFeed(
          notifications: notifications,
          unreadCount: unread,
        ),
      );
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> markNotificationRead(String notificationId) async {
    try {
      await _dataSource.markAsRead(notificationId);
      return const Success(null);
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> markAllNotificationsRead() async {
    try {
      await _dataSource.markAllAsRead();
      return const Success(null);
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> registerFcmToken(String token) async {
    try {
      await _dataSource.updateFcmToken(token);
      return const Success(null);
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  SensorReadingModel _latest(List<SensorReadingModel> readings) {
    final sorted = [...readings]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.first;
  }

  /// Builds the four current-reading cards from recorded readings. Uses the
  /// newest reading for current values/status and the full set (oldest→newest)
  /// for each card's trend chart. Returns empty when there are no readings.
  List<SensorDetailEntity> _buildSensors(List<SensorReadingModel> readings) {
    if (readings.isEmpty) return const [];
    final ordered = [...readings]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final latest = ordered.last;

    SensorDetailEntity build(
      SensorType type,
      String unit,
      double min,
      double max,
    ) {
      return SensorDetailEntity(
        type: type,
        currentValue: latest.valueFor(type),
        unit: unit,
        status: latest.statuses[type] ?? SensorStatus.normal,
        minRange: min,
        maxRange: max,
        history: ordered
            .map((r) => DataPoint(timestamp: r.timestamp, value: r.valueFor(type)))
            .toList(),
        lastUpdated: latest.timestamp,
      );
    }

    return [
      build(SensorType.temperature, '°C', AppConstants.tempMin, AppConstants.tempMax),
      build(SensorType.humidity, '%', AppConstants.humidityMin, AppConstants.humidityMax),
      build(SensorType.soilMoisture, '%', AppConstants.soilMoistureMin, AppConstants.soilMoistureMax),
      build(SensorType.light, 'lux', AppConstants.lightMin, AppConstants.lightMax),
    ];
  }
}
