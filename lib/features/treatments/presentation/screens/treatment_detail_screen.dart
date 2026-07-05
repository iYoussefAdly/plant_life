import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/l10n.dart';
import '../../../recovery/presentation/screens/recovery_progress_screen.dart';
import '../../domain/entities/treatment_plan_entity.dart';
import '../bloc/treatment_detail_cubit.dart';
import '../bloc/treatment_detail_state.dart';
import '../widgets/task_detail_sheet.dart';
import '../widgets/treatment_day_section.dart';
import '../widgets/treatment_progress_color.dart';

/// Navigation argument for the treatment detail route. Accepts the plan id and
/// an optional task to highlight (e.g. when opened from Home's Today's Tasks).
class TreatmentDetailArgs {
  final String planId;
  final String? highlightStepId;

  const TreatmentDetailArgs({required this.planId, this.highlightStepId});
}

class TreatmentDetailScreen extends StatelessWidget {
  final String? highlightStepId;

  const TreatmentDetailScreen({super.key, this.highlightStepId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.treatmentPlan, style: AppTextStyles.headlineMedium),
        actions: [
          BlocBuilder<TreatmentDetailCubit, TreatmentDetailState>(
            builder: (context, state) {
              if (state is TreatmentDetailSuccess &&
                  state.plan.status == TreatmentPlanStatus.active) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'cancel') _confirmCancel(context);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          const Icon(Icons.cancel_outlined,
                              size: 20, color: AppColors.error),
                          const SizedBox(width: 10),
                          Text(context.l10n.cancelPlan),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<TreatmentDetailCubit, TreatmentDetailState>(
        builder: (context, state) => switch (state) {
          TreatmentDetailInitial() => const SizedBox.shrink(),
          TreatmentDetailLoading() =>
            const Center(child: CircularProgressIndicator()),
          TreatmentDetailSuccess(:final plan) =>
            _DetailContent(plan: plan, highlightStepId: highlightStepId),
          TreatmentDetailError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(localizeMessage(context, message), style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => context.read<TreatmentDetailCubit>().retry(),
                      icon: const Icon(Icons.refresh),
                      label: Text(context.l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
        },
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final cubit = context.read<TreatmentDetailCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.cancelPlan),
        content: Text(dialogContext.l10n.cancelPlanConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.l10n.keepPlan),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.l10n.cancelPlan),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final error = await cubit.cancelPlan();
    if (error != null && context.mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text(localizeMessage(context, error))),
      );
    }
  }
}

class _DetailContent extends StatelessWidget {
  final TreatmentPlanEntity plan;
  final String? highlightStepId;

  const _DetailContent({required this.plan, this.highlightStepId});

  @override
  Widget build(BuildContext context) {
    final completedCount = plan.steps.where((s) => s.isCompleted).length;
    final percentage = (plan.progress * 100).toStringAsFixed(0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PlanHeader(plan: plan),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.progress, style: AppTextStyles.labelLarge),
                  Text(
                    context.l10n.tasksProgress(completedCount, plan.steps.length),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearPercentIndicator(
                padding: EdgeInsets.zero,
                lineHeight: 8,
                percent: plan.progress,
                barRadius: const Radius.circular(4),
                progressColor: _progressColor,
                backgroundColor: AppColors.textHint.withValues(alpha: 0.2),
                trailing: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 10),
                  child: Text(
                    '$percentage%',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: _progressColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(context.l10n.dailyTasks, style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),
        ...plan.days.map((day) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TreatmentDaySection(
                day: day,
                highlightStepId: highlightStepId,
                onToggleTask: (stepId, isCompleted) {
                  context.read<TreatmentDetailCubit>().toggleStep(
                        planId: plan.id,
                        stepId: stepId,
                        isCompleted: isCompleted,
                      );
                },
                onOpenTask: (stepId) {
                  final taskIndex = int.tryParse(stepId);
                  if (taskIndex == null) return;
                  // Pass the timeline-corrected date so the sheet matches the
                  // tile (the task endpoint returns the raw off-by-one date).
                  // Look up by step id rather than list position, in case the
                  // step list is shorter than the raw backend task array.
                  DateTime? scheduledAt;
                  for (final step in plan.steps) {
                    if (step.id == stepId) {
                      scheduledAt = step.scheduledAt;
                      break;
                    }
                  }
                  showTaskDetailSheet(
                    context,
                    planId: plan.id,
                    taskIndex: taskIndex,
                    scheduledDate: scheduledAt,
                    recommendedProducts: plan.recommendedProducts,
                  );
                },
              ),
            )),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push(
              AppRoutes.recoveryProgress,
              extra: RecoveryArgs(scanId: plan.scanId, title: plan.title),
            ),
            icon: const Icon(Icons.trending_up),
            label: Text(context.l10n.viewRecoveryProgress),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Color get _progressColor => treatmentProgressColor(plan.progress);
}

class _PlanHeader extends StatelessWidget {
  final TreatmentPlanEntity plan;

  const _PlanHeader({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(plan.title, style: AppTextStyles.headlineMedium),
            ),
            if (plan.status != TreatmentPlanStatus.active) ...[
              const SizedBox(width: 8),
              _StatusChip(status: plan.status),
            ],
          ],
        ),
        if (plan.description.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            plan.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TreatmentPlanStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TreatmentPlanStatus.completed =>
        (context.l10n.completed, AppColors.success),
      TreatmentPlanStatus.cancelled =>
        (context.l10n.cancelled, AppColors.error),
      TreatmentPlanStatus.active => (context.l10n.active, AppColors.primary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
