import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../../../core/events/app_event.dart';
import '../../../../core/events/app_event_bus.dart';
import '../../domain/usecases/get_treatment_plans_usecase.dart';
import '../../domain/usecases/sync_treatment_reminders_usecase.dart';
import 'treatments_state.dart';

class TreatmentsCubit extends Cubit<TreatmentsState> {
  final GetTreatmentPlansUseCase _getPlansUseCase;
  final AppEventBus _eventBus;
  final SyncTreatmentRemindersUseCase _syncReminders;

  StreamSubscription<TreatmentsChanged>? _treatmentsSub;

  TreatmentsCubit(this._getPlansUseCase, this._eventBus, this._syncReminders)
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
        // Refresh on-device reminders for every plan on each load (active plans
        // get scheduled, completed/cancelled ones cleared) so they stay correct
        // even for plans the user never opens individually.
        for (final plan in data) {
          _syncReminders(plan);
        }
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
