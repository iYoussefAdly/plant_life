import '../../../../core/errors/api_result.dart';
import '../entities/sensor_notification_feed.dart';
import '../repos/sensors_repository.dart';

/// Returns the current device's sensor notifications + unread count for the
/// global notifications center. Degrades to an empty feed when no device is
/// configured or the sensor backend is unavailable, so the center still shows
/// treatment notifications.
class GetSensorNotificationFeedUseCase {
  final SensorsRepository _repository;

  GetSensorNotificationFeedUseCase(this._repository);

  Future<SensorNotificationFeed> call(String? deviceId) async {
    if (deviceId == null) return SensorNotificationFeed.empty;
    final result = await _repository.getNotificationFeed(deviceId);
    return switch (result) {
      Success(:final data) => data,
      Error() => SensorNotificationFeed.empty,
    };
  }
}
