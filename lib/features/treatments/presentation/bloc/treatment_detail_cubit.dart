import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../../../core/events/app_event.dart';
import '../../../../core/events/app_event_bus.dart';
import '../../domain/usecases/cancel_plan_usecase.dart';
import '../../domain/usecases/get_treatment_detail_usecase.dart';
import '../../domain/usecases/sync_treatment_reminders_usecase.dart';
import '../../domain/usecases/toggle_step_usecase.dart';
import 'treatment_detail_state.dart';

class TreatmentDetailCubit extends Cubit<TreatmentDetailState> {
  final GetTreatmentDetailUseCase _getDetailUseCase;
  final ToggleStepUseCase _toggleStepUseCase;
  final CancelPlanUseCase _cancelPlanUseCase;
  final AppEventBus _eventBus;
  final SyncTreatmentRemindersUseCase _syncReminders;

  String _currentPlanId = '';

  TreatmentDetailCubit(
    this._getDetailUseCase,
    this._toggleStepUseCase,
    this._cancelPlanUseCase,
    this._eventBus,
    this._syncReminders,
  ) : super(const TreatmentDetailInitial());

  Future<void> loadDetail(String planId) async {
    _currentPlanId = planId;
    emit(const TreatmentDetailLoading());
    final result = await _getDetailUseCase(planId);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(TreatmentDetailSuccess(data));
        // Schedule reminders for this plan's tasks (covers plan creation, which
        // navigates straight here). Fire-and-forget — a scheduling hiccup must
        // not break the screen.
        _syncReminders(data);
      case Error(:final failure):
        emit(TreatmentDetailError(failure.message));
    }
  }

  Future<void> retry() => loadDetail(_currentPlanId);

  /// Cancels the current plan. Returns `null` on success, or the failure
  /// message so the screen can surface it without replacing the detail view.
  Future<String?> cancelPlan() async {
    final current = state;
    if (current is! TreatmentDetailSuccess) return null;

    final result = await _cancelPlanUseCase(current.plan.id);
    if (isClosed) return null;
    switch (result) {
      case Success(:final data):
        emit(TreatmentDetailSuccess(data));
        // A cancelled plan drops out of active lists (Home's Today's Tasks,
        // the plans list) — let them refresh.
        _eventBus.emit(const TreatmentsChanged());
        // Cancel all of this plan's scheduled reminders (syncPlan clears them
        // for any non-active plan).
        _syncReminders(data);
        return null;
      case Error(:final failure):
        return failure.message;
    }
  }

  Future<void> toggleStep({
    required String planId,
    required String stepId,
    required bool isCompleted,
  }) async {
    final current = state;
    if (current is! TreatmentDetailSuccess) return;

    // Future-day tasks stay locked until their scheduled date.
    final match = current.plan.steps.where((s) => s.id == stepId);
    if (match.isNotEmpty && !match.first.isUnlocked) return;

    // Optimistically reflect the toggle so the checkbox responds immediately;
    // confirm with the server's plan on success, or revert on failure (rather
    // than replacing the whole detail view with an error screen).
    emit(TreatmentDetailSuccess(
      current.plan.copyWithStep(stepId, isCompleted: isCompleted),
    ));

    final result = await _toggleStepUseCase(
      planId: planId,
      stepId: stepId,
      isCompleted: isCompleted,
    );
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(TreatmentDetailSuccess(data));
        // Notify other screens (Home's Today's Tasks, the plans list) so they
        // refresh without a manual pull-to-refresh.
        _eventBus.emit(const TreatmentsChanged());
        // Keep reminders in step with completion: a completed task drops its
        // reminders; re-opening one reschedules them.
        _syncReminders(data);
      case Error():
        emit(current);
    }
  }
}
