import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
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
          SensorsError(:final message) => ErrorView(
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
