import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/usecases/get_treatment_plans_usecase.dart';
import 'treatments_state.dart';

class TreatmentsCubit extends Cubit<TreatmentsState> {
  final GetTreatmentPlansUseCase _getPlansUseCase;

  TreatmentsCubit(this._getPlansUseCase) : super(const TreatmentsInitial());

  Future<void> loadPlans() async {
    emit(const TreatmentsLoading());
    final result = await _getPlansUseCase();
    switch (result) {
      case Success(:final data):
        emit(TreatmentsSuccess(data));
      case Error(:final failure):
        emit(TreatmentsError(failure.message));
    }
  }
}
