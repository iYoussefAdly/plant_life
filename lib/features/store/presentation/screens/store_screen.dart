import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/localization/l10n.dart';
import '../product_labels.dart';
import '../../domain/entities/product_category.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/products_cubit.dart';
import '../bloc/products_state.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/product_card.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Reflect any pre-existing search (this cubit is a shared singleton, and a
    // "Search in Store" deep-link may have set a keyword before this build).
    _searchController.text = context.read<ProductsCubit>().query.keyword;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      context.read<ProductsCubit>().loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<ProductsCubit>().search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.plantStore, style: AppTextStyles.headlineMedium),
        actions: const [CartIconButton(), SizedBox(width: 4)],
      ),
      body: BlocListener<ProductsCubit, ProductsState>(
        // Keep the search field in sync when the keyword changes from outside
        // the field (e.g. a "Search in Store" deep-link). User typing already
        // matches, so this is a no-op in that case.
        listenWhen: (prev, curr) => curr is ProductsLoaded,
        listener: (context, state) {
          if (state is ProductsLoaded &&
              state.query.keyword != _searchController.text) {
            _searchController.text = state.query.keyword;
            _searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: _searchController.text.length),
            );
          }
        },
        child: Column(
          children: [
            _SearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: () {
                _searchController.clear();
                context.read<ProductsCubit>().search('');
              },
            ),
            const _CategoryChips(),
            const _SortBar(),
            Expanded(
              child: BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) => switch (state) {
                  ProductsInitial() ||
                  ProductsLoading() =>
                    const _ProductsSkeleton(),
                  ProductsLoaded() => state.products.isEmpty
                      ? const _EmptyProducts()
                      : _ProductGrid(
                          state: state,
                          controller: _scrollController,
                        ),
                  ProductsError(:final message) => ErrorView(
                      message: message,
                      onRetry: () => context.read<ProductsCubit>().load(),
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: context.l10n.searchProducts,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onClear,
                  ),
          ),
          isDense: true,
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ProductsCubit>();
    final selected = cubit.query.category;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          _Chip(
            label: context.l10n.all,
            selected: selected == null,
            onTap: () => context.read<ProductsCubit>().setCategory(null),
          ),
          ...ProductCategory.values.map((c) => _Chip(
                label: c.label(context),
                selected: selected == c,
                onTap: () => context.read<ProductsCubit>().setCategory(c),
              )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.textHint.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SortBar extends StatelessWidget {
  const _SortBar();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ProductsCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Row(
        children: [
          Text(
            cubit.query.hasActiveFilters
                ? context.l10n.filtered
                : context.l10n.allProducts,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => _openSort(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.swap_vert, size: 18, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    cubit.query.sort.label(context),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSort(BuildContext context) {
    final cubit = context.read<ProductsCubit>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(sheetContext.l10n.sortBy, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            ...ProductSort.values.map((s) => ListTile(
                  title: Text(s.label(sheetContext)),
                  trailing: cubit.query.sort == s
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    cubit.setSort(s);
                    Navigator.of(sheetContext).pop();
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final ProductsLoaded state;
  final ScrollController controller;

  const _ProductGrid({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    final products = state.products;
    return RefreshIndicator(
      onRefresh: () => context.read<ProductsCubit>().load(),
      color: AppColors.primary,
      child: GridView.builder(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.70,
        ),
        itemCount: products.length + (state.hasMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= products.length) {
            return const _CardSkeleton();
          }
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () =>
                context.push('${AppRoutes.productDetails}/${product.id}'),
            onAddToCart: () async {
              final error =
                  await context.read<CartCubit>().addToCart(product.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error != null
                        ? localizeMessage(context, error)
                        : context.l10n.addedToCart),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Icon(Icons.search_off,
            size: 56, color: AppColors.textHint.withValues(alpha: 0.6)),
        const SizedBox(height: 12),
        Center(
          child: Text(
            context.l10n.noProductsFound,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: TextButton(
            onPressed: () => context.read<ProductsCubit>().clearFilters(),
            child: Text(context.l10n.clearFilters),
          ),
        ),
      ],
    );
  }
}

class _ProductsSkeleton extends StatelessWidget {
  const _ProductsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.70,
        children: List.generate(6, (_) => const _CardSkeleton()),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(aspectRatio: 1.25, child: SkeletonBox(height: 0)),
          SizedBox(height: 8),
          SkeletonBox(height: 12, radius: 6),
          SizedBox(height: 6),
          SkeletonBox(width: 80, height: 12, radius: 6),
        ],
      ),
    );
  }
}
