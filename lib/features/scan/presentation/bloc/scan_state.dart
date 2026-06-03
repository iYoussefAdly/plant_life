import '../../domain/entities/scan_result_entity.dart';

sealed class ScanState {
  const ScanState();
}

final class ScanInitial extends ScanState {
  const ScanInitial();
}

final class ScanAnalyzing extends ScanState {
  const ScanAnalyzing();
}

final class ScanResultReady extends ScanState {
  final ScanResultEntity result;
  const ScanResultReady(this.result);
}

final class ScanHistoryLoaded extends ScanState {
  final List<ScanResultEntity> history;
  const ScanHistoryLoaded(this.history);
}

final class ScanError extends ScanState {
  final String message;
  const ScanError(this.message);
}
