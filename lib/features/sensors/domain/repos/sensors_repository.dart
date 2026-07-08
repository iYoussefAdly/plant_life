import '../../../../core/errors/api_result.dart';
import '../entities/sensor_notification_feed.dart';
import '../entities/sensors_data_entity.dart';

abstract class SensorsRepository {
  /// Loads the current snapshot + alert history + unread count for [deviceId].
  Future<ApiResult<SensorsDataEntity>> getSensorsData(String deviceId);

  /// Registers [deviceId] to the account (`PATCH /auth/device`). Must succeed
  /// before the device is persisted locally or its data is loaded — this is
  /// the "Connect Device" step.
  Future<ApiResult<void>> registerDevice(String deviceId);

  /// Lean fetch of sensor notifications + unread count only (no reading
  /// history) — used to merge sensor alerts into the global notifications
  /// center.
  Future<ApiResult<SensorNotificationFeed>> getNotificationFeed(
    String deviceId,
  );

  Future<ApiResult<void>> markNotificationRead(String notificationId);

  Future<ApiResult<void>> markAllNotificationsRead();

  /// Registers/updates the device's FCM push token for the current account.
  Future<ApiResult<void>> registerFcmToken(String token);
}
