import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../treatments/domain/entities/treatment_plan_entity.dart';
import '../../../treatments/domain/repos/treatments_repository.dart';
import '../../domain/entities/home_data_entity.dart';
import '../../domain/entities/plant_alert_entity.dart';
import '../../domain/entities/sensor_reading_entity.dart';
import '../../domain/entities/treatment_task_entity.dart';
import '../../domain/repos/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final TreatmentsRepository _treatmentsRepository;

  HomeRepositoryImpl(this._treatmentsRepository);

  @override
  Future<ApiResult<HomeDataEntity>> getHomeData() async {
    // Today's Tasks are composed from the active heal plan(s). Sensor readings
    // and alerts remain mock until sensor endpoints are available. A treatments
    // failure degrades to an empty task list (see _loadTodayTasks); the
    // try/catch guards against any unexpected error so it still surfaces.
    try {
      final todayTasks = await _loadTodayTasks();
      return Success(
        HomeDataEntity(
          sensorReadings: _mockSensorReadings(),
          alerts: _mockAlerts(),
          todayTasks: todayTasks,
        ),
      );
    } catch (e) {
      return const Error(ServerFailure('Failed to load dashboard data'));
    }
  }

  /// Pulls the current day's tasks from every active heal plan. A treatments
  /// failure degrades to an empty task list rather than blanking the dashboard.
  Future<List<TreatmentTaskEntity>> _loadTodayTasks() async {
    final result = await _treatmentsRepository.getTreatmentPlans();
    final plans = switch (result) {
      Success(:final data) => data,
      Error() => const <TreatmentPlanEntity>[],
    };

    final now = DateTime.now();
    final tasks = <TreatmentTaskEntity>[];
    for (final plan
        in plans.where((p) => p.status == TreatmentPlanStatus.active)) {
      for (final step in plan.steps) {
        if (_isSameDay(step.scheduledAt, now)) {
          tasks.add(
            TreatmentTaskEntity(
              // Prefix with the plan id — step ids are per-plan indices and
              // would otherwise collide across multiple active plans.
              id: '${plan.id}_${step.id}',
              title: step.title,
              description: step.description,
              isCompleted: step.isCompleted,
              scheduledAt: step.scheduledAt,
            ),
          );
        }
      }
    }
    tasks.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return tasks;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<SensorReadingEntity> _mockSensorReadings() {
    final now = DateTime.now();
    return [
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
  }

  List<PlantAlertEntity> _mockAlerts() {
    final now = DateTime.now();
    return [
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
  }
}
