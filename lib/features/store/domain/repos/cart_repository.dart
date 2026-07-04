import '../../../../core/errors/api_result.dart';
import '../entities/cart_entity.dart';

abstract class CartRepository {
  Future<ApiResult<CartEntity>> getCart();
  Future<ApiResult<CartEntity>> addItem(String productId, int quantity);
  Future<ApiResult<CartEntity>> updateItem(String productId, int quantity);
  Future<ApiResult<CartEntity>> removeItem(String productId);
  Future<ApiResult<CartEntity>> clearCart();
}
