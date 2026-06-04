import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/usecases/get_scan_history_usecase.dart';
import '../../domain/usecases/save_reminder_usecase.dart';
import '../../domain/usecases/scan_image_usecase.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  final ScanImageUseCase _scanImageUseCase;
  final GetScanHistoryUseCase _getScanHistoryUseCase;
  final SaveReminderUseCase _saveReminderUseCase;

  ScanCubit(
    this._scanImageUseCase,
    this._getScanHistoryUseCase,
    this._saveReminderUseCase,
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

  Future<bool> saveReminder({
    required String treatmentPlanId,
    required String scanResultId,
    required DateTime scheduledAt,
  }) async {
    final reminder = ReminderEntity(
      id: 'reminder-${DateTime.now().millisecondsSinceEpoch}',
      treatmentPlanId: treatmentPlanId,
      scanResultId: scanResultId,
      scheduledAt: scheduledAt,
    );
    final result = await _saveReminderUseCase(reminder);
    return switch (result) {
      Success() => true,
      Error() => false,
    };
  }

  void reset() => emit(const ScanInitial());
}
