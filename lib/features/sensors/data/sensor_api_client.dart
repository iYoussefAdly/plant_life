import 'package:dio/dio.dart';

import '../../../core/networking/auth_interceptor.dart';
import '../../../core/storage/token_storage.dart';
import 'sensor_api_endpoints.dart';

/// Wraps the [Dio] configured for the sensor backend so sensor data sources
/// depend on a distinct type (rather than the main plant-life [Dio]).
class SensorApiClient {
  final Dio dio;
  const SensorApiClient(this.dio);
}

/// Builds the sensor-backend [Dio]. It reuses the main [TokenStorage] bearer
/// token (same auth realm) via the shared [AuthInterceptor], whose refresh
/// client points at the main API's `/auth/refresh-token`. Refreshed tokens are
/// saved to the same secure storage and the original sensor request is replayed
/// against its own host (each request carries its own `baseUrl`).
abstract final class SensorDioFactory {
  static const _timeout = Duration(seconds: 20);

  static SensorApiClient create({
    required TokenStorage tokenStorage,
    required Dio refreshDio,
    void Function()? onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: SensorApiEndpoints.baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        refreshDio: refreshDio,
        onUnauthorized: onUnauthorized,
      ),
    );
    return SensorApiClient(dio);
  }
}
