import '../../../../core/errors/api_result.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../domain/entities/rescan_entity.dart';
import '../../domain/repos/recovery_repository.dart';
import '../datasources/recovery_data_source.dart';

class RecoveryRepositoryImpl implements RecoveryRepository {
  final RecoveryDataSource _dataSource;

  RecoveryRepositoryImpl(this._dataSource);

  @override
  Future<ApiResult<List<RescanEntity>>> getRescans(String scanId) async {
    try {
      return Success(await _dataSource.getRescans(scanId));
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> createRescan(
    String parentScanId,
    String imagePath,
  ) async {
    try {
      await _dataSource.createRescan(parentScanId, imagePath);
      return const Success(null);
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }
}
