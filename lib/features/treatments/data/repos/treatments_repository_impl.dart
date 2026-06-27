import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/treatment_plan_entity.dart';
import '../../domain/entities/treatment_step_entity.dart';
import '../../domain/repos/treatments_repository.dart';

class TreatmentsRepositoryImpl implements TreatmentsRepository {
  final List<TreatmentPlanEntity> _plans = _buildMockPlans();

  @override
  Future<ApiResult<List<TreatmentPlanEntity>>> getTreatmentPlans() async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      return Success(List.unmodifiable(_plans));
    } catch (e) {
      return const Error(ServerFailure('Failed to load treatment plans'));
    }
  }

  @override
  Future<ApiResult<TreatmentPlanEntity>> getTreatmentDetail(String planId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final plan = _plans.where((p) => p.id == planId).firstOrNull;
      if (plan == null) {
        return const Error(ServerFailure('Treatment plan not found'));
      }
      return Success(plan);
    } catch (e) {
      return const Error(ServerFailure('Failed to load treatment detail'));
    }
  }

  @override
  Future<ApiResult<TreatmentPlanEntity>> toggleStepCompletion({
    required String planId,
    required String stepId,
    required bool isCompleted,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final planIndex = _plans.indexWhere((p) => p.id == planId);
      if (planIndex == -1) {
        return const Error(ServerFailure('Treatment plan not found'));
      }

      final updated = _plans[planIndex].copyWithStep(
        stepId,
        isCompleted: isCompleted,
      );
      _plans[planIndex] = updated;

      return Success(updated);
    } catch (e) {
      return const Error(ServerFailure('Failed to update step'));
    }
  }

  static List<TreatmentPlanEntity> _buildMockPlans() {
    final now = DateTime.now();

    return [
      TreatmentPlanEntity(
        id: 'plan-1',
        title: 'Powdery Mildew Treatment',
        description: 'A 7-day treatment plan for powdery mildew using neem oil and proper ventilation.',
        plantName: 'Tomato Plant',
        createdAt: now.subtract(const Duration(days: 3)),
        steps: [
          TreatmentStepEntity(
            id: 'step-1-1',
            dayNumber: 1,
            title: 'Remove affected leaves',
            description: 'Carefully prune all visibly infected leaves and dispose of them away from the garden.',
            isCompleted: true,
            scheduledAt: now.subtract(const Duration(days: 3)),
          ),
          TreatmentStepEntity(
            id: 'step-1-2',
            dayNumber: 1,
            title: 'Apply neem oil spray',
            description: 'Mix 2 tablespoons of neem oil per gallon of water. Spray all leaf surfaces thoroughly.',
            isCompleted: true,
            scheduledAt: now.subtract(const Duration(days: 3)),
          ),
          TreatmentStepEntity(
            id: 'step-1-3',
            dayNumber: 2,
            title: 'Improve air circulation',
            description: 'Space plants further apart and remove any overcrowded foliage.',
            isCompleted: false,
            scheduledAt: now.subtract(const Duration(days: 1)),
          ),
          TreatmentStepEntity(
            id: 'step-1-4',
            dayNumber: 2,
            title: 'Second neem oil application',
            description: 'Reapply neem oil spray to all surfaces. Focus on undersides of leaves.',
            isCompleted: false,
            scheduledAt: now.subtract(const Duration(days: 1)),
          ),
          TreatmentStepEntity(
            id: 'step-1-5',
            dayNumber: 3,
            title: 'Final inspection',
            description: 'Check all leaves for signs of remaining infection. Take a progress photo.',
            isCompleted: false,
            scheduledAt: now.add(const Duration(days: 4)),
          ),
        ],
      ),
      TreatmentPlanEntity(
        id: 'plan-2',
        title: 'Root Rot Recovery',
        description: 'Emergency treatment for root rot caused by overwatering. Requires repotting.',
        plantName: 'Peace Lily',
        createdAt: now.subtract(const Duration(days: 7)),
        steps: [
          TreatmentStepEntity(
            id: 'step-2-1',
            dayNumber: 1,
            title: 'Remove from pot',
            description: 'Gently remove the plant and shake off all old soil from the roots.',
            isCompleted: true,
            scheduledAt: now.subtract(const Duration(days: 7)),
          ),
          TreatmentStepEntity(
            id: 'step-2-2',
            dayNumber: 1,
            title: 'Trim rotten roots',
            description: 'Cut away all brown, mushy roots with sterilized scissors. Keep only firm, white roots.',
            isCompleted: true,
            scheduledAt: now.subtract(const Duration(days: 7)),
          ),
          TreatmentStepEntity(
            id: 'step-2-3',
            dayNumber: 1,
            title: 'Apply fungicide to roots',
            description: 'Dip remaining roots in a fungicide solution for 10 minutes.',
            isCompleted: true,
            scheduledAt: now.subtract(const Duration(days: 7)),
          ),
          TreatmentStepEntity(
            id: 'step-2-4',
            dayNumber: 1,
            title: 'Repot in fresh soil',
            description: 'Use a new pot with drainage holes and fresh, well-draining potting mix.',
            isCompleted: true,
            scheduledAt: now.subtract(const Duration(days: 7)),
          ),
          TreatmentStepEntity(
            id: 'step-2-5',
            dayNumber: 2,
            title: 'Reduce watering schedule',
            description: 'Water only when top 2 inches of soil are dry. Check every 3 days.',
            isCompleted: false,
            scheduledAt: now,
          ),
          TreatmentStepEntity(
            id: 'step-2-6',
            dayNumber: 3,
            title: 'Monitor new growth',
            description: 'Watch for new leaf growth as a sign of recovery. Take weekly photos.',
            isCompleted: false,
            scheduledAt: now.add(const Duration(days: 7)),
          ),
        ],
      ),
      TreatmentPlanEntity(
        id: 'plan-3',
        title: 'Nutrient Deficiency Plan',
        description: 'Targeted feeding schedule to correct iron and nitrogen deficiency.',
        plantName: 'Basil',
        createdAt: now.subtract(const Duration(days: 1)),
        steps: [
          TreatmentStepEntity(
            id: 'step-3-1',
            dayNumber: 1,
            title: 'Test soil pH',
            description: 'Use a soil test kit to check pH level. Ideal range: 6.0-7.0.',
            isCompleted: false,
            scheduledAt: now,
          ),
          TreatmentStepEntity(
            id: 'step-3-2',
            dayNumber: 1,
            title: 'Apply iron chelate',
            description: 'Dissolve iron chelate fertilizer in water per package instructions and apply.',
            isCompleted: false,
            scheduledAt: now,
          ),
          TreatmentStepEntity(
            id: 'step-3-3',
            dayNumber: 2,
            title: 'Apply balanced fertilizer',
            description: 'Use a 10-10-10 NPK fertilizer at half strength.',
            isCompleted: false,
            scheduledAt: now.add(const Duration(days: 1)),
          ),
        ],
      ),
    ];
  }
}
