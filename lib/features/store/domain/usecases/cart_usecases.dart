import '../../../../core/errors/api_result.dart';
import '../entities/cart_entity.dart';
import '../repos/cart_repository.dart';

class GetCartUseCase {
  final CartRepository _repository;
  GetCartUseCase(this._repository);
  Future<ApiResult<CartEntity>> call() => _repository.getCart();
}

class AddToCartUseCase {
  final CartRepository _repository;
  AddToCartUseCase(this._repository);
  Future<ApiResult<CartEntity>> call(String productId, int quantity) =>
      _repository.addItem(productId, quantity);
}

class UpdateCartItemUseCase {
  final CartRepository _repository;
  UpdateCartItemUseCase(this._repository);
  Future<ApiResult<CartEntity>> call(String productId, int quantity) =>
      _repository.updateItem(productId, quantity);
}

class RemoveCartItemUseCase {
  final CartRepository _repository;
  RemoveCartItemUseCase(this._repository);
  Future<ApiResult<CartEntity>> call(String productId) =>
      _repository.removeItem(productId);
}

class ClearCartUseCase {
  final CartRepository _repository;
  ClearCartUseCase(this._repository);
  Future<ApiResult<CartEntity>> call() => _repository.clearCart();
}
