import 'weekly_image_entity.dart';

class RecoveryEntity {
  final String treatmentId;
  final String treatmentTitle;
  final String plantName;
  final double progressPercent;
  final List<WeeklyImageEntity> weeklyImages;

  const RecoveryEntity({
    required this.treatmentId,
    required this.treatmentTitle,
    required this.plantName,
    required this.progressPercent,
    required this.weeklyImages,
  });
}
