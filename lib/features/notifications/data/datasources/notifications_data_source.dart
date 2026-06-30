import 'package:dio/dio.dart';

import '../../../../core/networking/api_endpoints.dart';
import '../../../../core/networking/api_response_parser.dart';
import '../models/responses/notifications_response.dart';

/// Remote notifications API. Throws [DioException] on failure; the repository
/// maps those to typed failures at the boundary.
class NotificationsDataSource {
  final Dio _dio;
  const NotificationsDataSource(this._dio);

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
