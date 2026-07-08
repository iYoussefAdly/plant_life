import '../../../../core/errors/api_result.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../domain/entities/scan_result_entity.dart';
import '../../domain/repos/scan_repository.dart';
import '../datasources/scan_data_source.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ScanDataSource _dataSource;

  ScanRepositoryImpl(this._dataSource);

  @override
  Future<ApiResult<ScanResultEntity>> scanImages({
    required List<String> imagePaths,
    required ScanImageSource source,
  }) async {
    try {
      final scan = source == ScanImageSource.camera
          ? await _dataSource.analyzeCameraScan(imagePaths)
          : await _dataSource.createScan(imagePaths);
      return Success(scan);
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<List<ScanResultEntity>>> getScanHistory() async {
    try {
      return Success(await _dataSource.getScans());
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }
}
