import '../../../../core/errors/api_result.dart';
import '../entities/treatment_plan_entity.dart';

abstract class TreatmentsRepository {
  Future<ApiResult<List<TreatmentPlanEntity>>> getTreatmentPlans();

  Future<ApiResult<TreatmentPlanEntity>> getTreatmentDetail(String planId);

  Future<ApiResult<TreatmentPlanEntity>> toggleStepCompletion({
    required String planId,
    required String stepId,
    required bool isCompleted,
  });
}
