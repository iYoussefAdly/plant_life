import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/treatment_plan_entity.dart';
import '../bloc/treatment_detail_cubit.dart';
import '../bloc/treatment_detail_state.dart';
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
        title: Text('Treatment Plan', style: AppTextStyles.headlineMedium),
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
                    Text(message, style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => context.read<TreatmentDetailCubit>().retry(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        },
      ),
    );
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
                  Text('Progress', style: AppTextStyles.labelLarge),
                  Text(
                    '$completedCount of ${plan.steps.length} tasks',
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
                  padding: const EdgeInsets.only(left: 10),
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
        Text('Daily Tasks', style: AppTextStyles.headlineSmall),
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
              ),
            )),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push(
              AppRoutes.recoveryProgress,
              extra: plan.id,
            ),
            icon: const Icon(Icons.trending_up),
            label: const Text('View Recovery Progress'),
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
        Text(plan.title, style: AppTextStyles.headlineMedium),
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
