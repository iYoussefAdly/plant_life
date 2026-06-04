import '../../../../core/errors/api_result.dart';
import '../repos/notifications_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationsRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  Future<ApiResult<void>> call(String notificationId) {
    return _repository.markAsRead(notificationId);
  }
}
