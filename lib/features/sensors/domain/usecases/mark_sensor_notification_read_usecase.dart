import '../../../../core/errors/api_result.dart';
import '../repos/sensors_repository.dart';

class MarkSensorNotificationReadUseCase {
  final SensorsRepository _repository;

  MarkSensorNotificationReadUseCase(this._repository);

  Future<ApiResult<void>> call(String notificationId) {
    return _repository.markNotificationRead(notificationId);
  }
}
