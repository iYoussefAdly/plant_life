import 'package:dio/dio.dart';

import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/product_entity.dart';
import 'product_model.dart';
import '../store_response.dart';

/// Parses the cart envelope defensively — the cart may arrive under
/// `data.cart` or directly as `data`, and items under `items`/`cartItems`,
/// with the product either populated (object) or as a bare id.
class CartModel {
  static CartEntity fromResponse(Response response) {
    final data = StoreResponse.dataMap(response);
    final cart = data['cart'];
    final cartMap = cart is Map<String, dynamic> ? cart : data;
    final rawItems =
        (cartMap['items'] ?? cartMap['cartItems'] ?? cartMap['products'])
                as List? ??
            const [];

    final items = <CartItemEntity>[];
    for (final raw in rawItems.whereType<Map<String, dynamic>>()) {
      final product = _product(raw);
      if (product == null || product.id.isEmpty) continue;
      items.add(
        CartItemEntity(
          product: product,
          quantity: (raw['quantity'] as num?)?.toInt() ?? 1,
        ),
      );
    }
    return CartEntity(items: items);
  }

  static ProductEntity? _product(Map<String, dynamic> item) {
    final p = item['product'];
    if (p is Map<String, dynamic>) return ProductModel.fromJson(p);
    // Some backends flatten the product fields onto the item itself.
    if (item['name'] != null || item['_id'] != null || item['price'] != null) {
      return ProductModel.fromJson(item);
    }
    return null;
  }
}
