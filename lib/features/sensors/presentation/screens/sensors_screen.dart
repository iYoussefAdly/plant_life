import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/pulsing_dot.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/localization/l10n.dart';
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
        title: Text(context.l10n.navSensors, style: AppTextStyles.headlineMedium),
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
          SensorsLoading() => const _SensorsSkeleton(),
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
      onRefresh: () =>
          context.read<SensorsCubit>().loadSensorsData(silent: true),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FadeSlideIn(
            child: SectionHeader(
              icon: Icons.sensors,
              title: context.l10n.liveReadings,
              trailing: const _LiveChip(),
            ),
          ),
          const SizedBox(height: 12),
          ...data.sensors.asMap().entries.map((entry) => FadeSlideIn(
                index: entry.key + 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: SensorDetailCard(sensor: entry.value),
                ),
              )),
          const SizedBox(height: 12),
          FadeSlideIn(
            index: data.sensors.length + 1,
            child: AlertHistoryList(alerts: data.alertHistory),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Pulsing "LIVE" indicator for the readings header.
class _LiveChip extends StatelessWidget {
  const _LiveChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PulsingDot(color: AppColors.success, size: 7),
          const SizedBox(width: 6),
          Text(
            context.l10n.liveLabel,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Monitoring-shaped loading placeholder.
class _SensorsSkeleton extends StatelessWidget {
  const _SensorsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: const [
          SkeletonBox(width: 150, height: 22, radius: 8),
          SizedBox(height: 14),
          SkeletonBox(height: 190, radius: 16),
          SizedBox(height: 14),
          SkeletonBox(height: 190, radius: 16),
          SizedBox(height: 14),
          SkeletonBox(height: 190, radius: 16),
        ],
      ),
    );
  }
}
