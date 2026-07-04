import '../../../../core/errors/api_result.dart';
import '../entities/treatment_plan_entity.dart';
import '../repos/treatments_repository.dart';

/// Cancels an active heal plan.
class CancelPlanUseCase {
  final TreatmentsRepository _repository;

  CancelPlanUseCase(this._repository);

  Future<ApiResult<TreatmentPlanEntity>> call(String planId) =>
      _repository.cancelPlan(planId);
}
