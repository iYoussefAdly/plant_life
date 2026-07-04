import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/usecases/cart_usecases.dart';
import 'cart_state.dart';

/// Shared (singleton) cart. Every store screen and the cart badge read this one
/// instance, so any change (add/update/remove/clear) reflects everywhere with
/// no manual refresh.
class CartCubit extends Cubit<CartState> {
  final GetCartUseCase _getCart;
  final AddToCartUseCase _addToCart;
  final UpdateCartItemUseCase _updateItem;
  final RemoveCartItemUseCase _removeItem;
  final ClearCartUseCase _clearCart;

  CartCubit(
    this._getCart,
    this._addToCart,
    this._updateItem,
    this._removeItem,
    this._clearCart,
  ) : super(const CartInitial());

  int get itemCount {
    final s = state;
    return s is CartLoaded ? s.cart.totalQuantity : 0;
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(const CartLoading());
    final result = await _getCart();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(CartLoaded(data));
      case Error(:final failure):
        if (!silent) emit(CartError(failure.message));
    }
  }

  /// Returns null on success, or an error message on failure (so callers can
  /// show a snackbar). The cart state is updated on success.
  Future<String?> addToCart(String productId, {int quantity = 1}) =>
      _mutate(() => _addToCart(productId, quantity));

  Future<String?> updateQuantity(String productId, int quantity) {
    if (quantity <= 0) return removeItem(productId);
    return _mutate(() => _updateItem(productId, quantity));
  }

  Future<String?> removeItem(String productId) =>
      _mutate(() => _removeItem(productId));

  Future<String?> clear() => _mutate(() => _clearCart());

  Future<String?> _mutate(
    Future<ApiResult<CartEntity>> Function() action,
  ) async {
    final current = state;
    if (current is CartLoaded) emit(CartLoaded(current.cart, isMutating: true));
    final result = await action();
    if (isClosed) return null;
    switch (result) {
      case Success(:final data):
        emit(CartLoaded(data));
        return null;
      case Error(:final failure):
        if (current is CartLoaded) emit(CartLoaded(current.cart));
        return failure.message;
    }
  }

  /// Clears local cart state on logout.
  void reset() => emit(const CartInitial());
}
