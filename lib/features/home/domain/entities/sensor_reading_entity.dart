enum SensorType { temperature, humidity, soilMoisture, light }

enum SensorStatus { normal, warning, critical }

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
