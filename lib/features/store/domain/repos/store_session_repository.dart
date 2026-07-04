import '../../../../core/errors/api_result.dart';

abstract class StoreSessionRepository {
  /// Ensures a store session exists for these credentials: tries to log in,
  /// and registers if the account doesn't exist yet. Persists the store token.
  Future<ApiResult<void>> provision({
    required String email,
    required String password,
    required String name,
  });

  Future<void> clear();
  Future<bool> hasSession();
}
