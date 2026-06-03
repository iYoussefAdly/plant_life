import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/treatment_plan_entity.dart';
import '../bloc/treatments_cubit.dart';
import '../bloc/treatments_state.dart';
import '../widgets/treatment_plan_card.dart';

class TreatmentsScreen extends StatelessWidget {
  const TreatmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Treatments', style: AppTextStyles.headlineMedium),
      ),
      body: BlocBuilder<TreatmentsCubit, TreatmentsState>(
        builder: (context, state) => switch (state) {
          TreatmentsInitial() => const SizedBox.shrink(),
          TreatmentsLoading() =>
            const Center(child: CircularProgressIndicator()),
          TreatmentsSuccess(:final plans) => _PlansList(plans: plans),
          TreatmentsError(:final message) => _ErrorView(
              message: message,
              onRetry: () => context.read<TreatmentsCubit>().loadPlans(),
            ),
        },
      ),
    );
  }
}

class _PlansList extends StatelessWidget {
  final List<TreatmentPlanEntity> plans;

  const _PlansList({required this.plans});

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return Center(
        child: Text(
          'No treatment plans yet',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TreatmentsCubit>().loadPlans(),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: plans.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final plan = plans[index];
          return TreatmentPlanCard(
            plan: plan,
            onTap: () async {
              await context.push(
                AppRoutes.treatmentDetail,
                extra: plan.id,
              );
              if (context.mounted) {
                context.read<TreatmentsCubit>().loadPlans();
              }
            },
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
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
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
