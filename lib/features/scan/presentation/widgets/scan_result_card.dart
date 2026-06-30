import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/disease_entity.dart';
import '../../domain/entities/scan_result_entity.dart';

class ScanResultCard extends StatelessWidget {
  final ScanResultEntity result;
  final VoidCallback onScanAgain;
  final VoidCallback? onStartTreatment;

  const ScanResultCard({
    super.key,
    required this.result,
    required this.onScanAgain,
    this.onStartTreatment,
  });

  @override
  Widget build(BuildContext context) {
    final isHealthy = result.status == ScanStatus.healthy;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: (isHealthy ? AppColors.success : AppColors.error)
                .withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isHealthy ? Icons.check_circle_outline : Icons.warning_amber_outlined,
            size: 44,
            color: isHealthy ? AppColors.success : AppColors.error,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isHealthy ? 'Plant is Healthy!' : 'Disease Detected',
          style: AppTextStyles.headlineMedium.copyWith(
            color: isHealthy ? AppColors.success : AppColors.error,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isHealthy
              ? 'No signs of disease were found in your plant.'
              : '${result.diseases.length} disease${result.diseases.length > 1 ? 's' : ''} found',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        if (!isHealthy) ...[
          const SizedBox(height: 20),
          ...result.diseases.map((d) => _DiseaseTile(disease: d)),
          if (onStartTreatment != null) ...[
            const SizedBox(height: 10),
            const _TreatmentPrompt(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onStartTreatment,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Treatment'),
              ),
            ),
          ],
        ],
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: onScanAgain,
            icon: const Icon(Icons.refresh),
            label: const Text('Scan Again'),
          ),
        ),
      ],
    );
  }
}

class _DiseaseTile extends StatelessWidget {
  final DiseaseEntity disease;

  const _DiseaseTile({required this.disease});

  @override
  Widget build(BuildContext context) {
    final confidencePct = (disease.confidence * 100).toStringAsFixed(0);
    final severityPct = disease.severityPercent.toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _severityColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  disease.name,
                  style: AppTextStyles.headlineSmall.copyWith(fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$confidencePct% conf.',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Severity',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '$severityPct%',
                style: AppTextStyles.labelLarge.copyWith(
                  color: _severityColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (disease.severityPercent / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.textHint.withValues(alpha: 0.2),
              color: _severityColor,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Color get _severityColor {
    if (disease.severityPercent >= 70) return AppColors.error;
    if (disease.severityPercent >= 40) return AppColors.warning;
    return AppColors.success;
  }
}

class _TreatmentPrompt extends StatelessWidget {
  const _TreatmentPrompt();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.medical_services_outlined,
              size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'A treatment plan is available for this diagnosis. '
              'Start it to track your daily tasks.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
