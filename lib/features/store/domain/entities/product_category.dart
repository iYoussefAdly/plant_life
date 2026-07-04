/// The fixed set of store categories (from the API contract).
enum ProductCategory {
  plantDiseaseTreatment('plant-disease-treatment', 'Treatments'),
  plantTools('plant-tools', 'Tools'),
  seeds('seeds', 'Seeds'),
  fertilizers('fertilizers', 'Fertilizers');

  final String apiValue;
  final String label;

  const ProductCategory(this.apiValue, this.label);
}

/// How the product list is sorted (maps to the API `sort` param).
enum ProductSort {
  newest('-createdAt', 'Newest'),
  priceLowToHigh('price', 'Price: Low to High'),
  priceHighToLow('-price', 'Price: High to Low'),
  bestSelling('-soldCount', 'Best Selling');

  final String apiValue;
  final String label;

  const ProductSort(this.apiValue, this.label);
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
