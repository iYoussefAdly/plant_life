import 'package:dio/dio.dart';

import '../../../../core/networking/api_endpoints.dart';
import '../../../../core/networking/api_response_parser.dart';
import '../models/rescan_model.dart';

/// Remote rescan/recovery API. Throws [DioException] on failure; the repository
/// maps those to typed failures at the boundary.
class RecoveryDataSource {
  final Dio _dio;
  const RecoveryDataSource(this._dio);

  Future<List<RescanModel>> getRescans(String scanId) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.scanRescans(scanId));
    final data = ApiResponseParser.dataMap(response);
    final list = (data['rescans'] ?? data['scans']) as List? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(RescanModel.fromJson)
        .where((r) => r.id.isNotEmpty)
        .toList();
  }

  /// Uploads a new follow-up scan (multipart, `images` array) — mirrors
  /// [ScanDataSource.createScan].
  Future<void> createRescan(String parentScanId, String imagePath) async {
    final filename = imagePath.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'images': [await MultipartFile.fromFile(imagePath, filename: filename)],
    });
    final response = await _dio.post<dynamic>(
      ApiEndpoints.rescan(parentScanId),
      data: formData,
    );
    // Surface HTTP 200 + { success: false } business errors.
    ApiResponseParser.data(response);
  }
}
