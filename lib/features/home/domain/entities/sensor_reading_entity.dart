import '../../../../core/enums/sensor_enums.dart';

export '../../../../core/enums/sensor_enums.dart';

class SensorReadingEntity {
  final SensorType type;
  final double value;
  final String unit;
  final SensorStatus status;
  final DateTime timestamp;

  const SensorReadingEntity({
    required this.type,
    required this.value,
    required this.unit,
    required this.status,
    required this.timestamp,
  });
}
