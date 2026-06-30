import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/repos/auth_repository.dart';
import '../datasources/auth_data_source.dart';
import '../models/responses/auth_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl(this._dataSource, this._tokenStorage);

  @override
  Future<ApiResult<void>> login({
    required String email,
    required String password,
  }) async {
    try {
      final auth = await _dataSource.login(email: email, password: password);
      return _persistTokens(auth);
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final auth = await _dataSource.register(
        name: name,
        email: email,
        password: password,
      );
      return _persistTokens(auth);
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<void> logout() => _tokenStorage.clear();

  /// Persists the tokens from a nominally successful auth call. If the server
  /// returned no usable tokens, surface it as an error rather than silently
  /// succeeding (which would leave the user "logged in" with no credentials).
  Future<ApiResult<void>> _persistTokens(AuthResponse auth) async {
    if (auth.accessToken.isEmpty || auth.refreshToken.isEmpty) {
      return const Error(
        ServerFailure('Invalid server response. Please try again.'),
      );
    }
    await _tokenStorage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
    );
    return const Success(null);
  }
}
