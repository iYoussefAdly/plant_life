import '../../../../core/errors/api_result.dart';
import '../repos/sensors_repository.dart';

/// Registers the device's FCM token with the backend so it can receive Sensor
/// danger push alerts. Called after login/registration and whenever the token
/// refreshes. Failures are non-fatal (the app still works without push).
class RegisterFcmTokenUseCase {
  final SensorsRepository _repository;

  RegisterFcmTokenUseCase(this._repository);

  Future<ApiResult<void>> call(String token) {
    return _repository.registerFcmToken(token);
  }
}
