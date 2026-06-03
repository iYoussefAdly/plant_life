import 'package:flutter/material.dart';

import '../../../../core/extensions/sensor_type_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/sensor_alert_entity.dart';

class AlertHistoryList extends StatelessWidget {
  final List<SensorAlertEntity> alerts;

  const AlertHistoryList({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No alerts recorded',
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
            Text('Alert History', style: AppTextStyles.headlineSmall),
          ],
        ),
        const SizedBox(height: 12),
        ...alerts.map((alert) => _AlertHistoryTile(
              alert: alert,
              timeAgo: _formatTimeAgo(alert.timestamp),
            )),
      ],
    );
  }

  static String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _AlertHistoryTile extends StatelessWidget {
  final SensorAlertEntity alert;
  final String timeAgo;

  const _AlertHistoryTile({required this.alert, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: alert.isResolved ? AppColors.textHint : _sensorColor,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(_sensorIcon, size: 20, color: _sensorColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: alert.isResolved
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${alert.value.toStringAsFixed(1)}${alert.unit}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: _sensorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (alert.isResolved)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Resolved',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color get _sensorColor => alert.sensorType.color;

  IconData get _sensorIcon => alert.sensorType.icon;
}
