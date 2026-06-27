import 'package:flutter/material.dart';

import '../../../../core/extensions/sensor_type_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/sensor_card_decoration.dart';
import '../../domain/entities/sensor_reading_entity.dart';

class SensorSummaryCard extends StatelessWidget {
  final SensorReadingEntity reading;

  const SensorSummaryCard({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: SensorCardDecoration.forStatus(reading.status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SensorIcon(reading: reading),
              const Spacer(),
              _StatusBadge(status: reading.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${reading.value.toStringAsFixed(1)}${reading.unit}',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: reading.status == SensorStatus.normal
                  ? AppColors.textPrimary
                  : reading.status.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            reading.type.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SensorIcon extends StatelessWidget {
  final SensorReadingEntity reading;

  const _SensorIcon({required this.reading});

  @override
  Widget build(BuildContext context) {
    final badge = SensorCardDecoration.statusBadgeIcon(reading.status);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: reading.type.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(reading.type.icon, size: 20, color: reading.type.color),
        ),
        if (badge != null)
          Positioned(right: -5, top: -5, child: badge),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SensorStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.labelMedium.copyWith(
          color: status.color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
