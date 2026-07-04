import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/store_token_storage.dart';
import '../../domain/repos/store_session_repository.dart';
import '../datasources/store_auth_data_source.dart';
import '../store_response.dart';

class StoreSessionRepositoryImpl implements StoreSessionRepository {
  final StoreAuthDataSource _dataSource;
  final StoreTokenStorage _tokenStorage;

  StoreSessionRepositoryImpl(this._dataSource, this._tokenStorage);

  @override
  Future<ApiResult<void>> provision({
    required String email,
    required String password,
    required String name,
  }) async {
    // Try to log in first; if the store account doesn't exist yet, register it.
    try {
      final token = await _dataSource.login(email: email, password: password);
      if (token.isNotEmpty) {
        await _tokenStorage.saveToken(token);
        return const Success(null);
      }
    } catch (_) {
      // Fall through to registration.
    }

    try {
      final token = await _dataSource.register(
        name: name.trim().isNotEmpty ? name.trim() : email.split('@').first,
        email: email,
        password: password,
      );
      if (token.isNotEmpty) {
        await _tokenStorage.saveToken(token);
        return const Success(null);
      }
      return const Error(ServerFailure('Could not start a store session.'));
    } catch (e) {
      return Error(StoreErrorHandler.handle(e));
    }
  }

  @override
  Future<void> clear() => _tokenStorage.clear();

  @override
  Future<bool> hasSession() => _tokenStorage.hasToken();
}
