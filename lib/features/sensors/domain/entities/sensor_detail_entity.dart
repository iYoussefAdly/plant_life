import '../../../../core/enums/sensor_enums.dart';

class DataPoint {
  final DateTime timestamp;
  final double value;

  const DataPoint({required this.timestamp, required this.value});
}

class SensorDetailEntity {
  final SensorType type;
  final double currentValue;
  final String unit;
  final SensorStatus status;
  final double minRange;
  final double maxRange;
  final List<DataPoint> history;
  final DateTime lastUpdated;

  const SensorDetailEntity({
    required this.type,
    required this.currentValue,
    required this.unit,
    required this.status,
    required this.minRange,
    required this.maxRange,
    required this.history,
    required this.lastUpdated,
  });
}
