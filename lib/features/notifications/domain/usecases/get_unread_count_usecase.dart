import '../../../../core/errors/api_result.dart';
import '../repos/notifications_repository.dart';

class GetUnreadCountUseCase {
  final NotificationsRepository _repository;

  GetUnreadCountUseCase(this._repository);

  Future<ApiResult<int>> call() => _repository.getUnreadCount();
}
