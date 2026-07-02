import 'package:flutter/material.dart';

import '../../../../core/extensions/sensor_type_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/sensor_alert_entity.dart';

class AlertHistoryList extends StatelessWidget {
  final List<SensorAlertEntity> alerts;

  const AlertHistoryList({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.history_outlined,
          title: 'Alert History',
          trailing: alerts.isEmpty
              ? null
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${alerts.length}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        if (alerts.isEmpty)
          const _EmptyAlerts()
        else
          ...alerts.map((alert) => _AlertHistoryTile(
                alert: alert,
                timeAgo: formatTimeAgo(alert.timestamp),
              )),
      ],
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  const _EmptyAlerts();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.verified_outlined,
            size: 40,
            color: AppColors.success.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 10),
          Text(
            'No alerts recorded',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Your sensors are operating within safe ranges',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _AlertHistoryTile extends StatelessWidget {
  final SensorAlertEntity alert;
  final String timeAgo;

  const _AlertHistoryTile({required this.alert, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    final color = alert.sensorType.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: alert.isResolved ? 0.08 : 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              alert.sensorType.icon,
              size: 19,
              color: alert.isResolved ? color.withValues(alpha: 0.55) : color,
            ),
          ),
          const SizedBox(width: 12),
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
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                        fontSize: 11,
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
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle,
                      size: 11, color: AppColors.success),
                  const SizedBox(width: 3),
                  Text(
                    'Resolved',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
