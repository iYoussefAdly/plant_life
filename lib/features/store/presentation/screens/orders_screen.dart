import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/localization/l10n.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/orders_cubit.dart';
import '../bloc/orders_state.dart';
import '../widgets/order_status_chip.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myOrders, style: AppTextStyles.headlineMedium),
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) => switch (state) {
          OrdersInitial() || OrdersLoading() =>
            const Center(child: CircularProgressIndicator()),
          OrdersLoaded(:final orders) => orders.isEmpty
              ? const _EmptyOrders()
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<OrdersCubit>().load(silent: true),
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _OrderCard(order: orders[i]),
                  ),
                ),
          OrdersError(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<OrdersCubit>().load(),
            ),
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.orderDetails}/${order.id}'),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  context.l10n.orderNumber(_shortId(order.id)),
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                OrderStatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${context.l10n.itemsCount(order.totalQuantity)} • ${formatShortDate(order.createdAt)}',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  order.isCashOnDelivery
                      ? Icons.payments_outlined
                      : Icons.credit_card,
                  size: 15,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  order.isCashOnDelivery
                      ? context.l10n.cashOnDeliveryShort
                      : context.l10n.card,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textHint),
                ),
                const Spacer(),
                Text(
                  formatPrice(order.totalPrice),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _shortId(String id) =>
      id.length > 6 ? id.substring(id.length - 6).toUpperCase() : id;
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: AppColors.textHint.withValues(alpha: 0.6)),
          const SizedBox(height: 14),
          Text(context.l10n.noOrdersYet, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 6),
          Text(
            context.l10n.ordersAppearHere,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go(AppRoutes.store),
            child: Text(context.l10n.startShopping),
          ),
        ],
      ),
    );
  }
}
