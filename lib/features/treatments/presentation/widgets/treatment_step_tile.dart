import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/treatment_step_entity.dart';

class TreatmentStepTile extends StatelessWidget {
  final TreatmentStepEntity step;
  final ValueChanged<bool> onToggle;

  /// Opens the full task-detail view (bottom sheet) for this task.
  final VoidCallback onOpenDetails;

  /// When true, the tile is emphasized (e.g. when opened from a Home
  /// "Today's Tasks" tap).
  final bool highlight;

  const TreatmentStepTile({
    super.key,
    required this.step,
    required this.onToggle,
    required this.onOpenDetails,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !step.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.06)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? AppColors.primary
              : step.isCompleted
                  ? AppColors.success.withValues(alpha: 0.3)
                  : AppColors.textHint.withValues(alpha: 0.2),
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpenDetails,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildCheckbox(step, locked),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: step.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: step.isCompleted || locked
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.chevron_right,
                        size: 22,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (locked)
                  Padding(
                    padding: const EdgeInsets.only(left: 40, top: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          'Unlocks ${formatShortDate(step.scheduledAt)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(TreatmentStepEntity step, bool locked) {
    if (locked) {
      // Future task — visible but not actionable yet.
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.textHint.withValues(alpha: 0.12),
          border: Border.all(color: AppColors.textHint.withValues(alpha: 0.4)),
        ),
        child:
            const Icon(Icons.lock_outline, size: 14, color: AppColors.textHint),
      );
    }

    return GestureDetector(
      onTap: () => onToggle(!step.isCompleted),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: step.isCompleted ? AppColors.success : Colors.transparent,
          border: Border.all(
            color: step.isCompleted ? AppColors.success : AppColors.textHint,
            width: 2,
          ),
        ),
        child: step.isCompleted
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}
