import '../../../../core/errors/api_result.dart';
import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<ApiResult<List<NotificationEntity>>> getNotifications();
  Future<ApiResult<int>> getUnreadCount();
  Future<ApiResult<void>> markAsRead(String notificationId);
}
