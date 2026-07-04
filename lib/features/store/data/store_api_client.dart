import 'package:dio/dio.dart';

import '../../../core/storage/store_token_storage.dart';
import 'store_api_endpoints.dart';

/// Wraps the [Dio] instance configured for the store backend so store data
/// sources depend on a distinct type (rather than the plant-life [Dio]).
class StoreApiClient {
  final Dio dio;
  const StoreApiClient(this.dio);
}

/// Attaches the store bearer token and clears it on an unrecoverable 401 so the
/// session re-provisions on the next app login.
class _StoreAuthInterceptor extends Interceptor {
  final StoreTokenStorage _tokenStorage;

  _StoreAuthInterceptor(this._tokenStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Proceed without the header rather than stall the request.
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      final isAuthCall = err.requestOptions.path.contains('/auth/');
      if (err.response?.statusCode == 401 && !isAuthCall) {
        await _tokenStorage.clear();
      }
    } catch (_) {
      // ignore
    }
    handler.next(err);
  }
}

abstract final class StoreDioFactory {
  static const _timeout = Duration(seconds: 30);

  static StoreApiClient create(StoreTokenStorage tokenStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: StoreApiEndpoints.baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.add(_StoreAuthInterceptor(tokenStorage));
    return StoreApiClient(dio);
  }
}
