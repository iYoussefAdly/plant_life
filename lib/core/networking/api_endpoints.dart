/// Centralized backend endpoint paths.
///
/// The base URL defaults to the Railway production deployment but can be
/// overridden at build time for staging/local servers, e.g.
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api`.
/// All paths are relative to it and consumed via [ApiEndpoints] by the
/// per-feature data sources.
abstract final class ApiEndpoints {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://plant-life-production-8a63.up.railway.app/api',
  );

  // Auth
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const refreshToken = '/auth/refresh-token';
  static const me = '/auth/me';

  // Scans
  static const scans = '/scans';
  static String scan(String id) => '/scans/$id';
  static String rescan(String parentScanId) => '/scans/$parentScanId/rescan';
  static String scanRescans(String scanId) => '/scans/$scanId/rescans';

  // AI model service — a separate host that camera captures are analyzed by.
  // Absolute URL (Dio uses it directly, ignoring the plant-life base URL);
  // overridable at build time like the other base URLs.
  static const cameraAnalyze = String.fromEnvironment(
    'CAMERA_ANALYZE_URL',
    defaultValue: 'https://model-production-bcf1.up.railway.app/analyze',
  );

  // Heal plans
  static const healPlans = '/heal-plans';
  static const healPlanTemplates = '/heal-plans/templates';
  static String healPlan(String id) => '/heal-plans/$id';
  static String healPlanTask(String planId, int taskIndex) =>
      '/heal-plans/$planId/tasks/$taskIndex';
  // Toggle and fetch share the same path (differ by HTTP verb: PATCH vs GET).
  static String toggleHealPlanTask(String planId, int taskIndex) =>
      healPlanTask(planId, taskIndex);
  static String cancelHealPlan(String id) => '/heal-plans/$id/cancel';

  // Notifications
  static const notifications = '/notifications';
  static const notificationsUnreadCount = '/notifications/unread-count';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const notificationsReadAll = '/notifications/read-all';
}
