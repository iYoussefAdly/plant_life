import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../../../core/events/app_event.dart';
import '../../../../core/events/app_event_bus.dart';
import '../../../treatments/domain/usecases/create_heal_plan_usecase.dart';
import '../../domain/entities/scan_result_entity.dart';
import '../../domain/usecases/get_scan_history_usecase.dart';
import '../../domain/usecases/scan_image_usecase.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  final ScanImageUseCase _scanImageUseCase;
  final GetScanHistoryUseCase _getScanHistoryUseCase;
  final CreateHealPlanUseCase _createHealPlanUseCase;
  final AppEventBus _eventBus;

  ScanCubit(
    this._scanImageUseCase,
    this._getScanHistoryUseCase,
    this._createHealPlanUseCase,
    this._eventBus,
  ) : super(const ScanInitial());

  Future<void> scanImages(List<String> imagePaths, ScanImageSource source) async {
    emit(const ScanAnalyzing());
    final result =
        await _scanImageUseCase(imagePaths: imagePaths, source: source);
    switch (result) {
      case Success(:final data):
        emit(ScanResultReady(data));
        // A new scan changes scan history — notify any scan-list subscribers.
        _eventBus.emit(const ScansChanged());
      case Error(:final failure):
        emit(ScanError(failure.message));
    }
  }

  Future<void> loadHistory() async {
    emit(const ScanHistoryLoading());
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
    switch (result) {
      case Success(:final data):
        // A new plan means new Today's Tasks + a new plans list entry.
        _eventBus.emit(const TreatmentsChanged());
        return (planId: data.id, error: null);
      case Error(:final failure):
        return (planId: null, error: failure.message);
    }
  }

  void reset() => emit(const ScanInitial());
}
