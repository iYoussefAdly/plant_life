import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/scan_result_entity.dart';

final _picker = ImagePicker();

/// Resolves a [ScanImageSource] to a local image path, sharing one behavior
/// across the Scan and Recovery (rescan) flows:
/// camera/gallery → image_picker; ESP32-CAM → "coming soon" notice (hardware
/// integration is postponed). Returns null when nothing was picked.
Future<String?> pickScanImagePath(
  BuildContext context,
  ScanImageSource source,
) async {
  if (source == ScanImageSource.esp32Cam) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ESP32 camera support is coming soon')),
    );
    return null;
  }
  final picked = await _picker.pickImage(
    source: source == ScanImageSource.camera
        ? ImageSource.camera
        : ImageSource.gallery,
    imageQuality: 85,
  );
  return picked?.path;
}

/// Bottom sheet offering the same three sources as the Scan screen
/// (camera / gallery / ESP32-CAM). Returns the chosen source, or null.
Future<ScanImageSource?> showScanSourceSheet(BuildContext context) {
  return showModalBottomSheet<ScanImageSource>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Text('Choose image source', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 12),
            _SourceTile(
              icon: Icons.camera_alt_outlined,
              title: 'Camera',
              subtitle: 'Take a new photo',
              onTap: () =>
                  Navigator.of(sheetContext).pop(ScanImageSource.camera),
            ),
            _SourceTile(
              icon: Icons.photo_library_outlined,
              title: 'Gallery',
              subtitle: 'Upload an existing image',
              onTap: () =>
                  Navigator.of(sheetContext).pop(ScanImageSource.gallery),
            ),
            _SourceTile(
              icon: Icons.linked_camera_outlined,
              title: 'ESP32-CAM',
              subtitle: 'Capture from your plant camera',
              onTap: () =>
                  Navigator.of(sheetContext).pop(ScanImageSource.esp32Cam),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 21, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right,
          size: 20, color: AppColors.textHint),
    );
  }
}
