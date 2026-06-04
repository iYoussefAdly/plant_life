import 'disease_entity.dart';
import 'suggested_treatment_entity.dart';

enum ScanStatus { healthy, diseased }

enum ScanImageSource { camera, gallery, esp32Cam }

class ScanResultEntity {
  final String id;
  final String imagePath;
  final ScanStatus status;
  final List<DiseaseEntity> diseases;
  final DateTime scannedAt;
  final SuggestedTreatmentEntity? suggestedTreatment;

  const ScanResultEntity({
    required this.id,
    required this.imagePath,
    required this.status,
    required this.diseases,
    required this.scannedAt,
    this.suggestedTreatment,
  });
}
