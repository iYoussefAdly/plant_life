import '../../../../core/errors/api_result.dart';
import '../entities/user_entity.dart';
import '../repos/auth_repository.dart';

class GetMeUseCase {
  final AuthRepository _repository;

  GetMeUseCase(this._repository);

  Future<ApiResult<UserEntity>> call() => _repository.getMe();
}
