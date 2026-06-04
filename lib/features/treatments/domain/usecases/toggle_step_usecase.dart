import '../../../../core/errors/api_result.dart';
import '../entities/treatment_plan_entity.dart';
import '../repos/treatments_repository.dart';

class ToggleStepUseCase {
  final TreatmentsRepository _repository;

  ToggleStepUseCase(this._repository);

  Future<ApiResult<TreatmentPlanEntity>> call({
    required String planId,
    required String stepId,
    required bool isCompleted,
  }) {
    return _repository.toggleStepCompletion(
      planId: planId,
      stepId: stepId,
      isCompleted: isCompleted,
    );
  }
}
