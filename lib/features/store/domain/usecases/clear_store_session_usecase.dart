import '../repos/store_session_repository.dart';

class ClearStoreSessionUseCase {
  final StoreSessionRepository _repository;
  ClearStoreSessionUseCase(this._repository);

  Future<void> call() => _repository.clear();
}
