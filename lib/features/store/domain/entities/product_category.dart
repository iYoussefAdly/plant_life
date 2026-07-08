/// The fixed set of store categories (from the API contract). Display names
/// live in the presentation layer (`product_labels.dart`) so they can be
/// localized.
enum ProductCategory {
  plantDiseaseTreatment('plant-disease-treatment'),
  plantTools('plant-tools'),
  seeds('seeds'),
  fertilizers('fertilizers'),
  devices('devices');

  final String apiValue;

  const ProductCategory(this.apiValue);
}

/// How the product list is sorted (maps to the API `sort` param).
enum ProductSort {
  newest('-createdAt'),
  priceLowToHigh('price'),
  priceHighToLow('-price'),
  bestSelling('-soldCount');

  final String apiValue;

  const ProductSort(this.apiValue);
}

/// Immutable product-list query (search + filter + sort + page).
class ProductQuery {
  final String keyword;
  final ProductCategory? category;
  final double? minPrice;
  final double? maxPrice;
  final ProductSort sort;
  final int page;
  final int limit;

  const ProductQuery({
    this.keyword = '',
    this.category,
    this.minPrice,
    this.maxPrice,
    this.sort = ProductSort.newest,
    this.page = 1,
    this.limit = 12,
  });

  ProductQuery copyWith({
    String? keyword,
    ProductCategory? category,
    bool clearCategory = false,
    double? minPrice,
    bool clearMinPrice = false,
    double? maxPrice,
    bool clearMaxPrice = false,
    ProductSort? sort,
    int? page,
  }) {
    return ProductQuery(
      keyword: keyword ?? this.keyword,
      category: clearCategory ? null : (category ?? this.category),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      sort: sort ?? this.sort,
      page: page ?? this.page,
      limit: limit,
    );
  }

  /// Whether any filter (beyond the default sort/page) is active.
  bool get hasActiveFilters =>
      keyword.isNotEmpty ||
      category != null ||
      minPrice != null ||
      maxPrice != null ||
      sort != ProductSort.newest;
}
