import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../../../core/events/app_event.dart';
import '../../../../core/events/app_event_bus.dart';
import '../../domain/usecases/get_treatment_plans_usecase.dart';
import 'treatments_state.dart';

class TreatmentsCubit extends Cubit<TreatmentsState> {
  final GetTreatmentPlansUseCase _getPlansUseCase;
  final AppEventBus _eventBus;

  StreamSubscription<TreatmentsChanged>? _treatmentsSub;

  TreatmentsCubit(this._getPlansUseCase, this._eventBus)
      : super(const TreatmentsInitial()) {
    // Keep the plans list (and its progress) in sync when a task is toggled or
    // a plan is created elsewhere.
    _treatmentsSub =
        _eventBus.on<TreatmentsChanged>().listen((_) => loadPlans(silent: true));
  }

  Future<void> loadPlans({bool silent = false}) async {
    if (!silent) emit(const TreatmentsLoading());
    final result = await _getPlansUseCase();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(TreatmentsSuccess(data));
      case Error(:final failure):
        if (!silent) emit(TreatmentsError(failure.message));
    }
  }

  @override
  Future<void> close() {
    _treatmentsSub?.cancel();
    return super.close();
  }
}
