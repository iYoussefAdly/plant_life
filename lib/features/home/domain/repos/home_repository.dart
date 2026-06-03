import '../../../../core/errors/api_result.dart';
import '../entities/home_data_entity.dart';

abstract class HomeRepository {
  Future<ApiResult<HomeDataEntity>> getHomeData();
}
