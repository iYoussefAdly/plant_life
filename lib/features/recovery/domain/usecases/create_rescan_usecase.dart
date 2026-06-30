import '../../../../core/errors/api_result.dart';
import '../repos/recovery_repository.dart';

class CreateRescanUseCase {
  final RecoveryRepository _repository;

  CreateRescanUseCase(this._repository);

  Future<ApiResult<void>> call(String parentScanId, String imagePath) =>
      _repository.createRescan(parentScanId, imagePath);
}
