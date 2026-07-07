import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../../../core/events/app_event.dart';
import '../../../../core/events/app_event_bus.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../sensors/domain/entities/sensor_notification_entity.dart';
import '../../../sensors/domain/usecases/get_sensor_notification_feed_usecase.dart';
import '../../../sensors/domain/usecases/mark_all_sensor_notifications_read_usecase.dart';
import '../../../sensors/domain/usecases/mark_sensor_notification_read_usecase.dart';
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
  // Sensor alerts (merged into this single, global center).
  final GetSensorNotificationFeedUseCase _getSensorFeedUseCase;
  final MarkSensorNotificationReadUseCase _markSensorReadUseCase;
  final MarkAllSensorNotificationsReadUseCase _markAllSensorReadUseCase;
  final AppPreferences _prefs;
  final AppEventBus _eventBus;

  StreamSubscription<NotificationEntity>? _liveSub;
  StreamSubscription<TreatmentsChanged>? _treatmentsSub;
  StreamSubscription<SensorDeviceChanged>? _sensorDeviceSub;

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
    this._getSensorFeedUseCase,
    this._markSensorReadUseCase,
    this._markAllSensorReadUseCase,
    this._prefs,
    this._eventBus,
  ) : super(const NotificationsInitial()) {
    // Live server-pushed notifications. onError keeps the subscription alive.
    _liveSub =
        _watchNewNotificationsUseCase().listen(_onIncoming, onError: (_) {});
    // Re-derive today's reminders whenever treatment data changes.
    _treatmentsSub = _eventBus.on<TreatmentsChanged>().listen((_) {
      if (!isClosed) loadNotifications(silent: true);
    });
    // Pull (or drop) sensor alerts when the device is connected/changed.
    _sensorDeviceSub = _eventBus.on<SensorDeviceChanged>().listen((_) {
      if (!isClosed) loadNotifications(silent: true);
    });
  }

  /// Maps a sensor backend alert into a unified [NotificationEntity]. Tapping it
  /// opens the Sensors screen (handled by the notifications screen), and its
  /// read-state is routed back to the sensor backend via [isSensor].
  NotificationEntity _fromSensor(SensorNotificationEntity s) =>
      NotificationEntity(
        id: s.id,
        type: NotificationType.sensorWarning,
        title: s.title,
        message: s.message,
        timestamp: s.timestamp,
        isRead: s.isRead,
        isSensor: true,
      );

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
    if (currentState is NotificationsLoading) return;
    loadNotifications();
  }

  /// Marks every notification as read across all sources — optimistic (badge
  /// clears instantly), resynced from the servers if any backend rejects it.
  Future<void> markAllAsRead() async {
    final currentState = state;
    if (currentState is! NotificationsLoaded || currentState.unreadCount == 0) {
      return;
    }

    final newlyReadLocal = currentState.notifications
        .where((n) => n.isLocal && !_locallyReadIds.contains(n.id))
        .map((n) => n.id)
        .toList();
    _locallyReadIds.addAll(newlyReadLocal);

    final hasBackendUnread =
        currentState.notifications.any((n) => !n.isLocal && !n.isSensor && !n.isRead);
    final hasSensorUnread =
        currentState.notifications.any((n) => n.isSensor && !n.isRead);

    emit(NotificationsLoaded(
      notifications: currentState.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList(),
      unreadCount: 0,
    ));

    final backendResult =
        hasBackendUnread ? await _markAllNotificationsReadUseCase() : null;
    final sensorResult =
        hasSensorUnread ? await _markAllSensorReadUseCase() : null;
    if (isClosed) return;
    if (backendResult is Error || sensorResult is Error) {
      // Resync from the servers to reflect whatever actually succeeded.
      _locallyReadIds.removeAll(newlyReadLocal);
      await loadNotifications(silent: true);
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
    _sensorDeviceSub?.cancel();
    return super.close();
  }

  Future<void> loadNotifications({bool silent = false}) async {
    if (!silent) emit(const NotificationsLoading());
    final result = await _getNotificationsUseCase();
    if (isClosed) return;

    // Derive today's reminders + fetch sensor alerts regardless of the backend
    // result so they still appear even if the notifications endpoint is down.
    final reminders = await _getTreatmentRemindersUseCase();
    if (isClosed) return;
    final feed = await _getSensorFeedUseCase(_prefs.sensorDeviceId);
    if (isClosed) return;
    final sensors = feed.notifications.map(_fromSensor).toList();
    final sensorUnreadLocal = sensors.where((n) => !n.isRead).length;
    final sensorUnread =
        feed.unreadCount > sensorUnreadLocal ? feed.unreadCount : sensorUnreadLocal;

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
        final merged =
            _merge(backend: data, reminders: reminders, sensors: sensors);
        final localUnread =
            merged.where((n) => n.isLocal && !n.isRead).length;
        emit(NotificationsLoaded(
          notifications: merged,
          unreadCount: backendUnread + localUnread + sensorUnread,
        ));
      case Error(:final failure):
        // Main backend unavailable — still surface reminders + sensor alerts;
        // only error out if there is genuinely nothing to show.
        final applicable = _applyLocalRead(reminders);
        final combined = [...applicable, ...sensors]
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        if (combined.isEmpty) {
          emit(NotificationsError(failure.message));
        } else {
          final localUnread =
              applicable.where((n) => n.isLocal && !n.isRead).length;
          emit(NotificationsLoaded(
            notifications: combined,
            unreadCount: localUnread + sensorUnread,
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
    final match = matches.first;

    final wasUnread = match.isRead == false;
    final updated = currentState.notifications
        .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
        .toList();
    final unread = wasUnread
        ? (currentState.unreadCount - 1).clamp(0, currentState.unreadCount)
        : currentState.unreadCount;
    emit(NotificationsLoaded(notifications: updated, unreadCount: unread));

    if (match.isLocal) {
      // Derived reminder — dismiss locally, no server round-trip.
      _locallyReadIds.add(notificationId);
      return;
    }

    // Route the read to the owning backend.
    final result = match.isSensor
        ? await _markSensorReadUseCase(notificationId)
        : await _markNotificationReadUseCase(notificationId);
    // Revert the optimistic update if the server rejected it.
    if (result is Error && !isClosed) emit(currentState);
  }

  /// Merges backend notifications, derived reminders, and sensor alerts into one
  /// list. Reminders the backend already covers are dropped; local read-state is
  /// applied to reminders. Sorted newest first.
  List<NotificationEntity> _merge({
    required List<NotificationEntity> backend,
    required List<NotificationEntity> reminders,
    required List<NotificationEntity> sensors,
  }) {
    final applicable = _applyLocalRead(
      reminders.where((r) => !backend.any((b) => _isCoveredBy(r, b))).toList(),
    );
    return [...backend, ...applicable, ...sensors]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<NotificationEntity> _applyLocalRead(List<NotificationEntity> reminders) =>
      reminders
          .map((r) => r.copyWith(isRead: _locallyReadIds.contains(r.id)))
          .toList();

  /// True when real backend notification [backend] already covers derived
  /// [reminder], so the reminder should be suppressed to avoid a duplicate.
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
