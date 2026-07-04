import '../store_api_client.dart';
import '../store_api_endpoints.dart';

/// Auth against the store backend. The token is returned at the top level
/// (`{ status, token, data: { user } }`).
class StoreAuthDataSource {
  final StoreApiClient _client;
  const StoreAuthDataSource(this._client);

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post<dynamic>(
      StoreApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return _token(response.data);
  }

  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post<dynamic>(
      StoreApiEndpoints.register,
      data: {'name': name, 'email': email, 'password': password},
    );
    return _token(response.data);
  }

  String _token(dynamic body) {
    if (body is Map<String, dynamic>) {
      final token = body['token'];
      if (token is String && token.isNotEmpty) return token;
    }
    return '';
  }
}
