import 'package:dio/dio.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/entities/shipping_address.dart';
import '../models/order_model.dart';
import '../store_api_client.dart';
import '../store_api_endpoints.dart';
import '../store_response.dart';

class OrdersDataSource {
  final StoreApiClient _client;
  const OrdersDataSource(this._client);

  /// Creates a cash-on-delivery order from the current cart.
  Future<OrderEntity> createOrder(ShippingAddress address) async {
    final response = await _client.dio.post<dynamic>(
      StoreApiEndpoints.orders,
      data: {'shippingAddress': address.toJson()},
    );
    return _order(response);
  }

  Future<List<OrderEntity>> getMyOrders() async {
    final response =
        await _client.dio.get<dynamic>(StoreApiEndpoints.myOrders);
    final body = response.data as Map<String, dynamic>? ?? const {};
    final data = body['data'];
    final rawList = data is Map<String, dynamic>
        ? (data['orders'] as List? ?? const [])
        : (data is List ? data : (body['orders'] as List? ?? const []));
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(OrderModel.fromJson)
        .where((o) => o.id.isNotEmpty)
        .toList();
  }

  Future<OrderEntity> getOrder(String id) async {
    final response = await _client.dio.get<dynamic>(StoreApiEndpoints.order(id));
    return _order(response);
  }

  /// Creates a Stripe checkout session and returns the redirect URL.
  Future<String> createCheckoutSession(ShippingAddress address) async {
    final response = await _client.dio.post<dynamic>(
      StoreApiEndpoints.checkoutSession,
      data: {'shippingAddress': address.toJson()},
    );
    final data = StoreResponse.dataMap(response);
    return data['url'] as String? ?? '';
  }

  OrderEntity _order(Response response) {
    final data = StoreResponse.dataMap(response);
    final order = data['order'];
    return OrderModel.fromJson(order is Map<String, dynamic> ? order : data);
  }
}
