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
    final abnormal = reading.status != SensorStatus.normal;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: SensorCardDecoration.forStatus(reading.status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: reading.type.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(reading.type.icon, size: 19, color: reading.type.color),
              ),
              const Spacer(),
              SensorCardDecoration.statusPill(context, reading.status),
            ],
          ),
          const Spacer(),
          RichText(
            maxLines: 1,
            text: TextSpan(
              text: reading.value.toStringAsFixed(1),
              style: AppTextStyles.headlineMedium.copyWith(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color:
                    abnormal ? reading.status.color : AppColors.textPrimary,
              ),
              children: [
                TextSpan(
                  text: ' ${reading.unit}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            reading.type.label(context),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
