import 'package:dio/dio.dart';

import '../../../../core/networking/api_endpoints.dart';
import '../../../../core/networking/api_response_parser.dart';
import '../../../../core/networking/socket_service.dart';
import '../models/notification_model.dart';
import '../models/responses/notifications_response.dart';

/// Remote notifications API. Throws [DioException] on failure; the repository
/// maps those to typed failures at the boundary.
class NotificationsDataSource {
  final Dio _dio;
  final SocketService _socketService;
  const NotificationsDataSource(this._dio, this._socketService);

  /// Live `notification:new` events from the socket, mapped to models.
  /// Malformed payloads are skipped so one bad event can't kill the stream.
  Stream<NotificationModel> watchNew() async* {
    await for (final payload in _socketService.onNotificationNew) {
      try {
        yield NotificationModel.fromJson(payload);
      } catch (_) {
        // Ignore an unparseable payload and keep listening.
      }
    }
  }

  Future<NotificationsResponse> getNotifications({
    int page = 1,
    int limit = 20,
    bool? read,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (read != null) query['read'] = read;
    final response = await _dio.get<dynamic>(
      ApiEndpoints.notifications,
      queryParameters: query,
    );
    return NotificationsResponse.fromResponse(response);
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.notificationsUnreadCount,
    );
    final data = ApiResponseParser.dataMap(response);
    return (data['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _dio.patch<dynamic>(ApiEndpoints.markNotificationRead(id));
  }
}
