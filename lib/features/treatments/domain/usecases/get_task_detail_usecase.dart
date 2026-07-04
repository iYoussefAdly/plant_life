import '../../../../core/errors/api_result.dart';
import '../entities/task_detail_entity.dart';
import '../repos/treatments_repository.dart';

/// Fetches the full details of a single task within a plan.
class GetTaskDetailUseCase {
  final TreatmentsRepository _repository;

  GetTaskDetailUseCase(this._repository);

  Future<ApiResult<TaskDetailEntity>> call(String planId, int taskIndex) =>
      _repository.getTaskDetail(planId, taskIndex);
}
