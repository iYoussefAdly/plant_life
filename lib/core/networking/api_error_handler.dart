import 'package:dio/dio.dart';

import '../errors/failure.dart';

/// Maps low-level networking exceptions to the app's typed [Failure]s.
///
/// Repository implementations call [handle] from their catch blocks so the
/// domain/presentation layers only ever see [Failure], never [DioException].
abstract final class ApiErrorHandler {
  static Failure handle(Object error) {
    if (error is DioException) return _handleDioException(error);
    return const ServerFailure('An unexpected error occurred');
  }

  static Failure _handleDioException(DioException e) {
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
        return ServerFailure(_messageFromResponse(e.response));
    }
  }

  /// Extracts a human-readable message from the backend error envelope,
  /// falling back to a generic status-coded message.
  static String _messageFromResponse(Response? response) {
    final body = response?.data;
    if (body is Map<String, dynamic>) {
      final message = body['message'] ?? body['error'];
      if (message is String && message.isNotEmpty) return message;
    }
    return 'Server error (${response?.statusCode ?? 'unknown'}).';
  }
}
