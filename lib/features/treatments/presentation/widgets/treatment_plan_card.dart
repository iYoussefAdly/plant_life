import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'treatment_progress_color.dart';
import '../../domain/entities/treatment_plan_entity.dart';

class TreatmentPlanCard extends StatelessWidget {
  final TreatmentPlanEntity plan;
  final VoidCallback onTap;

  const TreatmentPlanCard({
    super.key,
    required this.plan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = plan.steps.where((s) => s.isCompleted).length;
    final percentage = (plan.progress * 100).toStringAsFixed(0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 30,
              lineWidth: 5,
              percent: plan.progress,
              center: Text(
                '$percentage%',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _progressColor,
                ),
              ),
              progressColor: _progressColor,
              backgroundColor: AppColors.textHint.withValues(alpha: 0.2),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.plantName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedCount of ${plan.steps.length} steps completed',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Color get _progressColor => treatmentProgressColor(plan.progress);
}
