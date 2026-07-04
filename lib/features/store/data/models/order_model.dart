import '../../domain/entities/order_entity.dart';
import '../../domain/entities/shipping_address.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.items,
    required super.itemsPrice,
    required super.shippingPrice,
    required super.totalPrice,
    required super.paymentMethod,
    required super.status,
    required super.isPaid,
    required super.createdAt,
    super.shippingAddress,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['orderItems'] ?? json['items']) as List? ?? const [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(_item)
        .toList();
    final addr = json['shippingAddress'];

    return OrderModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      items: items,
      itemsPrice: (json['itemsPrice'] as num?)?.toDouble() ?? 0,
      shippingPrice: (json['shippingPrice'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      status: _status(json['orderStatus'] as String?),
      isPaid: json['isPaid'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
              DateTime.now(),
      shippingAddress:
          addr is Map<String, dynamic> ? ShippingAddress.fromJson(addr) : null,
    );
  }

  static OrderItemEntity _item(Map<String, dynamic> json) {
    final product = json['product'];
    final productId = product is Map<String, dynamic>
        ? (product['_id'] ?? product['id'] ?? '').toString()
        : (product ?? '').toString();
    String? image = json['image'] as String?;
    if (image == null && product is Map<String, dynamic>) {
      final imgs = (product['images'] as List?)?.whereType<String>().toList();
      if (imgs != null && imgs.isNotEmpty) image = imgs.first;
    }
    return OrderItemEntity(
      productId: productId,
      name: json['name'] as String? ??
          (product is Map<String, dynamic> ? product['name'] as String? : null) ??
          '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      image: image,
    );
  }

  static OrderStatus _status(String? s) {
    switch (s?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
      case 'confirmed':
        return OrderStatus.processing;
      case 'shipped':
      case 'out_for_delivery':
        return OrderStatus.shipped;
      case 'delivered':
      case 'completed':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.unknown;
    }
  }
}
