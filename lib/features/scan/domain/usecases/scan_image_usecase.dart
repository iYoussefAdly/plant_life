import '../../../../core/errors/api_result.dart';
import '../entities/scan_result_entity.dart';
import '../repos/scan_repository.dart';

class ScanImageUseCase {
  final ScanRepository _repository;

  ScanImageUseCase(this._repository);

  Future<ApiResult<ScanResultEntity>> call({
    required List<String> imagePaths,
    required ScanImageSource source,
  }) {
    return _repository.scanImages(imagePaths: imagePaths, source: source);
  }
}
