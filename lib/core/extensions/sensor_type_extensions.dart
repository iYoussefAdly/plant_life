import 'package:flutter/material.dart';

import '../enums/sensor_enums.dart';
import '../theme/app_colors.dart';

export '../enums/sensor_enums.dart';

extension SensorTypeUI on SensorType {
  Color get color => switch (this) {
        SensorType.temperature => AppColors.temperature,
        SensorType.humidity => AppColors.humidity,
        SensorType.soilMoisture => AppColors.soilMoisture,
        SensorType.light => AppColors.light,
      };

  IconData get icon => switch (this) {
        SensorType.temperature => Icons.thermostat_outlined,
        SensorType.humidity => Icons.water_drop_outlined,
        SensorType.soilMoisture => Icons.grass_outlined,
        SensorType.light => Icons.light_mode_outlined,
      };

  String get label => switch (this) {
        SensorType.temperature => 'Temperature',
        SensorType.humidity => 'Humidity',
        SensorType.soilMoisture => 'Soil Moisture',
        SensorType.light => 'Light',
      };
}

extension SensorStatusUI on SensorStatus {
  Color get color => switch (this) {
        SensorStatus.normal => AppColors.success,
        SensorStatus.warning => AppColors.error,
        SensorStatus.critical => AppColors.error,
      };

  String get label => switch (this) {
        SensorStatus.normal => 'Normal',
        SensorStatus.warning => 'Warning',
        SensorStatus.critical => 'Critical',
      };
}
