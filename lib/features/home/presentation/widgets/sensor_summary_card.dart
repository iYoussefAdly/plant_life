import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/sensor_reading_entity.dart';

class SensorSummaryCard extends StatelessWidget {
  final SensorReadingEntity reading;

  const SensorSummaryCard({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _sensorColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_sensorIcon, size: 20, color: _sensorColor),
              ),
              const Spacer(),
              _StatusBadge(status: reading.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${reading.value.toStringAsFixed(1)}${reading.unit}',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _sensorLabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color get _sensorColor => switch (reading.type) {
        SensorType.temperature => AppColors.temperature,
        SensorType.humidity => AppColors.humidity,
        SensorType.soilMoisture => AppColors.soilMoisture,
        SensorType.light => AppColors.light,
      };

  IconData get _sensorIcon => switch (reading.type) {
        SensorType.temperature => Icons.thermostat_outlined,
        SensorType.humidity => Icons.water_drop_outlined,
        SensorType.soilMoisture => Icons.grass_outlined,
        SensorType.light => Icons.light_mode_outlined,
      };

  String get _sensorLabel => switch (reading.type) {
        SensorType.temperature => 'Temperature',
        SensorType.humidity => 'Humidity',
        SensorType.soilMoisture => 'Soil Moisture',
        SensorType.light => 'Light',
      };
}

class _StatusBadge extends StatelessWidget {
  final SensorStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _statusLabel,
        style: AppTextStyles.labelMedium.copyWith(
          color: _statusColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _statusColor => switch (status) {
        SensorStatus.normal => AppColors.success,
        SensorStatus.warning => AppColors.warning,
        SensorStatus.critical => AppColors.error,
      };

  String get _statusLabel => switch (status) {
        SensorStatus.normal => 'Normal',
        SensorStatus.warning => 'Warning',
        SensorStatus.critical => 'Critical',
      };
}
