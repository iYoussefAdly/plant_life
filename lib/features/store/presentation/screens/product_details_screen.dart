import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_product_usecase.dart';
import '../bloc/cart_cubit.dart';
import '../widgets/quantity_stepper.dart';
import '../widgets/store_network_image.dart';

/// Self-loading product details (a lightweight FutureBuilder keeps this off the
/// global DI graph while still using the injected use case).
class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final GetProductUseCase getProduct;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.getProduct,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Future<ApiResult<ProductEntity>> _future = widget.getProduct(widget.productId);

  void _reload() =>
      setState(() => _future = widget.getProduct(widget.productId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product', style: AppTextStyles.headlineMedium),
      ),
      body: FutureBuilder<ApiResult<ProductEntity>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return switch (snapshot.data!) {
            Success(:final data) => _Details(product: data),
            Error(:final failure) =>
              ErrorView(message: failure.message, onRetry: _reload),
          };
        },
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final ProductEntity product;

  const _Details({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              AspectRatio(
                aspectRatio: 1.1,
                child: StoreNetworkImage(url: product.imageUrl),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _CategoryPill(label: product.category),
                        const Spacer(),
                        _StockChip(stock: product.stock),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(product.name, style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatPrice(product.effectivePrice),
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              formatPrice(product.price),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (product.unit.isNotEmpty)
                          Text(
                            'per ${product.unit}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (product.description.isNotEmpty) ...[
                      Text('Description', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 6),
                      Text(
                        product.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    if (product.activeIngredient != null)
                      _InfoRow(
                        icon: Icons.science_outlined,
                        label: 'Active ingredient',
                        value: product.activeIngredient!,
                      ),
                    if (product.usageInstructions != null)
                      _InfoRow(
                        icon: Icons.menu_book_outlined,
                        label: 'How to use',
                        value: product.usageInstructions!,
                      ),
                    if (product.brand != null)
                      _InfoRow(
                        icon: Icons.sell_outlined,
                        label: 'Brand',
                        value: product.brand!,
                      ),
                    if (product.storeName != null)
                      _InfoRow(
                        icon: Icons.storefront_outlined,
                        label: 'Sold by',
                        value: product.storeName!,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _AddToCartBar(product: product),
      ],
    );
  }
}

class _AddToCartBar extends StatefulWidget {
  final ProductEntity product;
  const _AddToCartBar({required this.product});

  @override
  State<_AddToCartBar> createState() => _AddToCartBarState();
}

class _AddToCartBarState extends State<_AddToCartBar> {
  int _qty = 1;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final available = product.inStock;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
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
      child: Row(
        children: [
          if (available)
            QuantityStepper(
              quantity: _qty,
              max: product.stock,
              onChanged: (q) => setState(() => _qty = q),
            ),
          if (available) const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: !available || _busy ? null : _add,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add_shopping_cart),
              label: Text(available ? 'Add to Cart' : 'Out of stock'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _add() async {
    setState(() => _busy = true);
    final error = await context
        .read<CartCubit>()
        .addToCart(widget.product.id, quantity: _qty);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Added $_qty to cart'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  const _CategoryPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.replaceAll('-', ' '),
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StockChip extends StatelessWidget {
  final int stock;
  const _StockChip({required this.stock});

  @override
  Widget build(BuildContext context) {
    final ok = stock > 0;
    final color = ok ? AppColors.success : AppColors.error;
    return Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.cancel, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          ok ? '$stock in stock' : 'Out of stock',
          style: AppTextStyles.labelMedium.copyWith(color: color),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
