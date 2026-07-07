import 'sensor_notification_entity.dart';

/// A lean view of the sensor backend's notifications: the list plus the
/// authoritative unread count. Used to merge sensor alerts into the global
/// notifications center without also fetching reading history.
class SensorNotificationFeed {
  final List<SensorNotificationEntity> notifications;
  final int unreadCount;

  const SensorNotificationFeed({
    required this.notifications,
    required this.unreadCount,
  });

  static const empty =
      SensorNotificationFeed(notifications: [], unreadCount: 0);
}
