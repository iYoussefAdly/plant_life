import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../../../core/events/app_event.dart';
import '../../../../core/events/app_event_bus.dart';
import '../../../../core/notifications/push_notifications_service.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../domain/usecases/get_sensors_data_usecase.dart';
import '../../domain/usecases/mark_all_sensor_notifications_read_usecase.dart';
import '../../domain/usecases/mark_sensor_notification_read_usecase.dart';
import '../../domain/usecases/register_sensor_device_usecase.dart';
import 'sensors_state.dart';

class SensorsCubit extends Cubit<SensorsState> {
  final GetSensorsDataUseCase _getSensorsData;
  final RegisterSensorDeviceUseCase _registerDevice;
  final MarkSensorNotificationReadUseCase _markRead;
  final MarkAllSensorNotificationsReadUseCase _markAllRead;
  final AppPreferences _prefs;
  final PushNotificationsService _push;
  final AppEventBus _eventBus;

  StreamSubscription<void>? _pushMessageSub;
  StreamSubscription<void>? _pushOpenedSub;

  SensorsCubit(
    this._getSensorsData,
    this._registerDevice,
    this._markRead,
    this._markAllRead,
    this._prefs,
    this._push,
    this._eventBus,
  ) : super(const SensorsInitial()) {
    // A sensor push arriving (or being tapped) while the feature is live means
    // fresh alert data — refresh quietly.
    _pushMessageSub = _push.onForegroundMessage.listen((_) => _refreshOnPush());
    _pushOpenedSub = _push.onOpened.listen((_) => _refreshOnPush());
  }

  String? get deviceId => _prefs.sensorDeviceId;

  void _refreshOnPush() {
    if (_prefs.sensorDeviceId != null) loadSensorsData(silent: true);
  }

  /// Entry point: gate on the Device ID, otherwise load.
  Future<void> init() async {
    if (_prefs.sensorDeviceId == null) {
      emit(const SensorsNeedsDeviceId());
      return;
    }
    await loadSensorsData();
  }

  Future<void> saveDeviceId(String deviceId) async {
    final trimmed = deviceId.trim();
    if (trimmed.isEmpty) return;

    // The device must be registered to the account first. Only on success do
    // we persist it locally and load its data — an unregistered/invalid
    // Device ID must never be treated as connected.
    emit(const SensorsLoading());
    final registerResult = await _registerDevice(trimmed);
    if (isClosed) return;
    if (registerResult case Error(:final failure)) {
      emit(SensorsError(failure.message));
      return;
    }

    await _prefs.setSensorDeviceId(trimmed);
    // Unlock Home's sensor sections + let the notifications center pull alerts.
    _eventBus.emit(const SensorDeviceChanged());
    await loadSensorsData();
  }

  /// Returns to the onboarding gate so the user can enter a different device.
  Future<void> changeDeviceId() async {
    await _prefs.clearSensorDeviceId();
    _eventBus.emit(const SensorDeviceChanged());
    emit(const SensorsNeedsDeviceId());
  }

  /// [silent] refreshes without flashing the loading placeholder (pull-to-
  /// refresh / push-triggered) and keeps current data on a background failure.
  Future<void> loadSensorsData({bool silent = false}) async {
    final id = _prefs.sensorDeviceId;
    if (id == null) {
      emit(const SensorsNeedsDeviceId());
      return;
    }
    if (!silent) emit(const SensorsLoading());
    final result = await _getSensorsData(id);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(SensorsSuccess(data));
      case Error(:final failure):
        if (!silent) emit(SensorsError(failure.message));
    }
  }

  Future<void> markRead(String notificationId) async {
    final current = state;
    if (current is! SensorsSuccess) return;
    final wasUnread = current.data.notifications
        .any((n) => n.id == notificationId && !n.isRead);
    if (!wasUnread) return;

    // Optimistic update.
    final updated = current.data.notifications
        .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
        .toList();
    emit(SensorsSuccess(current.data.copyWith(
      notifications: updated,
      unreadCount: (current.data.unreadCount - 1).clamp(0, 1 << 30),
    )));

    final result = await _markRead(notificationId);
    if (isClosed) return;
    if (result is Error) loadSensorsData(silent: true); // revert
  }

  Future<void> markAllRead() async {
    final current = state;
    if (current is! SensorsSuccess) return;
    if (current.data.unreadCount == 0) return;

    final updated =
        current.data.notifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(SensorsSuccess(
      current.data.copyWith(notifications: updated, unreadCount: 0),
    ));

    final result = await _markAllRead();
    if (isClosed) return;
    if (result is Error) loadSensorsData(silent: true); // revert
  }

  @override
  Future<void> close() {
    _pushMessageSub?.cancel();
    _pushOpenedSub?.cancel();
    return super.close();
  }
}
