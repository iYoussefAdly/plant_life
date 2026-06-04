import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/usecases/get_treatment_detail_usecase.dart';
import '../../domain/usecases/toggle_step_usecase.dart';
import 'treatment_detail_state.dart';

class TreatmentDetailCubit extends Cubit<TreatmentDetailState> {
  final GetTreatmentDetailUseCase _getDetailUseCase;
  final ToggleStepUseCase _toggleStepUseCase;

  String _currentPlanId = '';

  TreatmentDetailCubit(this._getDetailUseCase, this._toggleStepUseCase)
      : super(const TreatmentDetailInitial());

  Future<void> loadDetail(String planId) async {
    _currentPlanId = planId;
    emit(const TreatmentDetailLoading());
    final result = await _getDetailUseCase(planId);
    switch (result) {
      case Success(:final data):
        emit(TreatmentDetailSuccess(data));
      case Error(:final failure):
        emit(TreatmentDetailError(failure.message));
    }
  }

  Future<void> retry() => loadDetail(_currentPlanId);

  Future<void> toggleStep({
    required String planId,
    required String stepId,
    required bool isCompleted,
  }) async {
    final result = await _toggleStepUseCase(
      planId: planId,
      stepId: stepId,
      isCompleted: isCompleted,
    );
    switch (result) {
      case Success(:final data):
        emit(TreatmentDetailSuccess(data));
      case Error(:final failure):
        emit(TreatmentDetailError(failure.message));
    }
  }
}
