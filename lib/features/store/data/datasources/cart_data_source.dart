import '../../domain/entities/cart_entity.dart';
import '../models/cart_model.dart';
import '../store_api_client.dart';
import '../store_api_endpoints.dart';
import '../store_response.dart';

class CartDataSource {
  final StoreApiClient _client;
  const CartDataSource(this._client);

  Future<CartEntity> getCart() async {
    final response = await _client.dio.get<dynamic>(StoreApiEndpoints.cart);
    return CartModel.fromResponse(response);
  }

  Future<void> addItem(String productId, int quantity) async {
    final response = await _client.dio.post<dynamic>(
      StoreApiEndpoints.cart,
      data: {'productId': productId, 'quantity': quantity},
    );
    StoreResponse.dataMap(response);
  }

  Future<void> updateItem(String productId, int quantity) async {
    final response = await _client.dio.patch<dynamic>(
      StoreApiEndpoints.cartItem(productId),
      data: {'quantity': quantity},
    );
    StoreResponse.dataMap(response);
  }

  Future<void> removeItem(String productId) async {
    final response = await _client.dio
        .delete<dynamic>(StoreApiEndpoints.cartItem(productId));
    StoreResponse.dataMap(response);
  }

  Future<void> clearCart() async {
    final response =
        await _client.dio.delete<dynamic>(StoreApiEndpoints.cart);
    StoreResponse.dataMap(response);
  }
}
