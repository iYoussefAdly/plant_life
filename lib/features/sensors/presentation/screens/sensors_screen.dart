import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/sensors_data_entity.dart';
import '../bloc/sensors_cubit.dart';
import '../bloc/sensors_state.dart';
import '../widgets/alert_history_list.dart';
import '../widgets/sensor_detail_card.dart';

class SensorsScreen extends StatelessWidget {
  const SensorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensors', style: AppTextStyles.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => context.read<SensorsCubit>().loadSensorsData(),
          ),
        ],
      ),
      body: BlocBuilder<SensorsCubit, SensorsState>(
        builder: (context, state) => switch (state) {
          SensorsInitial() => const SizedBox.shrink(),
          SensorsLoading() =>
            const Center(child: CircularProgressIndicator()),
          SensorsSuccess(:final data) => _SensorsContent(data: data),
          SensorsError(:final message) => _ErrorView(
              message: message,
              onRetry: () => context.read<SensorsCubit>().loadSensorsData(),
            ),
        },
      ),
    );
  }
}

class _SensorsContent extends StatelessWidget {
  final SensorsDataEntity data;

  const _SensorsContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<SensorsCubit>().loadSensorsData(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...data.sensors.map((sensor) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SensorDetailCard(sensor: sensor),
              )),
          const SizedBox(height: 8),
          AlertHistoryList(alerts: data.alertHistory),
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
