import 'product_entity.dart';

class CartItemEntity {
  final ProductEntity product;
  final int quantity;

  const CartItemEntity({required this.product, required this.quantity});

  double get lineTotal => product.effectivePrice * quantity;
}

class CartEntity {
  final List<CartItemEntity> items;

  const CartEntity({required this.items});

  static const empty = CartEntity(items: []);

  bool get isEmpty => items.isEmpty;

  /// Total number of units across all lines (used for the cart badge).
  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.lineTotal);

  int quantityOf(String productId) {
    for (final item in items) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }
}
