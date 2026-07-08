import '../../../../core/errors/api_result.dart';
import '../repos/sensors_repository.dart';

/// Registers a sensor Device ID to the account — the required first step of
/// "Connect Device", before the ID is persisted locally or its data is loaded.
class RegisterSensorDeviceUseCase {
  final SensorsRepository _repository;

  RegisterSensorDeviceUseCase(this._repository);

  Future<ApiResult<void>> call(String deviceId) {
    return _repository.registerDevice(deviceId);
  }
}
