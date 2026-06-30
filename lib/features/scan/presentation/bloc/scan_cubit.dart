import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../../treatments/domain/usecases/create_heal_plan_usecase.dart';
import '../../domain/usecases/get_scan_history_usecase.dart';
import '../../domain/usecases/scan_image_usecase.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  final ScanImageUseCase _scanImageUseCase;
  final GetScanHistoryUseCase _getScanHistoryUseCase;
  final CreateHealPlanUseCase _createHealPlanUseCase;

  ScanCubit(
    this._scanImageUseCase,
    this._getScanHistoryUseCase,
    this._createHealPlanUseCase,
  ) : super(const ScanInitial());

  Future<void> scanImage(String imagePath) async {
    emit(const ScanAnalyzing());
    final result = await _scanImageUseCase(imagePath: imagePath);
    switch (result) {
      case Success(:final data):
        emit(ScanResultReady(data));
      case Error(:final failure):
        emit(ScanError(failure.message));
    }
  }

  Future<void> loadHistory() async {
    emit(const ScanAnalyzing());
    final result = await _getScanHistoryUseCase();
    switch (result) {
      case Success(:final data):
        emit(ScanHistoryLoaded(data));
      case Error(:final failure):
        emit(ScanError(failure.message));
    }
  }

  /// Creates a heal plan from a scan. Returns the new plan id on success, or
  /// the failure message so the screen can surface the real backend reason.
  /// The result view stays visible; the screen drives the loader + navigation.
  Future<({String? planId, String? error})> createPlan(String scanId) async {
    final result = await _createHealPlanUseCase(scanId);
    return switch (result) {
      Success(:final data) => (planId: data.id, error: null),
      Error(:final failure) => (planId: null, error: failure.message),
    };
  }

  void reset() => emit(const ScanInitial());
}
