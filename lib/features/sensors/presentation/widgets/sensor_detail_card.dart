import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/sensor_type_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/sensor_detail_entity.dart';

class SensorDetailCard extends StatelessWidget {
  final SensorDetailEntity sensor;

  const SensorDetailCard({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(sensor: sensor, color: _sensorColor),
          const SizedBox(height: 16),
          _MiniChart(sensor: sensor, color: _sensorColor),
          const SizedBox(height: 12),
          _RangeBar(sensor: sensor, color: _sensorColor),
        ],
      ),
    );
  }

  Color get _sensorColor => sensor.type.color;
}

class _Header extends StatelessWidget {
  final SensorDetailEntity sensor;
  final Color color;

  const _Header({required this.sensor, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_icon, size: 22, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_label, style: AppTextStyles.labelLarge),
              Text(
                _statusText,
                style: AppTextStyles.bodySmall.copyWith(color: _statusColor),
              ),
            ],
          ),
        ),
        Text(
          '${sensor.currentValue.toStringAsFixed(1)}${sensor.unit}',
          style: AppTextStyles.headlineMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  IconData get _icon => sensor.type.icon;
  String get _label => sensor.type.label;
  String get _statusText => sensor.status.label;
  Color get _statusColor => sensor.status.color;
}

class _MiniChart extends StatelessWidget {
  final SensorDetailEntity sensor;
  final Color color;

  const _MiniChart({required this.sensor, required this.color});

  @override
  Widget build(BuildContext context) {
    if (sensor.history.isEmpty) return const SizedBox(height: 80);

    final spots = sensor.history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    return SizedBox(
      height: 80,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          minY: sensor.minRange - (sensor.maxRange - sensor.minRange) * 0.2,
          maxY: sensor.maxRange + (sensor.maxRange - sensor.minRange) * 0.2,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.1),
              ),
            ),
          ],
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: sensor.minRange,
                color: AppColors.textHint.withValues(alpha: 0.3),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
              HorizontalLine(
                y: sensor.maxRange,
                color: AppColors.textHint.withValues(alpha: 0.3),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RangeBar extends StatelessWidget {
  final SensorDetailEntity sensor;
  final Color color;

  const _RangeBar({required this.sensor, required this.color});

  @override
  Widget build(BuildContext context) {
    final range = sensor.maxRange - sensor.minRange;
    final position = range > 0
        ? ((sensor.currentValue - sensor.minRange) / range).clamp(0.0, 1.0)
        : 0.5;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Min: ${sensor.minRange.toStringAsFixed(0)}${sensor.unit}',
              style: AppTextStyles.bodySmall,
            ),
            Text(
              'Optimal Range',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Max: ${sensor.maxRange.toStringAsFixed(0)}${sensor.unit}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.error.withValues(alpha: 0.3),
                        AppColors.success.withValues(alpha: 0.5),
                        AppColors.success.withValues(alpha: 0.5),
                        AppColors.error.withValues(alpha: 0.3),
                      ],
                      stops: const [0.0, 0.25, 0.75, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: position * constraints.maxWidth - 6,
                  top: -3,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
