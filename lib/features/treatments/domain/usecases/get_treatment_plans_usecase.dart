import '../../../../core/errors/api_result.dart';
import '../entities/treatment_plan_entity.dart';
import '../repos/treatments_repository.dart';

class GetTreatmentPlansUseCase {
  final TreatmentsRepository _repository;

  GetTreatmentPlansUseCase(this._repository);

  Future<ApiResult<List<TreatmentPlanEntity>>> call() {
    return _repository.getTreatmentPlans();
  }
}
