import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.surface
              : AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: BorderDirectional(
            start: BorderSide(color: _typeColor, width: 3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_typeIcon, size: 18, color: _typeColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          // Device-derived reminders carry a fixed title from
                          // the domain layer; show it in the app language.
                          notification.isLocal
                              ? context.l10n.treatmentTaskDueToday
                              : notification.title,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: notification.isRead
                          ? AppColors.textHint
                          : AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatTimeAgo(context, notification.timestamp),
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
      ),
    );
  }

  Color get _typeColor => switch (notification.type) {
        NotificationType.treatmentTask => AppColors.primary,
        NotificationType.sensorWarning => AppColors.warning,
      };

  IconData get _typeIcon => switch (notification.type) {
        NotificationType.treatmentTask => Icons.medical_services_outlined,
        NotificationType.sensorWarning => Icons.warning_amber_rounded,
      };

}
