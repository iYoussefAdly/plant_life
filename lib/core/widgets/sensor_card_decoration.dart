import 'package:flutter/material.dart';

import '../extensions/sensor_type_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

export '../enums/sensor_enums.dart';

abstract final class SensorCardDecoration {
  /// Card decoration tinted by the sensor status — plain surface when normal,
  /// amber wash for warning, red wash for critical.
  static BoxDecoration forStatus(SensorStatus status) {
    final statusColor = status.color;
    return BoxDecoration(
      color: status == SensorStatus.normal
          ? AppColors.surface
          : Color.alphaBlend(
              statusColor.withValues(alpha: 0.05), AppColors.surface),
      borderRadius: BorderRadius.circular(16),
      border: switch (status) {
        SensorStatus.normal => null,
        SensorStatus.warning =>
          Border.all(color: statusColor.withValues(alpha: 0.45), width: 1.4),
        SensorStatus.critical =>
          Border.all(color: statusColor.withValues(alpha: 0.55), width: 1.8),
      },
      boxShadow: [
        BoxShadow(
          color: status == SensorStatus.normal
              ? Colors.black.withValues(alpha: 0.05)
              : statusColor.withValues(alpha: 0.12),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Compact status chip: colored dot + label (e.g. `• Warning`).
  static Widget statusPill(BuildContext context, SensorStatus status) {
    final color = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 4),
          Text(
            status.label(context),
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
