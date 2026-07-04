import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order_entity.dart';

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;
  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (status) {
      OrderStatus.pending => (AppColors.warning, 'Pending', Icons.schedule),
      OrderStatus.processing => (AppColors.primary, 'Processing', Icons.autorenew),
      OrderStatus.shipped =>
        (AppColors.humidity, 'Shipped', Icons.local_shipping_outlined),
      OrderStatus.delivered =>
        (AppColors.success, 'Delivered', Icons.check_circle_outline),
      OrderStatus.cancelled =>
        (AppColors.error, 'Cancelled', Icons.cancel_outlined),
      OrderStatus.unknown =>
        (AppColors.textSecondary, 'Processing', Icons.info_outline),
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
