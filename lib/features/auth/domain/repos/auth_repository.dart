import '../../../../core/errors/api_result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// The currently signed-in user's profile.
  Future<ApiResult<UserEntity>> getMe();

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
