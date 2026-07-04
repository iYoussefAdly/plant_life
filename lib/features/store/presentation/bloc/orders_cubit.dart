import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/usecases/order_usecases.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final GetMyOrdersUseCase _getMyOrders;

  OrdersCubit(this._getMyOrders) : super(const OrdersInitial());

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(const OrdersLoading());
    final result = await _getMyOrders();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(OrdersLoaded(data));
      case Error(:final failure):
        if (!silent) emit(OrdersError(failure.message));
    }
  }
}
