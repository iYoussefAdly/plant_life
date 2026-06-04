import '../../../../core/errors/api_result.dart';
import '../entities/recovery_entity.dart';
import '../repos/recovery_repository.dart';

class GetRecoveryProgressUseCase {
  final RecoveryRepository _repository;

  GetRecoveryProgressUseCase(this._repository);

  Future<ApiResult<RecoveryEntity>> call(String treatmentId) {
    return _repository.getRecoveryProgress(treatmentId);
  }
}
