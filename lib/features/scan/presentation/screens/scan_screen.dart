import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/scan_result_entity.dart';
import '../bloc/scan_cubit.dart';
import '../bloc/scan_state.dart';
import '../widgets/image_source_picker.dart';
import '../widgets/scan_history_list.dart';
import '../widgets/scan_result_card.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Scanner', style: AppTextStyles.headlineMedium),
      ),
      body: BlocBuilder<ScanCubit, ScanState>(
        builder: (context, state) => switch (state) {
          ScanInitial() => _InitialView(
              onSourceSelected: (source) => _handleScan(context, source),
            ),
          ScanAnalyzing() => const _AnalyzingView(),
          ScanResultReady(:final result) => _ResultView(
              result: result,
              onScanAgain: () => context.read<ScanCubit>().reset(),
            ),
          ScanHistoryLoaded(:final history) => _HistoryView(
              history: history,
              onSourceSelected: (source) => _handleScan(context, source),
            ),
          ScanError(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<ScanCubit>().reset(),
            ),
        },
      ),
    );
  }

  void _handleScan(BuildContext context, ScanImageSource source) {
    context.read<ScanCubit>().scanImage('mock_image_${source.name}.jpg');
  }
}

class _InitialView extends StatelessWidget {
  final ValueChanged<ScanImageSource> onSourceSelected;

  const _InitialView({required this.onSourceSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          ScanImageSourcePicker(onSourceSelected: onSourceSelected),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.read<ScanCubit>().loadHistory(),
              child: Text(
                'View Scan History',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyzingView extends StatelessWidget {
  const _AnalyzingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text('Analyzing plant...', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Our AI is detecting potential diseases',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final ScanResultEntity result;
  final VoidCallback onScanAgain;

  const _ResultView({required this.result, required this.onScanAgain});

  @override
  Widget build(BuildContext context) {
    final treatment = result.suggestedTreatment;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ScanResultCard(
        result: result,
        onScanAgain: onScanAgain,
        onStartTreatment: treatment != null
            ? () => context.push(
                  AppRoutes.treatmentDetail,
                  extra: treatment.treatmentPlanId,
                )
            : null,
        onRemindLater: treatment != null
            ? (_) => _showReminderPicker(context, treatment.treatmentPlanId)
            : null,
      ),
    );
  }

  Future<void> _showReminderPicker(
    BuildContext context,
    String treatmentPlanId,
  ) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null || !context.mounted) return;

    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final saved = await context.read<ScanCubit>().saveReminder(
          treatmentPlanId: treatmentPlanId,
          scanResultId: result.id,
          scheduledAt: scheduledAt,
        );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Reminder set for ${date.day}/${date.month} at ${time.format(context)}'
              : 'Failed to set reminder',
        ),
      ),
    );
  }
}

class _HistoryView extends StatelessWidget {
  final List<ScanResultEntity> history;
  final ValueChanged<ScanImageSource> onSourceSelected;

  const _HistoryView({
    required this.history,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ScanImageSourcePicker(onSourceSelected: onSourceSelected),
          const SizedBox(height: 24),
          ScanHistoryList(history: history),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
