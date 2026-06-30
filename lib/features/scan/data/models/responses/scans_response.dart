import 'package:dio/dio.dart';

import '../../../../../core/networking/api_response_parser.dart';
import '../scan_model.dart';

/// Parsed payload of `GET /scans` (the user's scan history).
class ScansResponse {
  final List<ScanModel> scans;

  const ScansResponse({required this.scans});

  factory ScansResponse.fromResponse(Response response) {
    final data = ApiResponseParser.dataMap(response);
    final list = (data['scans'] as List?) ?? const [];
    return ScansResponse(
      scans: list
          .whereType<Map<String, dynamic>>()
          .map(ScanModel.fromJson)
          .where((s) => s.id.isNotEmpty)
          .toList(),
    );
  }
}
