import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Handles taps that arrive in a background isolate (e.g. action buttons). A
/// plain tap just launches the app and is delivered via the foreground stream /
/// [LocalNotificationsService.takeLaunchPayload], so this is intentionally a
/// no-op — it only exists to satisfy the plugin's API.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {}

/// Thin wrapper around `flutter_local_notifications`: initializes the plugin +
/// timezone database, owns the reminder channel, and exposes schedule/cancel
/// plus tap payloads. Higher layers decide *what* to schedule; this only knows
/// *how*. Lives in `core/` as shared infrastructure (like `SocketService`).
class LocalNotificationsService {
  static const _channelId = 'treatment_reminders';
  static const _channelName = 'Treatment reminders';
  static const _channelDescription =
      'Reminders to complete your treatment tasks';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final _tapController = StreamController<String>.broadcast();

  /// Payloads from reminders tapped while the app is running.
  Stream<String> get onTap => _tapController.stream;

  bool _ready = false;
  String? _launchPayload;

  Future<void> init() async {
    if (_ready) return;
    // Best-effort: notifications are non-critical, so any platform/plugin
    // failure (e.g. an unsupported host in tests) must not stop app startup.
    // `_ready` is set regardless so init isn't retried on every schedule call.
    try {
      tzdata.initializeTimeZones();
      try {
        tz.setLocalLocation(
          tz.getLocation(await FlutterTimezone.getLocalTimezone()),
        );
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: darwin),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            _tapController.add(payload);
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // Capture a tap that cold-started the app so the router can honor it once
      // it's ready (see takeLaunchPayload).
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        _launchPayload = launch?.notificationResponse?.payload;
      }

      await _createAndroidChannel();
      await _requestPermissions();
    } catch (_) {
      // Swallow — the app runs fine without reminders on this device/session.
    }
    _ready = true;
  }

  Future<void> _createAndroidChannel() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
          ),
        );
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// A reminder tap that cold-launched the app, consumed once so it isn't
  /// handled twice.
  String? takeLaunchPayload() {
    final payload = _launchPayload;
    _launchPayload = null;
    return payload;
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Schedules a one-off reminder at [when]. Past times are ignored.
  /// `inexactAllowWhileIdle` fires reliably while the app is closed/idle
  /// without the exact-alarm permission — a few minutes' drift is fine for
  /// treatment reminders.
  Future<void> schedule({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    required String payload,
  }) async {
    if (!_ready) await init();
    final scheduled = tz.TZDateTime.from(when, tz.local);
    if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) return;
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (_) {
      // A single scheduling failure shouldn't break the calling flow.
    }
  }

  /// Cancels every pending reminder whose decoded JSON payload satisfies
  /// [test]. Uses the OS-persisted pending list, so it works across restarts
  /// without any separate bookkeeping.
  Future<void> cancelWhere(
    bool Function(Map<String, dynamic> payload) test,
  ) async {
    if (!_ready) await init();
    try {
      for (final request in await _plugin.pendingNotificationRequests()) {
        final raw = request.payload;
        if (raw == null || raw.isEmpty) continue;
        Map<String, dynamic> data;
        try {
          data = jsonDecode(raw) as Map<String, dynamic>;
        } catch (_) {
          continue;
        }
        if (test(data)) await _plugin.cancel(request.id);
      }
    } catch (_) {
      // Ignore — cancellation is best-effort infra.
    }
  }

  /// Cancels all scheduled reminders — used on logout so the next user never
  /// receives the previous user's reminders.
  Future<void> cancelAll() async {
    if (!_ready) await init();
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  void dispose() => _tapController.close();
}
