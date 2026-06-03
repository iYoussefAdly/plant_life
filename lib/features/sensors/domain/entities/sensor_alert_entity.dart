import '../../../../core/enums/sensor_enums.dart';

class SensorAlertEntity {
  final String id;
  final SensorType sensorType;
  final String message;
  final double value;
  final String unit;
  final DateTime timestamp;
  final bool isResolved;

  const SensorAlertEntity({
    required this.id,
    required this.sensorType,
    required this.message,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.isResolved,
  });
}
