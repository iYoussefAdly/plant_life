import 'disease_entity.dart';

enum ScanStatus { healthy, diseased }

enum ScanImageSource { camera, gallery, esp32Cam }

class ScanResultEntity {
  final String id;
  final String imagePath;
  final ScanStatus status;
  final List<DiseaseEntity> diseases;
  final DateTime scannedAt;

  /// Number of leaves the AI model detected. Only populated for camera scans
  /// (the `/analyze` service reports it); null for gallery and all other flows.
  final int? leavesCount;

  const ScanResultEntity({
    required this.id,
    required this.imagePath,
    required this.status,
    required this.diseases,
    required this.scannedAt,
    this.leavesCount,
  });
}
