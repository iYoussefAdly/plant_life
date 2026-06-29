import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_endpoints.dart';
import 'auth_interceptor.dart';

/// Builds the configured [Dio] client used by all feature data sources.
///
/// Creates a separate refresh client (no auth interceptor) so the
/// [AuthInterceptor] can refresh tokens and replay requests without recursing
/// through itself.
abstract final class DioFactory {
  static const _timeout = Duration(seconds: 20);

  static Dio create({
    required TokenStorage tokenStorage,
    void Function()? onUnauthorized,
  }) {
    final baseOptions = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

    final refreshDio = Dio(baseOptions);
    final dio = Dio(baseOptions);
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        refreshDio: refreshDio,
        onUnauthorized: onUnauthorized,
      ),
    );
    return dio;
  }
}
