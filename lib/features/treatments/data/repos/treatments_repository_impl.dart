import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../domain/entities/treatment_plan_entity.dart';
import '../../domain/repos/treatments_repository.dart';
import '../datasources/treatments_data_source.dart';

class TreatmentsRepositoryImpl implements TreatmentsRepository {
  final TreatmentsDataSource _dataSource;

  TreatmentsRepositoryImpl(this._dataSource);

  @override
  Future<ApiResult<List<TreatmentPlanEntity>>> getTreatmentPlans() async {
    try {
      return Success(await _dataSource.getPlans());
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<TreatmentPlanEntity>> getTreatmentDetail(
    String planId,
  ) async {
    try {
      return Success(await _dataSource.getPlanDetail(planId));
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<TreatmentPlanEntity>> toggleStepCompletion({
    required String planId,
    required String stepId,
    required bool isCompleted,
  }) async {
    // The step id carries the task's index in the backend `tasks` array, which
    // is how the toggle endpoint identifies a task. `isCompleted` is unused:
    // the endpoint is a pure toggle and returns the updated plan.
    final taskIndex = int.tryParse(stepId);
    if (taskIndex == null) {
      return const Error(ServerFailure('Invalid task reference'));
    }
    try {
      return Success(await _dataSource.toggleTask(planId, taskIndex));
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }
}
