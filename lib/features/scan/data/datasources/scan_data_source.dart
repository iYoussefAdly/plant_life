import 'package:dio/dio.dart';

import '../../../../core/networking/api_endpoints.dart';
import '../../../../core/networking/api_response_parser.dart';
import '../models/responses/scans_response.dart';
import '../models/scan_model.dart';

/// Remote scans API. Throws [DioException] on failure; the repository maps
/// those to typed failures at the boundary.
class ScanDataSource {
  final Dio _dio;
  const ScanDataSource(this._dio);

  /// Uploads one or more images to `POST /scans` (multipart, `images` field)
  /// and returns the analysis result. Used for the gallery flow.
  Future<ScanModel> createScan(List<String> imagePaths) async {
    final formData = FormData.fromMap({
      'images': await _multipartFiles(imagePaths),
    });
    final response = await _dio.post<dynamic>(ApiEndpoints.scans, data: formData);
    return _scanFromResponse(response);
  }

  /// Analyzes camera captures via the AI model service (`POST /analyze` on a
  /// separate host). Sends the same `images` multipart field plus `source`,
  /// and parses the model's flat response.
  Future<ScanModel> analyzeCameraScan(List<String> imagePaths) async {
    final formData = FormData.fromMap({
      'images': await _multipartFiles(imagePaths),
      'source': 'camera',
    });
    final response = await _dio.post<dynamic>(
      ApiEndpoints.cameraAnalyze,
      data: formData,
    );
    // The model service returns a flat body (no `{success, data}` envelope);
    // tolerate an optional `data` wrapper just in case.
    final body = response.data;
    var map = body is Map<String, dynamic> ? body : const <String, dynamic>{};
    if (!map.containsKey('result') && map['data'] is Map<String, dynamic>) {
      map = map['data'] as Map<String, dynamic>;
    }
    return ScanModel.fromCameraJson(map);
  }

  Future<List<MultipartFile>> _multipartFiles(List<String> imagePaths) async {
    final files = <MultipartFile>[];
    for (final path in imagePaths) {
      final filename = path.split(RegExp(r'[/\\]')).last;
      files.add(await MultipartFile.fromFile(path, filename: filename));
    }
    return files;
  }

  Future<List<ScanModel>> getScans({int page = 1, int limit = 20}) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.scans,
      queryParameters: {'page': page, 'limit': limit},
    );
    return ScansResponse.fromResponse(response).scans;
  }

  ScanModel _scanFromResponse(Response response) {
    final data = ApiResponseParser.dataMap(response);
    final scan = data['scan'];
    return ScanModel.fromJson(scan is Map<String, dynamic> ? scan : data);
  }
}
