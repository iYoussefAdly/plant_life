import '../../../../core/errors/api_result.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repos/cart_repository.dart';
import '../datasources/cart_data_source.dart';
import '../store_response.dart';

/// Mutations re-fetch the cart so callers always get the authoritative state
/// (and every screen reading the shared cart cubit stays in sync).
class CartRepositoryImpl implements CartRepository {
  final CartDataSource _dataSource;
  CartRepositoryImpl(this._dataSource);

  @override
  Future<ApiResult<CartEntity>> getCart() => _guard(() => _dataSource.getCart());

  @override
  Future<ApiResult<CartEntity>> addItem(String productId, int quantity) =>
      _guard(() async {
        await _dataSource.addItem(productId, quantity);
        return _dataSource.getCart();
      });

  @override
  Future<ApiResult<CartEntity>> updateItem(String productId, int quantity) =>
      _guard(() async {
        await _dataSource.updateItem(productId, quantity);
        return _dataSource.getCart();
      });

  @override
  Future<ApiResult<CartEntity>> removeItem(String productId) =>
      _guard(() async {
        await _dataSource.removeItem(productId);
        return _dataSource.getCart();
      });

  @override
  Future<ApiResult<CartEntity>> clearCart() => _guard(() async {
        await _dataSource.clearCart();
        return const CartEntity(items: []);
      });

  Future<ApiResult<CartEntity>> _guard(
    Future<CartEntity> Function() action,
  ) async {
    try {
      return Success(await action());
    } catch (e) {
      return Error(StoreErrorHandler.handle(e));
    }
  }
}
