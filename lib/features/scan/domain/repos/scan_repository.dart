import '../../../../core/errors/api_result.dart';
import '../entities/scan_result_entity.dart';

abstract class ScanRepository {
  Future<ApiResult<ScanResultEntity>> scanImage({
    required String imagePath,
  });

  Future<ApiResult<List<ScanResultEntity>>> getScanHistory();
}
