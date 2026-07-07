import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../sensors/domain/entities/sensor_notification_entity.dart';
import '../../../sensors/domain/entities/sensors_data_entity.dart';
import '../../../sensors/domain/repos/sensors_repository.dart';
import '../../../treatments/domain/entities/treatment_plan_entity.dart';
import '../../../treatments/domain/repos/treatments_repository.dart';
import '../../domain/entities/home_data_entity.dart';
import '../../domain/entities/plant_alert_entity.dart';
import '../../domain/entities/sensor_reading_entity.dart';
import '../../domain/entities/treatment_task_entity.dart';
import '../../domain/repos/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  /// Home's Alerts section shows only the most recent sensor events; the full
  /// history lives on the Sensors screen (via "See All").
  static const _maxHomeAlerts = 5;

  final TreatmentsRepository _treatmentsRepository;
  final SensorsRepository _sensorsRepository;
  final AppPreferences _prefs;

  HomeRepositoryImpl(
    this._treatmentsRepository,
    this._sensorsRepository,
    this._prefs,
  );

  @override
  Future<ApiResult<HomeDataEntity>> getHomeData() async {
    // Today's Tasks are composed from the active heal plan(s). The sensor
    // overview + alerts come from the sensor backend and are gated behind a
    // configured Device ID; a sensors failure degrades to empty sensor
    // sections rather than blanking the whole dashboard (treatments are still
    // valuable on their own), mirroring how a treatments failure degrades to
    // an empty task list (see _loadTodayTasks).
    try {
      final todayTasks = await _loadTodayTasks();
      final deviceId = _prefs.sensorDeviceId;
      if (deviceId == null) {
        return Success(
          HomeDataEntity(
            sensorReadings: const [],
            alerts: const [],
            todayTasks: todayTasks,
            sensorsConfigured: false,
          ),
        );
      }

      final sensorsResult = await _sensorsRepository.getSensorsData(deviceId);
      final sensorsData = switch (sensorsResult) {
        Success(:final data) => data,
        Error() => null,
      };

      return Success(
        HomeDataEntity(
          sensorReadings: _mapReadings(sensorsData),
          alerts: _mapAlerts(sensorsData),
          todayTasks: todayTasks,
          sensorsConfigured: true,
        ),
      );
    } catch (e) {
      return const Error(ServerFailure('Failed to load dashboard data'));
    }
  }

  /// Overview cards from the latest recorded reading (empty when the device
  /// has no recorded readings yet or the sensor backend was unavailable).
  List<SensorReadingEntity> _mapReadings(SensorsDataEntity? data) {
    if (data == null) return const [];
    return data.sensors
        .map((s) => SensorReadingEntity(
              type: s.type,
              value: s.currentValue,
              unit: s.unit,
              status: s.status,
              timestamp: s.lastUpdated,
            ))
        .toList();
  }

  /// The latest [_maxHomeAlerts] sensor events, newest first.
  List<PlantAlertEntity> _mapAlerts(SensorsDataEntity? data) {
    if (data == null) return const [];
    final sorted = [...data.notifications]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(_maxHomeAlerts).map(_toAlert).toList();
  }

  PlantAlertEntity _toAlert(SensorNotificationEntity n) => PlantAlertEntity(
        id: n.id,
        message: n.message.isNotEmpty ? n.message : n.title,
        severity: switch (n.status) {
          SensorStatus.critical => AlertSeverity.critical,
          SensorStatus.warning => AlertSeverity.warning,
          SensorStatus.normal => AlertSeverity.info,
        },
        timestamp: n.timestamp,
      );

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
              planId: plan.id,
              stepId: step.id,
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
}
