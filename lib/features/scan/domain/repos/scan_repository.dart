import '../../../../core/errors/api_result.dart';
import '../entities/scan_result_entity.dart';

abstract class ScanRepository {
  /// Analyzes one or more images. Camera captures go to the AI model service;
  /// gallery uploads go to the standard scans endpoint.
  Future<ApiResult<ScanResultEntity>> scanImages({
    required List<String> imagePaths,
    required ScanImageSource source,
  });

  Future<ApiResult<List<ScanResultEntity>>> getScanHistory();
}
