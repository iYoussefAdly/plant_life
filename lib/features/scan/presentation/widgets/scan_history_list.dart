import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/scan_result_entity.dart';

class ScanHistoryList extends StatelessWidget {
  final List<ScanResultEntity> history;

  const ScanHistoryList({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            context.l10n.noScansYet,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history_outlined,
                size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Text(context.l10n.scanHistory, style: AppTextStyles.headlineSmall),
          ],
        ),
        const SizedBox(height: 12),
        ...history.map((scan) => _ScanHistoryTile(
              scan: scan,
              timeAgo: formatTimeAgo(context, scan.scannedAt),
            )),
      ],
    );
  }

}

class _ScanHistoryTile extends StatelessWidget {
  final ScanResultEntity scan;
  final String timeAgo;

  const _ScanHistoryTile({required this.scan, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    final isHealthy = scan.status == ScanStatus.healthy;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isHealthy ? AppColors.success : AppColors.error,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 48,
              height: 48,
              child: scan.imagePath.isNotEmpty
                  ? Image.network(
                      scan.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _StatusIcon(isHealthy: isHealthy),
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                              ? child
                              : Container(
                                  color: AppColors.textHint.withValues(alpha: 0.1),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                    )
                  : _StatusIcon(isHealthy: isHealthy),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHealthy
                      ? context.l10n.healthy
                      : scan.diseases.map((d) => d.name).join(', '),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  timeAgo,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          if (!isHealthy)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${scan.diseases.length} found',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.error,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Leading fallback shown when a scan has no image (or it fails to load).
class _StatusIcon extends StatelessWidget {
  final bool isHealthy;

  const _StatusIcon({required this.isHealthy});

  @override
  Widget build(BuildContext context) {
    final color = isHealthy ? AppColors.success : AppColors.error;
    return Container(
      color: color.withValues(alpha: 0.1),
      child: Icon(
        isHealthy ? Icons.check_circle_outline : Icons.bug_report_outlined,
        size: 22,
        color: color,
      ),
    );
  }
}
