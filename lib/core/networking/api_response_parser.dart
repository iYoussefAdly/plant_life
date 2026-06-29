import 'package:dio/dio.dart';

/// Unwraps the standard backend envelope: `{ "success": bool, "data": {...} }`.
///
/// Data sources call these helpers to reach the payload regardless of whether
/// `data` is a JSON object or a list, keeping envelope handling in one place.
abstract final class ApiResponseParser {
  /// Returns the `data` object as a map, or an empty map if absent.
  static Map<String, dynamic> dataMap(Response response) {
    _ensureSuccess(response);
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) return data;
    }
    return const <String, dynamic>{};
  }

  /// Returns the `data` payload as-is (object, list, or scalar), or null.
  static dynamic data(Response response) {
    _ensureSuccess(response);
    final body = response.data;
    if (body is Map<String, dynamic>) return body['data'];
    return null;
  }

  /// Some endpoints return HTTP 200 with `success: false` for business errors.
  /// Surface those as a [DioException] so they flow through [ApiErrorHandler]
  /// instead of silently yielding empty data.
  static void _ensureSuccess(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body['success'] == false) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: body['message'] ?? body['error'],
      );
    }
  }
}
