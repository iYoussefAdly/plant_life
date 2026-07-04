class ProductEntity {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? subCategory;
  final double price;

  /// Discounted price when the product is on offer (less than [price]).
  final double? discountPrice;
  final int stock;
  final String unit;
  final String? brand;
  final List<String> images;
  final String? usageInstructions;
  final String? activeIngredient;
  final String? storeName;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.subCategory,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.unit,
    this.brand,
    required this.images,
    this.usageInstructions,
    this.activeIngredient,
    this.storeName,
  });

  bool get inStock => stock > 0;

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  /// The price the customer actually pays.
  double get effectivePrice => hasDiscount ? discountPrice! : price;

  String? get imageUrl => images.isNotEmpty ? images.first : null;
}
