import '../../../../core/errors/api_result.dart';
import '../entities/treatment_plan_entity.dart';
import '../repos/treatments_repository.dart';

class GetTreatmentDetailUseCase {
  final TreatmentsRepository _repository;

  GetTreatmentDetailUseCase(this._repository);

  Future<ApiResult<TreatmentPlanEntity>> call(String planId) {
    return _repository.getTreatmentDetail(planId);
  }
}
