import '../../domain/entities/order_entity.dart';

sealed class OrdersState {
  const OrdersState();
}

final class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

final class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

final class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  const OrdersLoaded(this.orders);
}

final class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message);
}
