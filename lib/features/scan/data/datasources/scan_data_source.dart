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

  /// Uploads the image to `POST /scans` (multipart, `images` array) and returns
  /// the analysis result.
  Future<ScanModel> createScan(String imagePath) async {
    final filename = imagePath.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'images': [await MultipartFile.fromFile(imagePath, filename: filename)],
    });
    final response = await _dio.post<dynamic>(ApiEndpoints.scans, data: formData);
    return _scanFromResponse(response);
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
