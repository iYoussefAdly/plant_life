import '../../../../core/errors/api_result.dart';
import '../entities/order_entity.dart';
import '../entities/shipping_address.dart';
import '../repos/orders_repository.dart';

class CreateOrderUseCase {
  final OrdersRepository _repository;
  CreateOrderUseCase(this._repository);
  Future<ApiResult<OrderEntity>> call(ShippingAddress address) =>
      _repository.createOrder(address);
}

class GetMyOrdersUseCase {
  final OrdersRepository _repository;
  GetMyOrdersUseCase(this._repository);
  Future<ApiResult<List<OrderEntity>>> call() => _repository.getMyOrders();
}

class GetOrderUseCase {
  final OrdersRepository _repository;
  GetOrderUseCase(this._repository);
  Future<ApiResult<OrderEntity>> call(String id) => _repository.getOrder(id);
}

class CreateCheckoutSessionUseCase {
  final OrdersRepository _repository;
  CreateCheckoutSessionUseCase(this._repository);
  Future<ApiResult<String>> call(ShippingAddress address) =>
      _repository.createCheckoutSession(address);
}
