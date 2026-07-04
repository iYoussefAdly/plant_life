import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/order_usecases.dart';

sealed class OrderDetailsState {
  const OrderDetailsState();
}

final class OrderDetailsLoading extends OrderDetailsState {
  const OrderDetailsLoading();
}

final class OrderDetailsLoaded extends OrderDetailsState {
  final OrderEntity order;
  const OrderDetailsLoaded(this.order);
}

final class OrderDetailsError extends OrderDetailsState {
  final String message;
  const OrderDetailsError(this.message);
}

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  final GetOrderUseCase _getOrder;
  String _id = '';

  OrderDetailsCubit(this._getOrder) : super(const OrderDetailsLoading());

  Future<void> load(String id) async {
    _id = id;
    emit(const OrderDetailsLoading());
    final result = await _getOrder(id);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(OrderDetailsLoaded(data));
      case Error(:final failure):
        emit(OrderDetailsError(failure.message));
    }
  }

  Future<void> retry() => load(_id);
}
