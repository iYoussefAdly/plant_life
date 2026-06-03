import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../repos/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<ApiResult<void>> call({
    required String name,
    required String email,
    required String password,
    required String deviceId,
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
    return _repository.register(
      name: name,
      email: email,
      password: password,
      deviceId: deviceId,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
