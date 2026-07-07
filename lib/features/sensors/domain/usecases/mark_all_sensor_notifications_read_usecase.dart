import '../../../../core/errors/api_result.dart';
import '../repos/sensors_repository.dart';

class MarkAllSensorNotificationsReadUseCase {
  final SensorsRepository _repository;

  MarkAllSensorNotificationsReadUseCase(this._repository);

  Future<ApiResult<void>> call() {
    return _repository.markAllNotificationsRead();
  }
}
