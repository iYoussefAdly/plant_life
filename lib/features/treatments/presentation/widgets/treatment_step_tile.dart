import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/treatment_step_entity.dart';

class TreatmentStepTile extends StatefulWidget {
  final TreatmentStepEntity step;
  final ValueChanged<bool> onToggle;

  const TreatmentStepTile({
    super.key,
    required this.step,
    required this.onToggle,
  });

  @override
  State<TreatmentStepTile> createState() => _TreatmentStepTileState();
}

class _TreatmentStepTileState extends State<TreatmentStepTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final step = widget.step;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: step.isCompleted
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.textHint.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => widget.onToggle(!step.isCompleted),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.isCompleted
                        ? AppColors.success
                        : Colors.transparent,
                    border: Border.all(
                      color: step.isCompleted
                          ? AppColors.success
                          : AppColors.textHint,
                      width: 2,
                    ),
                  ),
                  child: step.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration:
                        step.isCompleted ? TextDecoration.lineThrough : null,
                    color: step.isCompleted
                        ? AppColors.textHint
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 22,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 40, top: 8),
              child: Text(
                step.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
