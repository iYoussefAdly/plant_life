import '../../../../core/enums/sensor_enums.dart';
import '../../domain/entities/sensor_notification_entity.dart';
import 'sensor_reading_model.dart';

class SensorNotificationModel extends SensorNotificationEntity {
  const SensorNotificationModel({
    required super.id,
    required super.sensorType,
    required super.status,
    required super.title,
    required super.message,
    required super.recommendation,
    required super.currentValue,
    required super.isRead,
    required super.timestamp,
  });

  factory SensorNotificationModel.fromJson(Map<String, dynamic> json) {
    final rec = (json['recommendation'] as List?)
            ?.whereType<String>()
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList() ??
        const <String>[];
    return SensorNotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      sensorType: sensorTypeFromApi(json['sensorType'] as String?) ??
          SensorType.temperature,
      status: sensorStatusFromApi(json['status'] as String?),
      title: (json['title'] as String? ?? '').trim(),
      message: (json['message'] as String? ?? '').trim(),
      recommendation: rec,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0,
      isRead: json['isRead'] as bool? ?? false,
      timestamp: DateTime.tryParse(
                (json['timestamp'] ?? json['createdAt']) as String? ?? '',
              )?.toLocal() ??
          DateTime.now(),
    );
  }
}
