import '../../domain/entities/cart_entity.dart';

sealed class CartState {
  const CartState();
}

final class CartInitial extends CartState {
  const CartInitial();
}

final class CartLoading extends CartState {
  const CartLoading();
}

final class CartLoaded extends CartState {
  final CartEntity cart;

  /// True while a mutation (add/update/remove) is in flight, so the UI can
  /// show a subtle busy state without hiding the current cart.
  final bool isMutating;

  const CartLoaded(this.cart, {this.isMutating = false});
}

final class CartError extends CartState {
  final String message;
  const CartError(this.message);
}
