import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_entity.dart';

sealed class ProductsState {
  const ProductsState();
}

final class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

final class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

final class ProductsLoaded extends ProductsState {
  final List<ProductEntity> products;
  final ProductQuery query;
  final bool hasMore;
  final bool isLoadingMore;
  final int total;

  const ProductsLoaded({
    required this.products,
    required this.query,
    required this.hasMore,
    required this.isLoadingMore,
    required this.total,
  });

  ProductsLoaded copyWith({
    List<ProductEntity>? products,
    ProductQuery? query,
    bool? hasMore,
    bool? isLoadingMore,
    int? total,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      query: query ?? this.query,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      total: total ?? this.total,
    );
  }
}

final class ProductsError extends ProductsState {
  final String message;
  const ProductsError(this.message);
}
