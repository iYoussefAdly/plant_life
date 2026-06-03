import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../repos/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<ApiResult<void>> call({
    required String email,
    required String password,
  }) {
    if (!_isValidEmail(email)) {
      return Future.value(
        const Error(ServerFailure('Please enter a valid email address')),
      );
    }
    if (password.length < 6) {
      return Future.value(
        const Error(ServerFailure('Password must be at least 6 characters')),
      );
    }
    return _repository.login(email: email, password: password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
