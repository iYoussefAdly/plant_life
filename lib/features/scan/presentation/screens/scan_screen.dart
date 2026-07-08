import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/localization/l10n.dart';
import '../../domain/entities/scan_result_entity.dart';
import '../bloc/scan_cubit.dart';
import '../bloc/scan_state.dart';
import '../widgets/image_source_picker.dart';
import '../widgets/scan_history_list.dart';
import '../widgets/scan_result_card.dart';
import '../widgets/scan_source_sheet.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.plantScanner, style: AppTextStyles.headlineMedium),
      ),
      body: BlocBuilder<ScanCubit, ScanState>(
        builder: (context, state) => switch (state) {
          ScanInitial() => _InitialView(
              onSourceSelected: (source) => _handleScan(context, source),
            ),
          ScanAnalyzing() => const _AnalyzingView(),
          ScanHistoryLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
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

  Future<void> _handleScan(
    BuildContext context,
    ScanImageSource source,
  ) async {
    final cubit = context.read<ScanCubit>();

    // Gallery supports selecting multiple images; camera/ESP32 stay single.
    if (source == ScanImageSource.gallery) {
      final paths = await pickScanImagePaths();
      if (paths.isEmpty) return;
      cubit.scanImages(paths, source);
      return;
    }

    final path = await pickScanImagePath(context, source);
    if (path == null) return;
    cubit.scanImages([path], source);
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
                context.l10n.viewScanHistory,
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
          Text(context.l10n.analyzingPlant, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            context.l10n.aiDetecting,
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
    final isDiseased = result.status == ScanStatus.diseased;
    // Start Treatment needs a persisted scanId to create a heal plan. Camera
    // results come from the AI model service, which returns no scanId, so the
    // button is hidden for them — the (always-present) Rescan action remains.
    // Gallery results carry a valid scanId and still show Start Treatment.
    final canStartTreatment = isDiseased && result.id.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ScanResultCard(
        result: result,
        onScanAgain: onScanAgain,
        onStartTreatment:
            canStartTreatment ? () => _startTreatment(context) : null,
      ),
    );
  }

  /// Creates a heal plan from this scan, then opens its detail screen.
  Future<void> _startTreatment(BuildContext context) async {
    final cubit = context.read<ScanCubit>();
    // The loader dialog lives on the root navigator (showDialog default), so it
    // must be dismissed via the root navigator — not Navigator.of(context),
    // which resolves to the bottom-nav shell's branch navigator. Captured
    // before the await to avoid using context across the async gap.
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final outcome = await cubit.createPlan(result.id);
    rootNavigator.pop(); // dismiss the loader
    if (!context.mounted) return;

    if (outcome.planId != null) {
      context.push(AppRoutes.treatmentDetail, extra: outcome.planId);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(outcome.error != null
              ? localizeMessage(context, outcome.error!)
              : context.l10n.couldNotStartTreatment),
        ),
      );
    }
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
