import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order_entity.dart';

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;
  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (color, label, icon) = switch (status) {
      OrderStatus.pending =>
        (AppColors.warning, l10n.statusPending, Icons.schedule),
      OrderStatus.processing =>
        (AppColors.primary, l10n.statusProcessing, Icons.autorenew),
      OrderStatus.shipped =>
        (AppColors.humidity, l10n.statusShipped, Icons.local_shipping_outlined),
      OrderStatus.delivered =>
        (AppColors.success, l10n.statusDelivered, Icons.check_circle_outline),
      OrderStatus.cancelled =>
        (AppColors.error, l10n.statusCancelled, Icons.cancel_outlined),
      OrderStatus.unknown =>
        (AppColors.textSecondary, l10n.statusProcessing, Icons.info_outline),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
