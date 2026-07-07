import 'package:dio/dio.dart';

import '../../../../core/networking/api_response_parser.dart';
import '../sensor_api_client.dart';
import '../sensor_api_endpoints.dart';
import '../models/sensor_notification_model.dart';
import '../models/sensor_reading_model.dart';

/// Remote sensor API (separate backend, reuses the user's access token).
/// Throws [DioException] on failure; the repository maps those to typed
/// failures at the boundary.
class SensorsDataSource {
  final SensorApiClient _client;
  const SensorsDataSource(this._client);

  Dio get _dio => _client.dio;

  /// Recorded readings for a device (warning/danger only — the backend does not
  /// persist normal readings).
  Future<List<SensorReadingModel>> getHistory(
    String deviceId, {
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) query['status'] = status;
    final response = await _dio.get<dynamic>(
      SensorApiEndpoints.history(deviceId),
      queryParameters: query,
    );
    final data = ApiResponseParser.dataMap(response);
    final list = (data['readings'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(SensorReadingModel.fromJson)
        .toList();
  }

  Future<List<SensorNotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
    bool? isRead,
    String? status,
    String? deviceId,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (isRead != null) query['isRead'] = isRead;
    if (status != null) query['status'] = status;
    if (deviceId != null) query['deviceId'] = deviceId;
    final response = await _dio.get<dynamic>(
      SensorApiEndpoints.notifications,
      queryParameters: query,
    );
    final data = ApiResponseParser.dataMap(response);
    final list = (data['notifications'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(SensorNotificationModel.fromJson)
        // Drop items with no id — they can't be marked read.
        .where((n) => n.id.isNotEmpty)
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response =
        await _dio.get<dynamic>(SensorApiEndpoints.notificationsUnreadCount);
    final data = ApiResponseParser.data(response);
    if (data is num) return data.toInt();
    if (data is Map<String, dynamic>) {
      final count = data['unreadCount'] ?? data['count'] ?? data['unread'];
      if (count is num) return count.toInt();
      if (count is String) return int.tryParse(count) ?? 0;
    }
    return 0;
  }

  Future<void> markAsRead(String id) async {
    await _dio.patch<dynamic>(SensorApiEndpoints.markNotificationRead(id));
  }

  Future<void> markAllAsRead() async {
    await _dio.patch<dynamic>(SensorApiEndpoints.notificationsReadAll);
  }

  /// Registers/updates the device's FCM token for push delivery of danger
  /// alerts (`PATCH /auth/fcm-token`).
  Future<void> updateFcmToken(String token) async {
    await _dio.patch<dynamic>(
      SensorApiEndpoints.fcmToken,
      data: {'fcmToken': token},
    );
  }
}
