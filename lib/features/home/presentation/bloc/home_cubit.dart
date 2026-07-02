import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../../../core/events/app_event.dart';
import '../../../../core/events/app_event_bus.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetHomeDataUseCase _getHomeDataUseCase;
  final AppEventBus _eventBus;

  StreamSubscription<TreatmentsChanged>? _treatmentsSub;

  HomeCubit(this._getHomeDataUseCase, this._eventBus)
      : super(const HomeInitial()) {
    // Today's Tasks come from the active heal plan(s), so refresh whenever
    // treatment data changes anywhere in the app (e.g. a task is toggled).
    _treatmentsSub = _eventBus
        .on<TreatmentsChanged>()
        .listen((_) => loadHomeData(silent: true));
  }

  Future<void> loadHomeData({bool silent = false}) async {
    if (!silent) emit(const HomeLoading());
    final result = await _getHomeDataUseCase();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(HomeSuccess(data));
      case Error(:final failure):
        // On a background refresh, keep the current data rather than replacing
        // it with an error screen.
        if (!silent) emit(HomeError(failure.message));
    }
  }

  @override
  Future<void> close() {
    _treatmentsSub?.cancel();
    return super.close();
  }
}
