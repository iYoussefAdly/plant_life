import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/shipping_address.dart';
import '../../domain/repos/orders_repository.dart';
import '../datasources/orders_data_source.dart';
import '../store_response.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersDataSource _dataSource;
  OrdersRepositoryImpl(this._dataSource);

  @override
  Future<ApiResult<OrderEntity>> createOrder(ShippingAddress address) async {
    try {
      return Success(await _dataSource.createOrder(address));
    } catch (e) {
      return Error(StoreErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<List<OrderEntity>>> getMyOrders() async {
    try {
      return Success(await _dataSource.getMyOrders());
    } catch (e) {
      return Error(StoreErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<OrderEntity>> getOrder(String id) async {
    try {
      return Success(await _dataSource.getOrder(id));
    } catch (e) {
      return Error(StoreErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<String>> createCheckoutSession(
    ShippingAddress address,
  ) async {
    try {
      final url = await _dataSource.createCheckoutSession(address);
      if (url.isEmpty) {
        return const Error(ServerFailure('No checkout URL was returned.'));
      }
      return Success(url);
    } catch (e) {
      return Error(StoreErrorHandler.handle(e));
    }
  }
}
