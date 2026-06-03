import '../../../../core/errors/api_result.dart';
import '../entities/sensors_data_entity.dart';
import '../repos/sensors_repository.dart';

class GetSensorsDataUseCase {
  final SensorsRepository _repository;

  GetSensorsDataUseCase(this._repository);

  Future<ApiResult<SensorsDataEntity>> call() {
    return _repository.getSensorsData();
  }
}
