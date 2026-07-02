import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../../../core/events/app_event.dart';
import '../../../../core/events/app_event_bus.dart';
import '../../domain/entities/recovery_entity.dart';
import '../../domain/entities/rescan_entity.dart';
import '../../domain/usecases/create_rescan_usecase.dart';
import '../../domain/usecases/get_rescans_usecase.dart';
import 'recovery_state.dart';

class RecoveryCubit extends Cubit<RecoveryState> {
  final GetRescansUseCase _getRescansUseCase;
  final CreateRescanUseCase _createRescanUseCase;
  final AppEventBus _eventBus;

  String _scanId = '';
  String _title = '';

  RecoveryCubit(
    this._getRescansUseCase,
    this._createRescanUseCase,
    this._eventBus,
  ) : super(const RecoveryInitial());

  Future<void> load(String scanId, String title) async {
    _scanId = scanId;
    _title = title;
    emit(const RecoveryLoading());

    if (scanId.isEmpty) {
      emit(RecoverySuccess(RecoveryEntity(
        scanId: scanId,
        title: title,
        progressPercent: 0,
        rescans: const [],
      )));
      return;
    }

    final result = await _getRescansUseCase(scanId);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        // Ensure newest-first regardless of API ordering.
        final rescans = [...data]
          ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
        emit(RecoverySuccess(RecoveryEntity(
          scanId: scanId,
          title: title,
          progressPercent: _progress(rescans),
          rescans: rescans,
        )));
      case Error(:final failure):
        emit(RecoveryError(failure.message));
    }
  }

  /// Uploads a follow-up scan, then reloads the timeline.
  Future<void> createRescan(String imagePath) async {
    if (_scanId.isEmpty) {
      emit(const RecoveryError(
        'No scan is linked to this plan, so a rescan cannot be created.',
      ));
      return;
    }
    emit(const RecoveryLoading());
    final result = await _createRescanUseCase(_scanId, imagePath);
    if (isClosed) return;
    switch (result) {
      case Success():
        _eventBus.emit(const ScansChanged());
        await load(_scanId, _title);
      case Error(:final failure):
        emit(RecoveryError(failure.message));
    }
  }

  Future<void> retry() => load(_scanId, _title);

  /// Recovery proxy: the lower the latest rescan's severity, the higher the
  /// recovery. Rescans are returned newest-first.
  double _progress(List<RescanEntity> rescans) {
    if (rescans.isEmpty) return 0;
    final latest = rescans.first.severityPercent;
    return ((100 - latest) / 100).clamp(0.0, 1.0);
  }
}
