import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/usecases/get_task_detail_usecase.dart';
import 'task_detail_state.dart';

/// Drives the task-detail bottom sheet: loads one task's full details on open.
class TaskDetailCubit extends Cubit<TaskDetailState> {
  final GetTaskDetailUseCase _getTaskDetail;

  String _planId = '';
  int _taskIndex = 0;

  TaskDetailCubit(this._getTaskDetail) : super(const TaskDetailLoading());

  Future<void> load(String planId, int taskIndex) async {
    _planId = planId;
    _taskIndex = taskIndex;
    emit(const TaskDetailLoading());
    final result = await _getTaskDetail(planId, taskIndex);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(TaskDetailLoaded(data));
      case Error(:final failure):
        emit(TaskDetailError(failure.message));
    }
  }

  Future<void> retry() => load(_planId, _taskIndex);
}
