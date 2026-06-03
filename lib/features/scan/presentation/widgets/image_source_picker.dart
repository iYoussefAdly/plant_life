import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/scan_result_entity.dart';

class ScanImageSourcePicker extends StatelessWidget {
  final ValueChanged<ScanImageSource> onSourceSelected;

  const ScanImageSourcePicker({super.key, required this.onSourceSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.document_scanner_outlined,
            size: 56,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text('Scan Your Plant', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Take a photo or upload an image to detect diseases',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _SourceButton(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () => onSourceSelected(ScanImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SourceButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: () => onSourceSelected(ScanImageSource.gallery),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SourceButton(
                icon: Icons.linked_camera_outlined,
                label: 'ESP32',
                onTap: () => onSourceSelected(ScanImageSource.esp32Cam),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
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
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
