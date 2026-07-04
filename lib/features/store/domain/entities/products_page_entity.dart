import 'product_entity.dart';

/// One page of products plus the pagination cursor, for lazy loading.
class ProductsPageEntity {
  final List<ProductEntity> products;
  final int page;
  final int totalPages;
  final int total;

  const ProductsPageEntity({
    required this.products,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  bool get hasMore => page < totalPages;
}
