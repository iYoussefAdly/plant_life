enum NotificationType { treatmentTask, sensorWarning }

class NotificationEntity {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedId;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.relatedId,
  });

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
        id: id,
        type: type,
        title: title,
        message: message,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
        relatedId: relatedId,
      );
}
