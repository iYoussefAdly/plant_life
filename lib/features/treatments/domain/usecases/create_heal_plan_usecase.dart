import '../../../../core/errors/api_result.dart';
import '../entities/treatment_plan_entity.dart';
import '../repos/treatments_repository.dart';

/// Creates a heal plan from an infected scan (used by the scan result's
/// "Start Treatment" action).
class CreateHealPlanUseCase {
  final TreatmentsRepository _repository;

  CreateHealPlanUseCase(this._repository);

  Future<ApiResult<TreatmentPlanEntity>> call(String scanId) =>
      _repository.createPlan(scanId);
}
