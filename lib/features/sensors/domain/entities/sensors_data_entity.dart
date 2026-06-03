import 'sensor_alert_entity.dart';
import 'sensor_detail_entity.dart';

class SensorsDataEntity {
  final List<SensorDetailEntity> sensors;
  final List<SensorAlertEntity> alertHistory;

  const SensorsDataEntity({
    required this.sensors,
    required this.alertHistory,
  });
}
