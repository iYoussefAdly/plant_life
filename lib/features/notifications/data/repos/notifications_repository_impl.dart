import '../../../../core/errors/api_result.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repos/notifications_repository.dart';
import '../datasources/notifications_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsDataSource _dataSource;

  NotificationsRepositoryImpl(this._dataSource);

  @override
  Future<ApiResult<List<NotificationEntity>>> getNotifications() async {
    try {
      final response = await _dataSource.getNotifications();
      return Success(response.notifications);
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<int>> getUnreadCount() async {
    try {
      final count = await _dataSource.getUnreadCount();
      return Success(count);
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> markAsRead(String notificationId) async {
    try {
      await _dataSource.markAsRead(notificationId);
      return const Success(null);
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> markAllAsRead() async {
    try {
      await _dataSource.markAllAsRead();
      return const Success(null);
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  @override
  Stream<NotificationEntity> watchNewNotifications() => _dataSource.watchNew();
}
