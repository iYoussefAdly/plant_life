import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repos/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<ApiResult<void>> login({
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (email == 'error@test.com') {
        return const Error(ServerFailure('Invalid email or password'));
      }
      return const Success(null);
    } catch (e) {
      return const Error(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<ApiResult<void>> register({
    required String name,
    required String email,
    required String password,
    required String deviceId,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (email == 'taken@test.com') {
        return const Error(ServerFailure('Email already registered'));
      }
      return const Success(null);
    } catch (e) {
      return const Error(ServerFailure('An unexpected error occurred'));
    }
  }
}
