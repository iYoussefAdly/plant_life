import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/localization/l10n.dart';
import '../../domain/entities/cart_entity.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/cart_state.dart';
import '../widgets/quantity_stepper.dart';
import '../widgets/store_network_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myCart, style: AppTextStyles.headlineMedium),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final canClear = state is CartLoaded && !state.cart.isEmpty;
              if (!canClear) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _confirmClear(context),
                child: Text(context.l10n.clear),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) => switch (state) {
          CartInitial() || CartLoading() =>
            const Center(child: CircularProgressIndicator()),
          CartLoaded() => state.cart.isEmpty
              ? const _EmptyCart()
              : _CartContent(cart: state.cart, busy: state.isMutating),
          CartError(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<CartCubit>().load(),
            ),
        },
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.clearCart),
        content: Text(ctx.l10n.removeAllFromCart),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ctx.l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ctx.l10n.clear)),
        ],
      ),
    );
    if (ok == true && context.mounted) context.read<CartCubit>().clear();
  }
}

class _CartContent extends StatelessWidget {
  final CartEntity cart;
  final bool busy;

  const _CartContent({required this.cart, required this.busy});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _CartItemTile(item: cart.items[index], enabled: !busy),
          ),
        ),
        _CheckoutBar(cart: cart, busy: busy),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemEntity item;
  final bool enabled;

  const _CartItemTile({required this.item, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartCubit>();
    return Container(
      padding: const EdgeInsets.all(10),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 64,
              child: StoreNetworkImage(url: item.product.imageUrl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style:
                      AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formatPrice(item.product.effectivePrice),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    QuantityStepper(
                      quantity: item.quantity,
                      max: item.product.stock > 0 ? item.product.stock : 99,
                      enabled: enabled,
                      onChanged: (q) =>
                          cart.updateQuantity(item.product.id, q),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error, size: 20),
                      onPressed: enabled
                          ? () => cart.removeItem(item.product.id)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final CartEntity cart;
  final bool busy;

  const _CheckoutBar({required this.cart, required this.busy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(context.l10n.subtotalWithCount(cart.totalQuantity),
                  style: AppTextStyles.bodyMedium),
              const Spacer(),
              Text(
                formatPrice(cart.subtotal),
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: busy ? null : () => context.push(AppRoutes.checkout),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text(context.l10n.proceedToCheckout),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 64, color: AppColors.textHint.withValues(alpha: 0.6)),
          const SizedBox(height: 14),
          Text(context.l10n.cartEmptyTitle, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 6),
          Text(
            context.l10n.cartEmptyHint,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go(AppRoutes.store),
            child: Text(context.l10n.goToStore),
          ),
        ],
      ),
    );
  }
}
