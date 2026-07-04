import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../../../core/events/app_event.dart';
import '../../../../core/events/app_event_bus.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/get_treatment_reminders_usecase.dart';
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
  final GetTreatmentRemindersUseCase _getTreatmentRemindersUseCase;
  final AppEventBus _eventBus;

  StreamSubscription<NotificationEntity>? _liveSub;
  StreamSubscription<TreatmentsChanged>? _treatmentsSub;

  /// Ids of locally-derived reminders the user has dismissed (marked read).
  /// Session-scoped: a reminder disappears for good once its task is completed,
  /// so persistence across restarts isn't required.
  final Set<String> _locallyReadIds = {};

  NotificationsCubit(
    this._getNotificationsUseCase,
    this._getUnreadCountUseCase,
    this._markNotificationReadUseCase,
    this._markAllNotificationsReadUseCase,
    this._watchNewNotificationsUseCase,
    this._getTreatmentRemindersUseCase,
    this._eventBus,
  ) : super(const NotificationsInitial()) {
    // Listen for notifications pushed live by the server. onError keeps the
    // subscription alive if the stream ever surfaces an error.
    _liveSub =
        _watchNewNotificationsUseCase().listen(_onIncoming, onError: (_) {});
    // Re-derive today's reminders whenever treatment data changes (a task
    // completed elsewhere should drop its reminder; a new plan should add them).
    _treatmentsSub = _eventBus.on<TreatmentsChanged>().listen((_) {
      if (!isClosed) loadNotifications(silent: true);
    });
  }

  /// Handles a notification pushed live by the server: prepend it, drop any
  /// derived reminder it now duplicates (same plan, same day), and bump the
  /// unread badge. If the list isn't loaded yet, fetch it.
  void _onIncoming(NotificationEntity notification) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      if (currentState.notifications.any((n) => n.id == notification.id)) return;
      final deduped = currentState.notifications
          .where((n) => !_isCoveredBy(n, notification))
          .toList();
      final droppedUnread = currentState.notifications
          .where((n) => _isCoveredBy(n, notification) && !n.isRead)
          .length;
      final delta = (notification.isRead ? 0 : 1) - droppedUnread;
      emit(NotificationsLoaded(
        notifications: [notification, ...deduped],
        unreadCount:
            (currentState.unreadCount + delta).clamp(0, 1 << 30).toInt(),
      ));
      return;
    }
    // Avoid a reload storm if events arrive while a load is already running.
    if (currentState is NotificationsLoading) return;
    loadNotifications();
  }

  /// Marks every notification as read — optimistic (badge clears instantly),
  /// reverted if the server rejects the request. Derived reminders are dismissed
  /// locally; backend notifications go through the server.
  Future<void> markAllAsRead() async {
    final currentState = state;
    if (currentState is! NotificationsLoaded || currentState.unreadCount == 0) {
      return;
    }

    // Dismiss local reminders optimistically, tracking which ids we added so we
    // can undo them if the backend call fails.
    final newlyReadLocal = currentState.notifications
        .where((n) => n.isLocal && !_locallyReadIds.contains(n.id))
        .map((n) => n.id)
        .toList();
    _locallyReadIds.addAll(newlyReadLocal);

    emit(NotificationsLoaded(
      notifications: currentState.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList(),
      unreadCount: 0,
    ));

    final result = await _markAllNotificationsReadUseCase();
    if (result is Error && !isClosed) {
      _locallyReadIds.removeAll(newlyReadLocal);
      emit(currentState);
    }
  }

  /// Clears loaded notifications and local read-state (called on logout so the
  /// next session never sees the previous user's data or badge).
  void reset() {
    _locallyReadIds.clear();
    emit(const NotificationsInitial());
  }

  @override
  Future<void> close() {
    _liveSub?.cancel();
    _treatmentsSub?.cancel();
    return super.close();
  }

  Future<void> loadNotifications({bool silent = false}) async {
    if (!silent) emit(const NotificationsLoading());
    final result = await _getNotificationsUseCase();
    if (isClosed) return;

    // Derive today's reminders regardless of the backend result so they still
    // appear even if the notifications endpoint is unavailable.
    final reminders = await _getTreatmentRemindersUseCase();
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        // The dedicated unread-count endpoint is authoritative for backend
        // items (the list is paginated); the loaded page is a lower bound.
        final backendUnreadLocal = data.where((n) => !n.isRead).length;
        final countResult = await _getUnreadCountUseCase();
        if (isClosed) return;
        final backendUnread = switch (countResult) {
          Success(data: final count) =>
            count > backendUnreadLocal ? count : backendUnreadLocal,
          Error() => backendUnreadLocal,
        };
        final merged = _merge(backend: data, reminders: reminders);
        final localUnread =
            merged.where((n) => n.isLocal && !n.isRead).length;
        emit(NotificationsLoaded(
          notifications: merged,
          unreadCount: backendUnread + localUnread,
        ));
      case Error(:final failure):
        // Backend unavailable — still surface local reminders so the user sees
        // today's tasks; only error out if there are none to show.
        if (reminders.isEmpty) {
          emit(NotificationsError(failure.message));
        } else {
          final applied = _applyLocalRead(reminders)
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          emit(NotificationsLoaded(
            notifications: applied,
            unreadCount: applied.where((n) => !n.isRead).length,
          ));
        }
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;

    final matches =
        currentState.notifications.where((n) => n.id == notificationId);
    if (matches.isEmpty) return;
    final isLocal = matches.first.isLocal;

    final wasUnread = matches.first.isRead == false;
    final updated = currentState.notifications
        .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
        .toList();
    final unread = wasUnread
        ? (currentState.unreadCount - 1).clamp(0, currentState.unreadCount)
        : currentState.unreadCount;
    emit(NotificationsLoaded(notifications: updated, unreadCount: unread));

    if (isLocal) {
      // Derived reminder — dismiss locally, no server round-trip.
      _locallyReadIds.add(notificationId);
      return;
    }

    final result = await _markNotificationReadUseCase(notificationId);
    // Revert the optimistic update if the server rejected it.
    if (result is Error && !isClosed) emit(currentState);
  }

  /// Merges backend notifications with derived reminders, dropping any reminder
  /// the backend already covers (same plan, same day) and applying local
  /// read-state. Sorted newest first.
  List<NotificationEntity> _merge({
    required List<NotificationEntity> backend,
    required List<NotificationEntity> reminders,
  }) {
    final applicable = _applyLocalRead(
      reminders.where((r) => !backend.any((b) => _isCoveredBy(r, b))).toList(),
    );
    return [...backend, ...applicable]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<NotificationEntity> _applyLocalRead(List<NotificationEntity> reminders) =>
      reminders
          .map((r) => r.copyWith(isRead: _locallyReadIds.contains(r.id)))
          .toList();

  /// True when real backend notification [backend] already covers derived
  /// [reminder], so the reminder should be suppressed to avoid a duplicate.
  ///
  /// Backend notifications carry no task index, only a plan (`relatedId`). We
  /// therefore match on plan + same calendar day AND on the task text (the
  /// reminder's message is the task title): this suppresses only the *same*
  /// task rather than every task in that plan on that day, so a backend reminder
  /// for one task can't hide the other tasks still due the same day.
  bool _isCoveredBy(NotificationEntity reminder, NotificationEntity backend) {
    if (!reminder.isLocal || backend.isLocal) return false;
    if (backend.relatedId == null ||
        backend.relatedId != reminder.relatedId) {
      return false;
    }
    if (!_isSameDay(backend.timestamp, reminder.timestamp)) return false;
    final task = reminder.message.trim().toLowerCase();
    if (task.isEmpty) return false;
    final backendText = '${backend.title} ${backend.message}'.toLowerCase();
    return backendText.contains(task);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
