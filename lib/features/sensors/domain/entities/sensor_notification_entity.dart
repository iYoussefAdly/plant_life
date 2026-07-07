import '../../../../core/enums/sensor_enums.dart';

/// A per-sensor warning/danger alert from the backend. Titles, messages, and
/// recommendations are produced (and localized) server-side.
class SensorNotificationEntity {
  final String id;
  final SensorType sensorType;
  final SensorStatus status;
  final String title;
  final String message;
  final List<String> recommendation;
  final double currentValue;
  final bool isRead;
  final DateTime timestamp;

  const SensorNotificationEntity({
    required this.id,
    required this.sensorType,
    required this.status,
    required this.title,
    required this.message,
    required this.recommendation,
    required this.currentValue,
    required this.isRead,
    required this.timestamp,
  });

  SensorNotificationEntity copyWith({bool? isRead}) => SensorNotificationEntity(
        id: id,
        sensorType: sensorType,
        status: status,
        title: title,
        message: message,
        recommendation: recommendation,
        currentValue: currentValue,
        isRead: isRead ?? this.isRead,
        timestamp: timestamp,
      );
}
