/// Endpoints for the sensor backend (`plantlife-production`).
///
/// This is a separate host from the main plant-life API, but it shares the same
/// auth realm — requests carry the user's existing access token (see
/// [SensorApiClient]). The base URL can be overridden at build time, e.g.
/// `flutter run --dart-define=SENSOR_API_BASE_URL=http://10.0.2.2:5000/api`.
abstract final class SensorApiEndpoints {
  static const baseUrl = String.fromEnvironment(
    'SENSOR_API_BASE_URL',
    defaultValue: 'https://plantlife-production.up.railway.app/api',
  );

  // Readings — the device posts to /sensors/data; the app only reads history.
  // History returns warning/danger readings only (normal readings aren't
  // persisted by the backend).
  static String history(String deviceId) => '/sensors/history/$deviceId';

  // Sensor notifications (per-sensor warning/danger alerts).
  static const notifications = '/sensors/notifications';
  static const notificationsUnreadCount = '/sensors/notifications/unread-count';
  static String markNotificationRead(String id) =>
      '/sensors/notifications/$id/read';
  static const notificationsReadAll = '/sensors/notifications/read-all';

  // FCM device-token registration (account-level, on this backend).
  static const fcmToken = '/auth/fcm-token';
}
