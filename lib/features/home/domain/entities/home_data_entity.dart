import 'plant_alert_entity.dart';
import 'sensor_reading_entity.dart';
import 'treatment_task_entity.dart';

class HomeDataEntity {
  final List<SensorReadingEntity> sensorReadings;
  final List<PlantAlertEntity> alerts;
  final List<TreatmentTaskEntity> todayTasks;

  const HomeDataEntity({
    required this.sensorReadings,
    required this.alerts,
    required this.todayTasks,
  });
}
