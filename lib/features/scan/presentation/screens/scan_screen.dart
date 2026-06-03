import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
          ScanError(:final message) => _ErrorView(
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ScanResultCard(result: result, onScanAgain: onScanAgain),
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
            Text(
              message,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
