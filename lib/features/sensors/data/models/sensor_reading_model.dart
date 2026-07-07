import '../../../../core/enums/sensor_enums.dart';

/// Maps a backend sensor-type string to the app [SensorType]. Returns null for
/// unknown types so callers can skip them.
SensorType? sensorTypeFromApi(String? raw) {
  switch (raw) {
    case 'temperature':
      return SensorType.temperature;
    case 'humidity':
      return SensorType.humidity;
    case 'soilMoisture':
      return SensorType.soilMoisture;
    case 'lightIntensity':
    case 'light':
      return SensorType.light;
  }
  return null;
}

/// Maps a backend status string to [SensorStatus] (`danger` → `critical`).
SensorStatus sensorStatusFromApi(String? raw) {
  switch (raw) {
    case 'danger':
      return SensorStatus.critical;
    case 'warning':
      return SensorStatus.warning;
    default:
      return SensorStatus.normal;
  }
}

/// A single sensor reading (a snapshot of all four sensors + per-sensor
/// evaluation), parsed from `GET /sensors/history/:deviceId`.
class SensorReadingModel {
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final double lightIntensity;
  final Map<SensorType, SensorStatus> statuses;
  final SensorStatus overallStatus;
  final DateTime timestamp;

  const SensorReadingModel({
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.lightIntensity,
    required this.statuses,
    required this.overallStatus,
    required this.timestamp,
  });

  double valueFor(SensorType type) => switch (type) {
        SensorType.temperature => temperature,
        SensorType.humidity => humidity,
        SensorType.soilMoisture => soilMoisture,
        SensorType.light => lightIntensity,
      };

  static double _num(dynamic v) => (v as num?)?.toDouble() ?? 0;

  factory SensorReadingModel.fromJson(Map<String, dynamic> json) {
    final statuses = <SensorType, SensorStatus>{};
    final evals = json['evaluations'];
    if (evals is Map) {
      evals.forEach((key, value) {
        final type = sensorTypeFromApi(key as String?);
        if (type != null && value is Map) {
          statuses[type] = sensorStatusFromApi(value['status'] as String?);
        }
      });
    }
    return SensorReadingModel(
      temperature: _num(json['temperature']),
      humidity: _num(json['humidity']),
      soilMoisture: _num(json['soilMoisture']),
      lightIntensity: _num(json['lightIntensity']),
      statuses: statuses,
      overallStatus: sensorStatusFromApi(json['overallStatus'] as String?),
      timestamp: DateTime.tryParse(
                (json['timestamp'] ?? json['createdAt']) as String? ?? '',
              )?.toLocal() ??
          DateTime.now(),
    );
  }
}
