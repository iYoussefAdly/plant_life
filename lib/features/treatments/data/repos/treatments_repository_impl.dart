import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../domain/entities/task_detail_entity.dart';
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
  Future<ApiResult<TreatmentPlanEntity>> createPlan(String scanId) async {
    try {
      return Success(await _dataSource.createPlan(scanId));
    } catch (e) {
      // The accept-plan endpoint is not atomic: the backend persists the plan
      // first, then runs a post-creation side effect (a notification) that can
      // currently fail and abort the response with an error. When that happens
      // the plan already exists, so recover by looking it up for this scan and
      // only surface the failure if no such plan is found.
      final recovered = await _findPlanForScan(scanId);
      if (recovered != null) return Success(recovered);
      return Error(ApiErrorHandler.handle(e));
    }
  }

  /// Returns the plan just created for [scanId], if one exists. Used to recover
  /// from a non-atomic accept-plan failure. Looks only at active plans (a freshly
  /// accepted plan is active) so a previously cancelled plan for the same scan is
  /// never returned, and prefers the most recently created match. Lookup failures
  /// are swallowed so the original create error can surface instead.
  Future<TreatmentPlanEntity?> _findPlanForScan(String scanId) async {
    if (scanId.isEmpty) return null;
    try {
      final plans = await _dataSource.getPlans(status: 'active');
      TreatmentPlanEntity? match;
      for (final plan in plans) {
        if (plan.scanId != scanId) continue;
        if (match == null || plan.createdAt.isAfter(match.createdAt)) {
          match = plan;
        }
      }
      return match;
    } catch (_) {
      // Ignore — fall through to the original create failure.
      return null;
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

  @override
  Future<ApiResult<TaskDetailEntity>> getTaskDetail(
    String planId,
    int taskIndex,
  ) async {
    try {
      return Success(await _dataSource.getTaskDetail(planId, taskIndex));
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<TreatmentPlanEntity>> cancelPlan(String planId) async {
    try {
      return Success(await _dataSource.cancelPlan(planId));
    } catch (e) {
      return Error(ApiErrorHandler.handle(e));
    }
  }
}
