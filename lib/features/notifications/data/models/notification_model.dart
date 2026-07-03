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
      title: _sanitize(json['title'] as String? ?? ''),
      message: _sanitize(json['message'] as String? ?? ''),
      timestamp:
          DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
              DateTime.now(),
      isRead: json['read'] as bool? ?? false,
      // The backend returns the related heal-plan id under `healPlan`
      // (verified against the live API) — used to open the plan on tap.
      relatedId:
          (json['relatedId'] ?? json['healPlanId'] ?? json['healPlan'])
              ?.toString(),
    );
  }

  /// Strips un-interpolated template placeholders (e.g. `${healPlan.disease}`)
  /// that the backend occasionally leaves in the text — raw code must never
  /// reach the UI. Placeholders are replaced with an ellipsis; the real values
  /// require a backend fix (template literals need backticks in Node).
  static final _placeholderRe = RegExp(r'\$\{[^}]*\}');
  static final _whitespaceRe = RegExp(r'\s+');

  static String _sanitize(String text) => text
      .replaceAll(_placeholderRe, '…')
      .replaceAll(_whitespaceRe, ' ')
      .trim();

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
