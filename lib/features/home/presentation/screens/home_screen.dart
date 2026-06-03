import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
          HomeError(:final message) => _ErrorView(
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

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
