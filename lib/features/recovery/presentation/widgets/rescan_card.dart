import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/rescan_entity.dart';

class RescanCard extends StatelessWidget {
  final RescanEntity rescan;
  final bool isLatest;

  const RescanCard({super.key, required this.rescan, this.isLatest = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isLatest
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: rescan.imageUrl.isNotEmpty
                  ? Image.network(
                      rescan.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _ImageFallback(),
                      loadingBuilder: (context, child, progress) =>
                          progress == null ? child : const _ImageFallback(),
                    )
                  : const _ImageFallback(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      formatShortDate(rescan.capturedAt),
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isLatest) ...[
                      const SizedBox(width: 8),
                      _Badge(
                        label: 'Latest',
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Severity ${rescan.severityPercent.toStringAsFixed(0)}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    _deltaBadge(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _deltaBadge() {
    if (rescan.severityDelta == 0) {
      return const _Badge(label: 'No change', color: AppColors.textHint);
    }
    final amount = rescan.severityDelta.abs().toStringAsFixed(0);
    return _Badge(
      label: rescan.improved ? '↓ $amount%' : '↑ $amount%',
      color: rescan.improved ? AppColors.success : AppColors.error,
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Icon(Icons.photo_camera_outlined,
          size: 24, color: AppColors.primary),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
