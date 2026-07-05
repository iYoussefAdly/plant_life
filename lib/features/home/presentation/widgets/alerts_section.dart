import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/plant_alert_entity.dart';

class AlertsSection extends StatelessWidget {
  final List<PlantAlertEntity> alerts;

  const AlertsSection({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.notifications_active_outlined,
          title: context.l10n.alerts,
          color: AppColors.warning,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${alerts.length}',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...alerts.map((alert) => _AlertTile(
              alert: alert,
              timeAgo: formatTimeAgo(context, alert.timestamp),
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
              color: _severityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_severityIcon, size: 19, color: _severityColor),
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
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeAgo,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                    fontSize: 11,
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
