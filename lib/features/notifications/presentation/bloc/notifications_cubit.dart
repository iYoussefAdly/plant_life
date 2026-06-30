import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final GetUnreadCountUseCase _getUnreadCountUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;

  NotificationsCubit(
    this._getNotificationsUseCase,
    this._getUnreadCountUseCase,
    this._markNotificationReadUseCase,
  ) : super(const NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(const NotificationsLoading());
    final result = await _getNotificationsUseCase();
    switch (result) {
      case Success(:final data):
        // Prefer the dedicated unread-count endpoint for the badge; the list
        // is paginated so counting it locally would be inaccurate. Fall back
        // to the loaded page's count if the endpoint call fails.
        final countResult = await _getUnreadCountUseCase();
        final unread = switch (countResult) {
          Success(data: final count) => count,
          Error() => data.where((n) => !n.isRead).length,
        };
        emit(NotificationsLoaded(notifications: data, unreadCount: unread));
      case Error(:final failure):
        emit(NotificationsError(failure.message));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;

    final wasUnread = currentState.notifications
        .any((n) => n.id == notificationId && !n.isRead);
    final updated = currentState.notifications.map((n) {
      if (n.id == notificationId) return n.copyWith(isRead: true);
      return n;
    }).toList();
    final unread = wasUnread
        ? (currentState.unreadCount - 1).clamp(0, currentState.unreadCount)
        : currentState.unreadCount;
    emit(NotificationsLoaded(notifications: updated, unreadCount: unread));

    final result = await _markNotificationReadUseCase(notificationId);
    // Revert the optimistic update if the server rejected it, so the UI does
    // not diverge from server state.
    if (result is Error && !isClosed) emit(currentState);
  }
}
