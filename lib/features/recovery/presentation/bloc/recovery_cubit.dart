import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/usecases/get_recovery_progress_usecase.dart';
import 'recovery_state.dart';

class RecoveryCubit extends Cubit<RecoveryState> {
  final GetRecoveryProgressUseCase _getRecoveryUseCase;
  String _currentTreatmentId = '';

  RecoveryCubit(this._getRecoveryUseCase) : super(const RecoveryInitial());

  Future<void> loadRecovery(String treatmentId) async {
    _currentTreatmentId = treatmentId;
    emit(const RecoveryLoading());
    final result = await _getRecoveryUseCase(treatmentId);
    switch (result) {
      case Success(:final data):
        emit(RecoverySuccess(data));
      case Error(:final failure):
        emit(RecoveryError(failure.message));
    }
  }

  Future<void> retry() => loadRecovery(_currentTreatmentId);
}
