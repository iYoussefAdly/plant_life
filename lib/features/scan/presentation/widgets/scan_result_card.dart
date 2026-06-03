import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/disease_entity.dart';
import '../../domain/entities/scan_result_entity.dart';

class ScanResultCard extends StatelessWidget {
  final ScanResultEntity result;
  final VoidCallback onScanAgain;

  const ScanResultCard({
    super.key,
    required this.result,
    required this.onScanAgain,
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
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
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
