import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/recovery_entity.dart';
import '../bloc/recovery_cubit.dart';
import '../bloc/recovery_state.dart';
import '../widgets/recovery_header.dart';
import '../widgets/weekly_image_card.dart';

class RecoveryProgressScreen extends StatelessWidget {
  const RecoveryProgressScreen({super.key});

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
        const SizedBox(height: 24),
        if (recovery.weeklyImages.isEmpty)
          const _EmptyTimeline()
        else ...[
          Row(
            children: [
              const Icon(Icons.timeline_outlined,
                  size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text('Weekly Timeline', style: AppTextStyles.headlineSmall),
            ],
          ),
          const SizedBox(height: 12),
          ...recovery.weeklyImages.reversed.toList().asMap().entries.map(
            (entry) {
              final isLatest = entry.key == 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WeeklyImageCard(
                  weeklyImage: entry.value,
                  isLatest: isLatest,
                ),
              );
            },
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
            'No progress photos yet',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Weekly photos will appear here as you track recovery',
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
