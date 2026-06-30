import '../../../../core/errors/api_result.dart';
import '../entities/rescan_entity.dart';

abstract class RecoveryRepository {
  /// The follow-up scans for the given (original) scan.
  Future<ApiResult<List<RescanEntity>>> getRescans(String scanId);

  /// Uploads a new follow-up scan for [parentScanId].
  Future<ApiResult<void>> createRescan(String parentScanId, String imagePath);
}
