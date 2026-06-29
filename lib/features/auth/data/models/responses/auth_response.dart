import 'package:dio/dio.dart';

import '../../../../../core/networking/api_response_parser.dart';

/// Parsed payload of the `/auth/login` and `/auth/register` endpoints.
///
/// Only the tokens are modelled today — the app has no screen that consumes
/// the returned user profile yet. A `UserModel`/`UserEntity` can be added when
/// a profile feature needs it (and `GET /auth/me`).
class AuthResponse {
  final String accessToken;
  final String refreshToken;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromResponse(Response response) {
    final data = ApiResponseParser.dataMap(response);
    return AuthResponse(
      accessToken: data['accessToken'] as String? ?? '',
      refreshToken: data['refreshToken'] as String? ?? '',
    );
  }
}
