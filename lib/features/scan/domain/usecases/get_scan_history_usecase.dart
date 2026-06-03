import '../../../../core/errors/api_result.dart';
import '../entities/scan_result_entity.dart';
import '../repos/scan_repository.dart';

class GetScanHistoryUseCase {
  final ScanRepository _repository;

  GetScanHistoryUseCase(this._repository);

  Future<ApiResult<List<ScanResultEntity>>> call() {
    return _repository.getScanHistory();
  }
}
