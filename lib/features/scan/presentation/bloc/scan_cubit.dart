import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/usecases/get_scan_history_usecase.dart';
import '../../domain/usecases/scan_image_usecase.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  final ScanImageUseCase _scanImageUseCase;
  final GetScanHistoryUseCase _getScanHistoryUseCase;

  ScanCubit(this._scanImageUseCase, this._getScanHistoryUseCase)
      : super(const ScanInitial());

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

  void reset() => emit(const ScanInitial());
}
