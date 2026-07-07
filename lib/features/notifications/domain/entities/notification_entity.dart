enum NotificationType { treatmentTask, sensorWarning }

class NotificationEntity {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedId;

  /// True for reminders derived on the device from active treatment tasks
  /// (not persisted on the backend). Read-state for these is tracked locally,
  /// so `markAsRead`/`markAllAsRead` must not call the server for them.
  final bool isLocal;

  /// True for alerts sourced from the sensor backend (merged into this global
  /// center). Routing marker: their read-state is marked on the sensor backend,
  /// not the main notifications backend.
  final bool isSensor;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.relatedId,
    this.isLocal = false,
    this.isSensor = false,
  });

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
        id: id,
        type: type,
        title: title,
        message: message,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
        relatedId: relatedId,
        isLocal: isLocal,
        isSensor: isSensor,
      );
}
