import 'plant_alert_entity.dart';
import 'sensor_reading_entity.dart';
import 'treatment_task_entity.dart';

class HomeDataEntity {
  final List<SensorReadingEntity> sensorReadings;
  final List<PlantAlertEntity> alerts;
  final List<TreatmentTaskEntity> todayTasks;

  /// Whether a sensor Device ID is configured. When false, the dashboard hides
  /// the sensor overview + alerts and shows a "connect your sensor" prompt.
  final bool sensorsConfigured;

  const HomeDataEntity({
    required this.sensorReadings,
    required this.alerts,
    required this.todayTasks,
    required this.sensorsConfigured,
  });
}
