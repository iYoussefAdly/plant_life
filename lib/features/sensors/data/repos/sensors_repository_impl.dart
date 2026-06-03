import 'dart:math';

import '../../../../core/enums/sensor_enums.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/sensor_alert_entity.dart';
import '../../domain/entities/sensor_detail_entity.dart';
import '../../domain/entities/sensors_data_entity.dart';
import '../../domain/repos/sensors_repository.dart';

class SensorsRepositoryImpl implements SensorsRepository {
  @override
  Future<ApiResult<SensorsDataEntity>> getSensorsData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final now = DateTime.now();
      final random = Random(42);

      final sensors = [
        _buildSensorDetail(
          type: SensorType.temperature,
          current: 24.5,
          unit: '°C',
          status: SensorStatus.normal,
          min: 18,
          max: 30,
          baseValue: 23,
          variance: 4,
          now: now,
          random: random,
        ),
        _buildSensorDetail(
          type: SensorType.humidity,
          current: 35.0,
          unit: '%',
          status: SensorStatus.warning,
          min: 40,
          max: 70,
          baseValue: 45,
          variance: 15,
          now: now,
          random: random,
        ),
        _buildSensorDetail(
          type: SensorType.soilMoisture,
          current: 55.0,
          unit: '%',
          status: SensorStatus.normal,
          min: 30,
          max: 80,
          baseValue: 55,
          variance: 10,
          now: now,
          random: random,
        ),
        _buildSensorDetail(
          type: SensorType.light,
          current: 150.0,
          unit: 'lux',
          status: SensorStatus.critical,
          min: 200,
          max: 800,
          baseValue: 400,
          variance: 200,
          now: now,
          random: random,
        ),
      ];

      final alertHistory = [
        SensorAlertEntity(
          id: '1',
          sensorType: SensorType.light,
          message: 'Light level dropped below 200 lux',
          value: 150,
          unit: 'lux',
          timestamp: now.subtract(const Duration(minutes: 5)),
          isResolved: false,
        ),
        SensorAlertEntity(
          id: '2',
          sensorType: SensorType.humidity,
          message: 'Humidity below optimal range',
          value: 35,
          unit: '%',
          timestamp: now.subtract(const Duration(minutes: 30)),
          isResolved: false,
        ),
        SensorAlertEntity(
          id: '3',
          sensorType: SensorType.temperature,
          message: 'Temperature spike detected',
          value: 32.5,
          unit: '°C',
          timestamp: now.subtract(const Duration(hours: 2)),
          isResolved: true,
        ),
        SensorAlertEntity(
          id: '4',
          sensorType: SensorType.soilMoisture,
          message: 'Soil moisture dropped to 25%',
          value: 25,
          unit: '%',
          timestamp: now.subtract(const Duration(hours: 5)),
          isResolved: true,
        ),
        SensorAlertEntity(
          id: '5',
          sensorType: SensorType.temperature,
          message: 'Temperature returned to normal',
          value: 24,
          unit: '°C',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
          isResolved: true,
        ),
      ];

      return Success(SensorsDataEntity(
        sensors: sensors,
        alertHistory: alertHistory,
      ));
    } catch (e) {
      return const Error(ServerFailure('Failed to load sensor data'));
    }
  }

  SensorDetailEntity _buildSensorDetail({
    required SensorType type,
    required double current,
    required String unit,
    required SensorStatus status,
    required double min,
    required double max,
    required double baseValue,
    required double variance,
    required DateTime now,
    required Random random,
  }) {
    final history = List.generate(24, (i) {
      final time = now.subtract(Duration(hours: 23 - i));
      final value = baseValue + (random.nextDouble() * variance) - (variance / 2);
      return DataPoint(timestamp: time, value: double.parse(value.toStringAsFixed(1)));
    });

    return SensorDetailEntity(
      type: type,
      currentValue: current,
      unit: unit,
      status: status,
      minRange: min,
      maxRange: max,
      history: history,
      lastUpdated: now,
    );
  }
}
