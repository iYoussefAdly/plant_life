import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetHomeDataUseCase _getHomeDataUseCase;

  HomeCubit(this._getHomeDataUseCase) : super(const HomeInitial());

  Future<void> loadHomeData() async {
    emit(const HomeLoading());
    final result = await _getHomeDataUseCase();
    switch (result) {
      case Success(:final data):
        emit(HomeSuccess(data));
      case Error(:final failure):
        emit(HomeError(failure.message));
    }
  }
}
