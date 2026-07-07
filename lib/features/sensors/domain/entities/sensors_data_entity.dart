import 'sensor_detail_entity.dart';
import 'sensor_notification_entity.dart';

class SensorsDataEntity {
  /// Current per-sensor snapshot, derived from the latest recorded reading.
  /// Empty when the device has no recorded (warning/danger) readings yet.
  final List<SensorDetailEntity> sensors;

  /// Alert history — the backend's sensor notifications, newest first.
  final List<SensorNotificationEntity> notifications;

  /// Count of unread sensor notifications (for the badge).
  final int unreadCount;

  /// Timestamp of the latest reading, or null when none exist.
  final DateTime? lastReadingAt;

  const SensorsDataEntity({
    required this.sensors,
    required this.notifications,
    required this.unreadCount,
    this.lastReadingAt,
  });

  SensorsDataEntity copyWith({
    List<SensorNotificationEntity>? notifications,
    int? unreadCount,
  }) =>
      SensorsDataEntity(
        sensors: sensors,
        notifications: notifications ?? this.notifications,
        unreadCount: unreadCount ?? this.unreadCount,
        lastReadingAt: lastReadingAt,
      );
}
