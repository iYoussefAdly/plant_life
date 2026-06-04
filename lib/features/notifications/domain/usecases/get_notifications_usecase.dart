import '../../../../core/errors/api_result.dart';
import '../entities/notification_entity.dart';
import '../repos/notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository _repository;

  GetNotificationsUseCase(this._repository);

  Future<ApiResult<List<NotificationEntity>>> call() {
    return _repository.getNotifications();
  }
}
