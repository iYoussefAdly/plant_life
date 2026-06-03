import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/home_data_entity.dart';
import '../../domain/entities/plant_alert_entity.dart';
import '../../domain/entities/sensor_reading_entity.dart';
import '../../domain/entities/treatment_task_entity.dart';
import '../../domain/repos/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<ApiResult<HomeDataEntity>> getHomeData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final now = DateTime.now();

      final sensorReadings = [
        SensorReadingEntity(
          type: SensorType.temperature,
          value: 24.5,
          unit: '°C',
          status: SensorStatus.normal,
          timestamp: now,
        ),
        SensorReadingEntity(
          type: SensorType.humidity,
          value: 35.0,
          unit: '%',
          status: SensorStatus.warning,
          timestamp: now,
        ),
        SensorReadingEntity(
          type: SensorType.soilMoisture,
          value: 55.0,
          unit: '%',
          status: SensorStatus.normal,
          timestamp: now,
        ),
        SensorReadingEntity(
          type: SensorType.light,
          value: 150.0,
          unit: 'lux',
          status: SensorStatus.critical,
          timestamp: now,
        ),
      ];

      final alerts = [
        PlantAlertEntity(
          id: '1',
          message: 'Humidity is below optimal range',
          severity: AlertSeverity.warning,
          timestamp: now.subtract(const Duration(minutes: 15)),
        ),
        PlantAlertEntity(
          id: '2',
          message: 'Light level critically low',
          severity: AlertSeverity.critical,
          timestamp: now.subtract(const Duration(minutes: 5)),
        ),
        PlantAlertEntity(
          id: '3',
          message: 'Soil moisture is within ideal range',
          severity: AlertSeverity.info,
          timestamp: now.subtract(const Duration(hours: 1)),
        ),
      ];

      final todayTasks = [
        TreatmentTaskEntity(
          id: '1',
          title: 'Water the plant',
          description: 'Apply 200ml of water to the base',
          isCompleted: true,
          scheduledAt: now.subtract(const Duration(hours: 3)),
        ),
        TreatmentTaskEntity(
          id: '2',
          title: 'Apply fungicide spray',
          description: 'Spray leaves with neem oil solution',
          isCompleted: false,
          scheduledAt: now.add(const Duration(hours: 2)),
        ),
        TreatmentTaskEntity(
          id: '3',
          title: 'Check drainage',
          description: 'Ensure pot drainage holes are clear',
          isCompleted: false,
          scheduledAt: now.add(const Duration(hours: 4)),
        ),
      ];

      return Success(HomeDataEntity(
        sensorReadings: sensorReadings,
        alerts: alerts,
        todayTasks: todayTasks,
      ));
    } catch (e) {
      return const Error(ServerFailure('Failed to load dashboard data'));
    }
  }
}
