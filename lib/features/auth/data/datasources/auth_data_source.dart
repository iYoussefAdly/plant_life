import 'package:dio/dio.dart';

import '../../../../core/networking/api_endpoints.dart';
import '../../../../core/networking/api_response_parser.dart';
import '../models/responses/auth_response.dart';
import '../models/user_model.dart';

/// Remote auth API. Throws [DioException] on failure; the repository maps
/// those to typed failures at the boundary.
class AuthDataSource {
  final Dio _dio;
  const AuthDataSource(this._dio);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return AuthResponse.fromResponse(response);
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.register,
      data: {'name': name, 'email': email, 'password': password},
    );
    return AuthResponse.fromResponse(response);
  }

  /// Fetches the current user's profile (`GET /auth/me`).
  Future<UserModel> getMe() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.me);
    final data = ApiResponseParser.dataMap(response);
    final user = data['user'];
    return UserModel.fromJson(user is Map<String, dynamic> ? user : data);
  }
}
