import 'package:dio/dio.dart';

import '../../../../../core/networking/api_response_parser.dart';
import '../notification_model.dart';

/// Parsed payload of `GET /notifications`:
/// `{ notifications: [...], pagination: {...} }`.
class NotificationsResponse {
  final List<NotificationModel> notifications;

  const NotificationsResponse({required this.notifications});

  factory NotificationsResponse.fromResponse(Response response) {
    final data = ApiResponseParser.dataMap(response);
    final list = (data['notifications'] as List?) ?? const [];
    return NotificationsResponse(
      notifications: list
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          // Drop items with no id — they cannot be marked read (would build a
          // malformed `/notifications//read` URL).
          .where((n) => n.id.isNotEmpty)
          .toList(),
    );
  }
}
