import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;

  NotificationsCubit(
    this._getNotificationsUseCase,
    this._markNotificationReadUseCase,
  ) : super(const NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(const NotificationsLoading());
    final result = await _getNotificationsUseCase();
    switch (result) {
      case Success(:final data):
        final unread = data.where((n) => !n.isRead).length;
        emit(NotificationsLoaded(notifications: data, unreadCount: unread));
      case Error(:final failure):
        emit(NotificationsError(failure.message));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;

    final updated = currentState.notifications.map((n) {
      if (n.id == notificationId) return n.copyWith(isRead: true);
      return n;
    }).toList();
    final unread = updated.where((n) => !n.isRead).length;
    emit(NotificationsLoaded(notifications: updated, unreadCount: unread));

    await _markNotificationReadUseCase(notificationId);
  }
}
