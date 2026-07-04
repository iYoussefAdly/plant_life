import 'shipping_address.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled, unknown }

class OrderItemEntity {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? image;

  const OrderItemEntity({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
  });

  double get lineTotal => price * quantity;
}

class OrderEntity {
  final String id;
  final List<OrderItemEntity> items;
  final double itemsPrice;
  final double shippingPrice;
  final double totalPrice;
  final String paymentMethod;
  final OrderStatus status;
  final bool isPaid;
  final DateTime createdAt;
  final ShippingAddress? shippingAddress;

  const OrderEntity({
    required this.id,
    required this.items,
    required this.itemsPrice,
    required this.shippingPrice,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
    required this.isPaid,
    required this.createdAt,
    this.shippingAddress,
  });

  int get totalQuantity => items.fold(0, (s, i) => s + i.quantity);

  bool get isCashOnDelivery => paymentMethod.toLowerCase() == 'cash';
}
