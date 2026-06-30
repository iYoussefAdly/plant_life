import '../../../../core/errors/api_result.dart';

abstract class AuthRepository {
  Future<ApiResult<void>> login({
    required String email,
    required String password,
  });

  Future<ApiResult<void>> register({
    required String name,
    required String email,
    required String password,
  });

  /// Clears the persisted session (tokens). No backend call — the API has no
  /// logout endpoint.
  Future<void> logout();
}
