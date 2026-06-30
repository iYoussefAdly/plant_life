import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/recovery_entity.dart';
import '../bloc/recovery_cubit.dart';
import '../bloc/recovery_state.dart';
import '../widgets/recovery_header.dart';
import '../widgets/rescan_card.dart';

/// Navigation argument for the Recovery route: the original scan id (parent of
/// the rescans) plus a title for the header.
class RecoveryArgs {
  final String scanId;
  final String title;

  const RecoveryArgs({required this.scanId, this.title = ''});
}

class RecoveryProgressScreen extends StatelessWidget {
  const RecoveryProgressScreen({super.key});

  static final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recovery Progress', style: AppTextStyles.headlineMedium),
      ),
      body: BlocBuilder<RecoveryCubit, RecoveryState>(
        builder: (context, state) => switch (state) {
          RecoveryInitial() => const SizedBox.shrink(),
          RecoveryLoading() =>
            const Center(child: CircularProgressIndicator()),
          RecoverySuccess(:final data) => _RecoveryContent(recovery: data),
          RecoveryError(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<RecoveryCubit>().retry(),
            ),
        },
      ),
    );
  }

  static Future<void> startRescan(BuildContext context) async {
    final cubit = context.read<RecoveryCubit>();
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (picked == null) return;
    await cubit.createRescan(picked.path);
  }
}

class _RecoveryContent extends StatelessWidget {
  final RecoveryEntity recovery;

  const _RecoveryContent({required this.recovery});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        RecoveryHeader(recovery: recovery),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => RecoveryProgressScreen.startRescan(context),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Rescan now'),
          ),
        ),
        const SizedBox(height: 24),
        if (recovery.rescans.isEmpty)
          const _EmptyTimeline()
        else ...[
          Row(
            children: [
              const Icon(Icons.timeline_outlined,
                  size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text('Rescan History', style: AppTextStyles.headlineSmall),
            ],
          ),
          const SizedBox(height: 12),
          ...recovery.rescans.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RescanCard(
                rescan: entry.value,
                isLatest: entry.key == 0,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: AppColors.textHint.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No follow-up scans yet',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap "Rescan now" to track your plant\'s recovery over time',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
