import 'package:dio/dio.dart';

import '../../../core/errors/failure.dart';

/// Helpers for the store envelope `{ status: "success"|"fail"|"error",
/// message?, data: {...} }`.
abstract final class StoreResponse {
  /// Returns the `data` object, throwing a [DioException] when the backend
  /// reports a non-success status (so it flows through [StoreErrorHandler]).
  static Map<String, dynamic> dataMap(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      if (body['status'] != null && body['status'] != 'success') {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: body['message'],
        );
      }
      final data = body['data'];
      if (data is Map<String, dynamic>) return data;
      return body;
    }
    return const {};
  }
}

/// Maps store networking errors to the app's typed [Failure]s, reusing the same
/// contract as the plant-life layer.
abstract final class StoreErrorHandler {
  static Failure handle(Object error) {
    if (error is DioException) return _handleDio(error);
    return const ServerFailure('An unexpected error occurred');
  }

  static Failure _handleDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const NetworkFailure('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection.');
      case DioExceptionType.cancel:
        return const NetworkFailure('Request was cancelled.');
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const NetworkFailure('Something went wrong. Please try again.');
      case DioExceptionType.badResponse:
        return ServerFailure(_message(e));
    }
  }

  static String _message(DioException e) {
    final body = e.response?.data;
    if (body is Map<String, dynamic>) {
      final msg = body['message'] ?? body['error'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    if (e.error is String && (e.error as String).isNotEmpty) {
      return e.error as String;
    }
    return 'Store error (${e.response?.statusCode ?? 'unknown'}).';
  }
}
