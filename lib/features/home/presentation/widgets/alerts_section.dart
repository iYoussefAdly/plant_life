import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/plant_alert_entity.dart';

class AlertsSection extends StatelessWidget {
  final List<PlantAlertEntity> alerts;

  const AlertsSection({super.key, required this.alerts});

  static String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.notifications_outlined,
                size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Text('Alerts', style: AppTextStyles.headlineSmall),
          ],
        ),
        const SizedBox(height: 12),
        ...alerts.map((alert) => _AlertTile(
              alert: alert,
              timeAgo: _formatTimeAgo(alert.timestamp),
            )),
      ],
    );
  }
}

class _AlertTile extends StatelessWidget {
  final PlantAlertEntity alert;
  final String timeAgo;

  const _AlertTile({required this.alert, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _severityColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: _severityColor, width: 3),
        ),
      ),
      child: Row(
        children: [
          Icon(_severityIcon, size: 20, color: _severityColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
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
        ],
      ),
    );
  }

  Color get _severityColor => switch (alert.severity) {
        AlertSeverity.info => AppColors.primary,
        AlertSeverity.warning => AppColors.warning,
        AlertSeverity.critical => AppColors.error,
      };

  IconData get _severityIcon => switch (alert.severity) {
        AlertSeverity.info => Icons.info_outline,
        AlertSeverity.warning => Icons.warning_amber_outlined,
        AlertSeverity.critical => Icons.error_outline,
      };
}
