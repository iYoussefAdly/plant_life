import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repos/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final List<NotificationEntity> _notifications = _buildMockNotifications();

  @override
  Future<ApiResult<List<NotificationEntity>>> getNotifications() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return Success(List.unmodifiable(_notifications));
    } catch (e) {
      return const Error(ServerFailure('Failed to load notifications'));
    }
  }

  @override
  Future<ApiResult<void>> markAsRead(String notificationId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
      return const Success(null);
    } catch (e) {
      return const Error(ServerFailure('Failed to mark notification as read'));
    }
  }

  static List<NotificationEntity> _buildMockNotifications() {
    final now = DateTime.now();
    return [
      NotificationEntity(
        id: 'notif-1',
        type: NotificationType.treatmentTask,
        title: 'Water Plant',
        message: 'Time to water your tomato plant — Step 2 of Mildew Treatment',
        timestamp: now.subtract(const Duration(minutes: 30)),
        relatedId: 'plan-1',
      ),
      NotificationEntity(
        id: 'notif-2',
        type: NotificationType.sensorWarning,
        title: 'High Temperature',
        message: 'Temperature reached 38.5°C — exceeds safe range for tomato',
        timestamp: now.subtract(const Duration(hours: 1)),
        relatedId: 'temperature',
      ),
      NotificationEntity(
        id: 'notif-3',
        type: NotificationType.treatmentTask,
        title: 'Apply Fungicide',
        message: 'Apply fungicide spray as scheduled — Step 3 of Mildew Treatment',
        timestamp: now.subtract(const Duration(hours: 2)),
        relatedId: 'plan-1',
      ),
      NotificationEntity(
        id: 'notif-4',
        type: NotificationType.sensorWarning,
        title: 'Low Soil Moisture',
        message: 'Soil moisture dropped to 22% — below the 30% threshold',
        timestamp: now.subtract(const Duration(hours: 3)),
        relatedId: 'soilMoisture',
      ),
      NotificationEntity(
        id: 'notif-5',
        type: NotificationType.treatmentTask,
        title: 'Remove Infected Leaves',
        message: 'Inspect and remove leaves showing powdery mildew signs',
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: true,
        relatedId: 'plan-1',
      ),
      NotificationEntity(
        id: 'notif-6',
        type: NotificationType.sensorWarning,
        title: 'Low Light Level',
        message: 'Light level at 150 lux — below optimal range for growth',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
        relatedId: 'light',
      ),
      NotificationEntity(
        id: 'notif-7',
        type: NotificationType.treatmentTask,
        title: 'Check Soil pH',
        message: 'Verify soil pH is between 6.0-6.8 for optimal treatment',
        timestamp: now.subtract(const Duration(days: 1, hours: 6)),
        isRead: true,
        relatedId: 'plan-2',
      ),
      NotificationEntity(
        id: 'notif-8',
        type: NotificationType.sensorWarning,
        title: 'Temperature Warning',
        message: 'Temperature spiked to 36.2°C during afternoon hours',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        relatedId: 'temperature',
      ),
    ];
  }
}
