import '../../../../core/errors/api_result.dart';
import '../repos/notifications_repository.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationsRepository _repository;

  MarkAllNotificationsReadUseCase(this._repository);

  Future<ApiResult<void>> call() => _repository.markAllAsRead();
}
