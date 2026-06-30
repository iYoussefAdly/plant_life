import '../../../../core/errors/api_result.dart';
import '../entities/rescan_entity.dart';
import '../repos/recovery_repository.dart';

class GetRescansUseCase {
  final RecoveryRepository _repository;

  GetRescansUseCase(this._repository);

  Future<ApiResult<List<RescanEntity>>> call(String scanId) =>
      _repository.getRescans(scanId);
}
