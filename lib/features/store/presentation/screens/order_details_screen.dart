import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/order_details_cubit.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/store_network_image.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details', style: AppTextStyles.headlineMedium),
      ),
      body: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        builder: (context, state) => switch (state) {
          OrderDetailsLoading() =>
            const Center(child: CircularProgressIndicator()),
          OrderDetailsLoaded(:final order) => _Content(order: order),
          OrderDetailsError(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<OrderDetailsCubit>().retry(),
            ),
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final OrderEntity order;
  const _Content({required this.order});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order #${_shortId(order.id)}',
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(formatShortDate(order.createdAt),
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const Spacer(),
              OrderStatusChip(status: order.status),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text('Items', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        ...order.items.map((item) => _ItemRow(item: item)),
        const SizedBox(height: 12),
        _card(
          child: Column(
            children: [
              _priceRow('Items', order.itemsPrice),
              const SizedBox(height: 6),
              _priceRow('Shipping', order.shippingPrice),
              const Divider(height: 20),
              _priceRow('Total', order.totalPrice, emphasize: true),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    order.isCashOnDelivery
                        ? Icons.payments_outlined
                        : Icons.credit_card,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.isCashOnDelivery
                        ? 'Cash on Delivery'
                        : 'Card Payment',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    order.isPaid ? 'Paid' : 'Not paid',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: order.isPaid ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (order.shippingAddress != null) ...[
                const Divider(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatAddress(order),
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatAddress(OrderEntity order) {
    final a = order.shippingAddress!;
    final parts = [a.street, a.city, if (a.details.isNotEmpty) a.details, a.phone]
        .where((p) => p.isNotEmpty);
    return parts.join('\n');
  }

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );

  Widget _priceRow(String label, double value, {bool emphasize = false}) {
    final style = emphasize
        ? AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)
        : AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary);
    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(
          formatPrice(value),
          style: emphasize
              ? style.copyWith(color: AppColors.primary)
              : style.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  String _shortId(String id) =>
      id.length > 6 ? id.substring(id.length - 6).toUpperCase() : id;
}

class _ItemRow extends StatelessWidget {
  final OrderItemEntity item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: StoreNetworkImage(url: item.image),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${item.quantity} × ${formatPrice(item.price)}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            formatPrice(item.lineTotal),
            style: AppTextStyles.labelLarge
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
