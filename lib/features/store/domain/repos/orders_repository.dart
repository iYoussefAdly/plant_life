import '../../../../core/errors/api_result.dart';
import '../entities/order_entity.dart';
import '../entities/shipping_address.dart';

abstract class OrdersRepository {
  Future<ApiResult<OrderEntity>> createOrder(ShippingAddress address);
  Future<ApiResult<List<OrderEntity>>> getMyOrders();
  Future<ApiResult<OrderEntity>> getOrder(String id);

  /// Returns the Stripe checkout redirect URL.
  Future<ApiResult<String>> createCheckoutSession(ShippingAddress address);
}
