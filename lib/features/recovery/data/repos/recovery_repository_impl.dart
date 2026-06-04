import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/recovery_entity.dart';
import '../../domain/entities/weekly_image_entity.dart';
import '../../domain/repos/recovery_repository.dart';

class RecoveryRepositoryImpl implements RecoveryRepository {
  @override
  Future<ApiResult<RecoveryEntity>> getRecoveryProgress(
    String treatmentId,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 700));

      final recovery = _mockData[treatmentId];
      if (recovery == null) {
        return const Error(ServerFailure('Recovery data not found'));
      }
      return Success(recovery);
    } catch (e) {
      return const Error(ServerFailure('Failed to load recovery data'));
    }
  }

  static final _mockData = <String, RecoveryEntity>{
    'plan-1': RecoveryEntity(
      treatmentId: 'plan-1',
      treatmentTitle: 'Powdery Mildew Treatment',
      plantName: 'Tomato Plant',
      progressPercent: 0.40,
      weeklyImages: [
        WeeklyImageEntity(
          weekNumber: 1,
          notes: 'Initial infection spotted. Removed affected leaves and applied first neem oil treatment.',
          date: DateTime.now().subtract(const Duration(days: 21)),
        ),
        WeeklyImageEntity(
          weekNumber: 2,
          notes: 'Mildew spread has slowed. New growth appears healthy. Applied second neem oil spray.',
          date: DateTime.now().subtract(const Duration(days: 14)),
        ),
        WeeklyImageEntity(
          weekNumber: 3,
          notes: 'Significant improvement. Only traces of mildew on lower leaves. Air circulation improved.',
          date: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ],
    ),
    'plan-2': RecoveryEntity(
      treatmentId: 'plan-2',
      treatmentTitle: 'Root Rot Recovery',
      plantName: 'Peace Lily',
      progressPercent: 0.67,
      weeklyImages: [
        WeeklyImageEntity(
          weekNumber: 1,
          notes: 'Removed from old pot. Trimmed all rotten roots. Applied fungicide and repotted.',
          date: DateTime.now().subtract(const Duration(days: 28)),
        ),
        WeeklyImageEntity(
          weekNumber: 2,
          notes: 'Plant showing signs of shock — drooping leaves. Reduced watering to minimum.',
          date: DateTime.now().subtract(const Duration(days: 21)),
        ),
        WeeklyImageEntity(
          weekNumber: 3,
          notes: 'First new leaf unfurling! Roots appear firm and white when checked.',
          date: DateTime.now().subtract(const Duration(days: 14)),
        ),
        WeeklyImageEntity(
          weekNumber: 4,
          notes: 'Steady new growth. Two new leaves this week. Watering schedule stabilized.',
          date: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ],
    ),
    'plan-3': RecoveryEntity(
      treatmentId: 'plan-3',
      treatmentTitle: 'Nutrient Deficiency Plan',
      plantName: 'Basil',
      progressPercent: 0.0,
      weeklyImages: [],
    ),
  };
}
