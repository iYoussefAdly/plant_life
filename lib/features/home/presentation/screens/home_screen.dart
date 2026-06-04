import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../notifications/presentation/bloc/notifications_cubit.dart';
import '../../../notifications/presentation/bloc/notifications_state.dart';
import '../../domain/entities/home_data_entity.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import '../widgets/alerts_section.dart';
import '../widgets/sensor_summary_card.dart';
import '../widgets/treatment_tasks_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PlantLife', style: AppTextStyles.headlineMedium),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              final unread = switch (state) {
                NotificationsLoaded(:final unreadCount) => unreadCount,
                _ => 0,
              };
              return IconButton(
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () => context.push(AppRoutes.notifications),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => context.read<HomeCubit>().loadHomeData(),
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => switch (state) {
          HomeInitial() => const SizedBox.shrink(),
          HomeLoading() => const Center(child: CircularProgressIndicator()),
          HomeSuccess(:final data) => _HomeContent(data: data),
          HomeError(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<HomeCubit>().loadHomeData(),
            ),
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeDataEntity data;

  const _HomeContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().loadHomeData(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Sensor Overview', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: data.sensorReadings.length,
            itemBuilder: (context, index) =>
                SensorSummaryCard(reading: data.sensorReadings[index]),
          ),
          const SizedBox(height: 24),
          AlertsSection(alerts: data.alerts),
          const SizedBox(height: 24),
          TreatmentTasksSection(tasks: data.todayTasks),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
