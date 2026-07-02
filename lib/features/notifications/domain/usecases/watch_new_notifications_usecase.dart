import '../entities/notification_entity.dart';
import '../repos/notifications_repository.dart';

class WatchNewNotificationsUseCase {
  final NotificationsRepository _repository;

  WatchNewNotificationsUseCase(this._repository);

  Stream<NotificationEntity> call() => _repository.watchNewNotifications();
}
