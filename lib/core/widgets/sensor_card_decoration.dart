import 'package:flutter/material.dart';

import '../enums/sensor_enums.dart';
import '../theme/app_colors.dart';

abstract final class SensorCardDecoration {
  static BoxDecoration forStatus(SensorStatus status) => BoxDecoration(
        color: switch (status) {
          SensorStatus.normal => AppColors.surface,
          SensorStatus.warning => AppColors.error.withValues(alpha: 0.06),
          SensorStatus.critical => AppColors.error.withValues(alpha: 0.06),
        },
        borderRadius: BorderRadius.circular(16),
        border: switch (status) {
          SensorStatus.normal => null,
          SensorStatus.warning =>
            Border.all(color: AppColors.error.withValues(alpha: 0.4), width: 1.5),
          SensorStatus.critical =>
            Border.all(color: AppColors.error.withValues(alpha: 0.5), width: 2),
        },
        boxShadow: [
          BoxShadow(
            color: switch (status) {
              SensorStatus.normal => Colors.black.withValues(alpha: 0.05),
              SensorStatus.warning => AppColors.error.withValues(alpha: 0.1),
              SensorStatus.critical => AppColors.error.withValues(alpha: 0.1),
            },
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static Widget? statusBadgeIcon(SensorStatus status) => switch (status) {
        SensorStatus.normal => null,
        SensorStatus.warning => _buildBadge(Icons.warning_rounded, AppColors.warning),
        SensorStatus.critical => _buildBadge(Icons.error_rounded, AppColors.error),
      };

  static Widget _buildBadge(IconData icon, Color color) => Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.priority_high_rounded, size: 12, color: Colors.white),
      );
}
