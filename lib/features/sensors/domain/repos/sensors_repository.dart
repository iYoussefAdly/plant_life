import '../../../../core/errors/api_result.dart';
import '../entities/sensors_data_entity.dart';

abstract class SensorsRepository {
  Future<ApiResult<SensorsDataEntity>> getSensorsData();
}
