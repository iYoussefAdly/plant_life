import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    super.subCategory,
    required super.price,
    super.discountPrice,
    required super.stock,
    required super.unit,
    super.brand,
    required super.images,
    super.usageInstructions,
    super.activeIngredient,
    super.storeName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];
    final merchant = json['merchant'];
    return ProductModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      subCategory: json['subCategory'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String? ?? '',
      brand: json['brand'] as String?,
      images: images,
      usageInstructions: json['usageInstructions'] as String?,
      activeIngredient: json['activeIngredient'] as String?,
      storeName:
          merchant is Map<String, dynamic> ? merchant['storeName'] as String? : null,
    );
  }
}
