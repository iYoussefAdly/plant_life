import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/shipping_address.dart';
import '../../domain/usecases/order_usecases.dart';

sealed class CheckoutState {
  const CheckoutState();
}

final class CheckoutIdle extends CheckoutState {
  const CheckoutIdle();
}

final class CheckoutSubmitting extends CheckoutState {
  const CheckoutSubmitting();
}

/// A cash-on-delivery order was placed.
final class CheckoutOrderPlaced extends CheckoutState {
  final OrderEntity order;
  const CheckoutOrderPlaced(this.order);
}

/// A Stripe checkout URL is ready to open in the browser.
final class CheckoutRedirect extends CheckoutState {
  final String url;
  const CheckoutRedirect(this.url);
}

final class CheckoutError extends CheckoutState {
  final String message;
  const CheckoutError(this.message);
}

class CheckoutCubit extends Cubit<CheckoutState> {
  final CreateOrderUseCase _createOrder;
  final CreateCheckoutSessionUseCase _createCheckoutSession;

  CheckoutCubit(this._createOrder, this._createCheckoutSession)
      : super(const CheckoutIdle());

  Future<void> placeCashOrder(ShippingAddress address) async {
    emit(const CheckoutSubmitting());
    final result = await _createOrder(address);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(CheckoutOrderPlaced(data));
      case Error(:final failure):
        emit(CheckoutError(failure.message));
    }
  }

  Future<void> startStripeCheckout(ShippingAddress address) async {
    emit(const CheckoutSubmitting());
    final result = await _createCheckoutSession(address);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(CheckoutRedirect(data));
      case Error(:final failure):
        emit(CheckoutError(failure.message));
    }
  }

  void reset() => emit(const CheckoutIdle());
}
