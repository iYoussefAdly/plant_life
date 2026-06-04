import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/disease_entity.dart';
import '../../domain/entities/scan_result_entity.dart';
import '../../domain/entities/suggested_treatment_entity.dart';

class ScanResultCard extends StatelessWidget {
  final ScanResultEntity result;
  final VoidCallback onScanAgain;
  final VoidCallback? onStartTreatment;
  final ValueChanged<DateTime>? onRemindLater;

  const ScanResultCard({
    super.key,
    required this.result,
    required this.onScanAgain,
    this.onStartTreatment,
    this.onRemindLater,
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
        ],
        if (!isHealthy && result.suggestedTreatment != null) ...[
          const SizedBox(height: 20),
          _TreatmentOverview(treatment: result.suggestedTreatment!),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStartTreatment,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Treatment'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRemindLater != null
                  ? () => onRemindLater!(DateTime.now())
                  : null,
              icon: const Icon(Icons.schedule_outlined),
              label: const Text('Remind Me Later'),
            ),
          ),
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
    final percentage = (disease.confidence * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _confidenceColor.withValues(alpha: 0.3),
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
                  color: _confidenceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percentage%',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: _confidenceColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: disease.confidence,
              backgroundColor: AppColors.textHint.withValues(alpha: 0.2),
              color: _confidenceColor,
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            disease.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Color get _confidenceColor {
    if (disease.confidence >= 0.7) return AppColors.error;
    if (disease.confidence >= 0.4) return AppColors.warning;
    return AppColors.textSecondary;
  }
}

class _TreatmentOverview extends StatelessWidget {
  final SuggestedTreatmentEntity treatment;

  const _TreatmentOverview({required this.treatment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_services_outlined,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Suggested Treatment',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            treatment.title,
            style: AppTextStyles.headlineSmall.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            treatment.summary,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoChip(
                icon: Icons.schedule_outlined,
                label: treatment.estimatedDuration,
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Icons.checklist_outlined,
                label: '${treatment.totalSteps} steps',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
