import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_endpoints.dart';

/// Attaches the bearer access token to outgoing requests and transparently
/// refreshes it on a 401.
///
/// Uses [QueuedInterceptor] so concurrent requests that hit a 401 queue behind
/// a single refresh attempt instead of each firing their own. Refresh and retry
/// go through a separate [Dio] ([_refreshDio]) that has no auth interceptor, so
/// there is no recursion. If refresh fails, tokens are cleared and
/// [onUnauthorized] is invoked (wired by the auth layer to redirect to login).
class AuthInterceptor extends QueuedInterceptor {
  final TokenStorage _tokenStorage;
  final Dio _refreshDio;
  final void Function()? onUnauthorized;

  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Dio refreshDio,
    this.onUnauthorized,
  })  : _tokenStorage = tokenStorage,
        _refreshDio = refreshDio;

  static const _retriedFlag = 'auth_retried';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Storage failure — proceed without the auth header rather than stall
      // the QueuedInterceptor (a thrown async error would never complete the
      // handler and would hang every subsequent request).
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // The whole body is guarded so the handler is always completed; an
    // unhandled async throw here would permanently stall the request queue.
    try {
      final isUnauthorized = err.response?.statusCode == 401;
      final alreadyRetried = err.requestOptions.extra[_retriedFlag] == true;
      final isAuthEndpoint = err.requestOptions.path.contains('/auth/');

      if (isUnauthorized && !alreadyRetried && !isAuthEndpoint) {
        if (await _tryRefresh()) {
          // Refresh succeeded — replay the original request once.
          final newToken = await _tokenStorage.getAccessToken();
          final options = err.requestOptions
            ..extra[_retriedFlag] = true
            ..headers['Authorization'] = 'Bearer $newToken';
          final response = await _refreshDio.fetch<dynamic>(options);
          return handler.resolve(response);
        }
        // Refresh failed — the session is no longer valid.
        await _tokenStorage.clear();
        onUnauthorized?.call();
      }
    } on DioException catch (replayError) {
      // Refresh worked but the replay itself failed (e.g. network) — forward
      // the replay error so the caller sees the real reason, and keep tokens.
      return handler.next(replayError);
    } catch (_) {
      // Any other failure (e.g. clearing tokens threw) — fall through and
      // forward the original error below.
    }

    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await _refreshDio.post<dynamic>(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final body = response.data;
      final data = body is Map<String, dynamic> ? body['data'] : null;
      if (data is! Map<String, dynamic>) return false;

      final newAccess = data['accessToken'] as String?;
      final newRefresh = data['refreshToken'] as String?;
      if (newAccess == null || newRefresh == null) return false;

      await _tokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
