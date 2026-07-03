import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/watch_new_notifications_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final GetUnreadCountUseCase _getUnreadCountUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase _markAllNotificationsReadUseCase;
  final WatchNewNotificationsUseCase _watchNewNotificationsUseCase;

  StreamSubscription<NotificationEntity>? _liveSub;

  NotificationsCubit(
    this._getNotificationsUseCase,
    this._getUnreadCountUseCase,
    this._markNotificationReadUseCase,
    this._markAllNotificationsReadUseCase,
    this._watchNewNotificationsUseCase,
  ) : super(const NotificationsInitial()) {
    // Listen for live notifications pushed over the socket. onError keeps the
    // subscription alive if the stream ever surfaces an error.
    _liveSub =
        _watchNewNotificationsUseCase().listen(_onIncoming, onError: (_) {});
  }

  /// Handles a notification pushed live by the server: prepend it and bump the
  /// unread badge, deduping by id. If the list isn't loaded yet, fetch it.
  void _onIncoming(NotificationEntity notification) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      if (currentState.notifications.any((n) => n.id == notification.id)) return;
      emit(NotificationsLoaded(
        notifications: [notification, ...currentState.notifications],
        unreadCount: currentState.unreadCount + (notification.isRead ? 0 : 1),
      ));
      return;
    }
    // Avoid a reload storm if events arrive while a load is already running.
    if (currentState is NotificationsLoading) return;
    loadNotifications();
  }

  /// Marks every notification as read — optimistic (badge clears instantly),
  /// reverted if the server rejects the request.
  Future<void> markAllAsRead() async {
    final currentState = state;
    if (currentState is! NotificationsLoaded || currentState.unreadCount == 0) {
      return;
    }

    emit(NotificationsLoaded(
      notifications: currentState.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList(),
      unreadCount: 0,
    ));

    final result = await _markAllNotificationsReadUseCase();
    if (result is Error && !isClosed) emit(currentState);
  }

  /// Clears loaded notifications (called on logout so the next session never
  /// sees the previous user's data or badge).
  void reset() => emit(const NotificationsInitial());

  @override
  Future<void> close() {
    _liveSub?.cancel();
    return super.close();
  }

  Future<void> loadNotifications() async {
    emit(const NotificationsLoading());
    final result = await _getNotificationsUseCase();
    switch (result) {
      case Success(:final data):
        // The dedicated unread-count endpoint is authoritative (the list is
        // paginated), but the loaded page gives a guaranteed lower bound —
        // taking the larger of the two keeps the badge correct even if the
        // endpoint misreports (e.g. returns 0 while unread items are visible).
        final localUnread = data.where((n) => !n.isRead).length;
        final countResult = await _getUnreadCountUseCase();
        final unread = switch (countResult) {
          Success(data: final count) =>
            count > localUnread ? count : localUnread,
          Error() => localUnread,
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
