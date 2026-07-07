import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Background/terminated FCM handler. Runs in its own isolate, so it needs a
/// fresh Firebase init. On Android, messages that carry a `notification` block
/// are displayed by the system automatically — nothing to do here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Nothing else to do — the system tray notification is shown by Android.
  }
}

/// Firebase Cloud Messaging for **Sensor danger alerts only**. Completely
/// separate from [LocalNotificationsService] (treatment reminders), including a
/// dedicated Android channel, so the two never interfere.
///
/// Scoped to Android — the project ships only an Android `google-services.json`
/// (no iOS APNs config), so on other platforms this stays inert and the app
/// runs normally without push.
class PushNotificationsService {
  static const _channelId = 'sensor_alerts';
  static const _channelName = 'Sensor alerts';
  static const _channelDescription =
      'Critical (danger) alerts from your plant sensors';

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  final _tokenRefreshController = StreamController<String>.broadcast();
  final _foregroundController = StreamController<RemoteMessage>.broadcast();
  final _openedController = StreamController<RemoteMessage>.broadcast();

  bool _ready = false;
  bool _available = false;

  /// Whether FCM initialized successfully (Firebase configured on this build).
  bool get isAvailable => _available;

  /// New token whenever FCM rotates it — re-register with the backend.
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  /// A sensor push received while the app is in the foreground.
  Stream<RemoteMessage> get onForegroundMessage => _foregroundController.stream;

  /// A sensor push the user tapped to open the app.
  Stream<RemoteMessage> get onOpened => _openedController.stream;

  Future<void> init() async {
    if (_ready) return;
    _ready = true;
    if (!Platform.isAndroid) return;
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await FirebaseMessaging.instance.requestPermission();
      await _initLocalChannel();

      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(_openedController.add);
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        if (token.isNotEmpty) _tokenRefreshController.add(token);
      });

      // A push that cold-started the app. Delivered on the event queue (not
      // inline) so listeners attached right after `await init()` still get it —
      // a broadcast stream drops events emitted before anyone listens.
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        Future<void>(() {
          if (!_openedController.isClosed) _openedController.add(initial);
        });
      }

      _available = true;
    } catch (_) {
      // Firebase not available/configured — continue without push.
      _available = false;
    }
  }

  /// The current FCM device token, or null when unavailable.
  Future<String?> getToken() async {
    if (!_available) return null;
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> _initLocalChannel() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _local.initialize(
      const InitializationSettings(android: android),
    );
    await _local
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

  /// Foreground FCM messages are not shown by the system — display manually on
  /// the dedicated sensor channel.
  void _onForeground(RemoteMessage message) {
    _foregroundController.add(message);
    final notification = message.notification;
    if (notification == null) return;
    _local.show(
      message.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  void dispose() {
    _tokenRefreshController.close();
    _foregroundController.close();
    _openedController.close();
  }
}
