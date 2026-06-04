import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notifications_cubit.dart';
import '../bloc/notifications_state.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: AppTextStyles.headlineMedium),
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) => switch (state) {
          NotificationsInitial() => const SizedBox.shrink(),
          NotificationsLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          NotificationsLoaded(:final notifications) =>
            _NotificationsList(notifications: notifications),
          NotificationsError(:final message) => ErrorView(
              message: message,
              onRetry: () =>
                  context.read<NotificationsCubit>().loadNotifications(),
            ),
        },
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  final List<NotificationEntity> notifications;

  const _NotificationsList({required this.notifications});

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 56, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              'No notifications',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final today = DateTime.now();
    final todayNotifications = notifications
        .where((n) => _isSameDay(n.timestamp, today))
        .toList();
    final earlierNotifications = notifications
        .where((n) => !_isSameDay(n.timestamp, today))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (todayNotifications.isNotEmpty) ...[
          _SectionHeader(title: 'Today'),
          const SizedBox(height: 8),
          ...todayNotifications.map((n) => NotificationTile(
                notification: n,
                onTap: () => _onNotificationTap(context, n),
              )),
        ],
        if (earlierNotifications.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(title: 'Earlier'),
          const SizedBox(height: 8),
          ...earlierNotifications.map((n) => NotificationTile(
                notification: n,
                onTap: () => _onNotificationTap(context, n),
              )),
        ],
      ],
    );
  }

  void _onNotificationTap(BuildContext context, NotificationEntity n) {
    context.read<NotificationsCubit>().markAsRead(n.id);

    switch (n.type) {
      case NotificationType.treatmentTask:
        if (n.relatedId != null) {
          context.push(AppRoutes.treatmentDetail, extra: n.relatedId);
        }
      case NotificationType.sensorWarning:
        context.push(AppRoutes.sensors);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.labelLarge.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
