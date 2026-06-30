import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.message,
    required super.timestamp,
    super.isRead,
    super.relatedId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      type: _mapType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestamp:
          DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
              DateTime.now(),
      isRead: json['read'] as bool? ?? false,
      // Backend does not currently return a related entity id — see the
      // "Open Points for Backend Discussion" in the integration plan. Kept
      // null-safe so the tile tap degrades gracefully (no navigation/crash).
      relatedId: (json['relatedId'] ?? json['healPlanId'])?.toString(),
    );
  }

  /// Maps the backend `type` string to the app's [NotificationType].
  /// Unknown/sensor types fall back to [NotificationType.treatmentTask] since
  /// sensor notifications are not expected while sensors stay on mock data.
  static NotificationType _mapType(String? type) {
    switch (type) {
      case 'sensor_warning':
      case 'sensor_alert':
        return NotificationType.sensorWarning;
      case 'task_reminder':
      case 'treatment_task':
      default:
        return NotificationType.treatmentTask;
    }
  }
}
