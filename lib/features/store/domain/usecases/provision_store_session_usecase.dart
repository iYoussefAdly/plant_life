import '../../../../core/errors/api_result.dart';
import '../repos/store_session_repository.dart';

class ProvisionStoreSessionUseCase {
  final StoreSessionRepository _repository;
  ProvisionStoreSessionUseCase(this._repository);

  Future<ApiResult<void>> call({
    required String email,
    required String password,
    String name = '',
  }) =>
      _repository.provision(email: email, password: password, name: name);
}
