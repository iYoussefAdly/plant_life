import '../../../../core/errors/api_result.dart';
import '../entities/recovery_entity.dart';

abstract class RecoveryRepository {
  Future<ApiResult<RecoveryEntity>> getRecoveryProgress(String treatmentId);
}
