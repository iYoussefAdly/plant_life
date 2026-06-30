import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/treatment_day_entity.dart';
import 'treatment_step_tile.dart';

class TreatmentDaySection extends StatelessWidget {
  final TreatmentDayEntity day;
  final void Function(String stepId, bool isCompleted) onToggleTask;

  /// Step id to emphasize (e.g. opened from Home's Today's Tasks).
  final String? highlightStepId;

  const TreatmentDaySection({
    super.key,
    required this.day,
    required this.onToggleTask,
    this.highlightStepId,
  });

  @override
  Widget build(BuildContext context) {
    final completed = day.isCompleted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: completed
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: completed
                  ? AppColors.success.withValues(alpha: 0.4)
                  : AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Icon(
                completed ? Icons.check_circle : Icons.calendar_today_outlined,
                size: 18,
                color: completed ? AppColors.success : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Day ${day.dayNumber}',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: completed ? AppColors.success : AppColors.textPrimary,
                ),
              ),
              if (day.date != null) ...[
                const SizedBox(width: 8),
                if (!completed && !day.isUnlocked) ...[
                  const Icon(Icons.lock_outline,
                      size: 13, color: AppColors.textHint),
                  const SizedBox(width: 3),
                ],
                Text(
                  formatShortDate(day.date!),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const Spacer(),
              if (completed)
                Text(
                  'Completed',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                Text(
                  '${day.completedCount}/${day.tasks.length}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...day.tasks.map((task) => TreatmentStepTile(
              key: ValueKey(task.id),
              step: task,
              highlight: task.id == highlightStepId,
              onToggle: (isCompleted) => onToggleTask(task.id, isCompleted),
            )),
      ],
    );
  }
}
