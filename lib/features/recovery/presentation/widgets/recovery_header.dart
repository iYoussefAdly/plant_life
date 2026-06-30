import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/recovery_entity.dart';

class RecoveryHeader extends StatelessWidget {
  final RecoveryEntity recovery;

  const RecoveryHeader({super.key, required this.recovery});

  @override
  Widget build(BuildContext context) {
    final percentage = (recovery.progressPercent * 100).toStringAsFixed(0);
    final count = recovery.rescans.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 60,
            lineWidth: 10,
            percent: recovery.progressPercent.clamp(0.0, 1.0),
            animation: true,
            animationDuration: 1200,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$percentage%',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: _progressColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Recovery',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            progressColor: _progressColor,
            backgroundColor: AppColors.textHint.withValues(alpha: 0.15),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 16),
          if (recovery.title.isNotEmpty)
            Text(
              recovery.title,
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 4),
          Text(
            '$count follow-up scan${count != 1 ? 's' : ''}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color get _progressColor {
    if (recovery.progressPercent >= 0.8) return AppColors.success;
    if (recovery.progressPercent >= 0.4) return AppColors.primary;
    if (recovery.progressPercent > 0) return AppColors.warning;
    return AppColors.textHint;
  }
}
