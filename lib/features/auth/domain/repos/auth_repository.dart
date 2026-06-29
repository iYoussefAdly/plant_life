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
}
