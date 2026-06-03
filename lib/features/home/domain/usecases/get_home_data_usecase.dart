import '../../../../core/errors/api_result.dart';
import '../entities/home_data_entity.dart';
import '../repos/home_repository.dart';

class GetHomeDataUseCase {
  final HomeRepository _repository;

  GetHomeDataUseCase(this._repository);

  Future<ApiResult<HomeDataEntity>> call() {
    return _repository.getHomeData();
  }
}
