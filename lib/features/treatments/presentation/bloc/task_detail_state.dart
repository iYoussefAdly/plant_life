import '../../domain/entities/task_detail_entity.dart';

sealed class TaskDetailState {
  const TaskDetailState();
}

class TaskDetailLoading extends TaskDetailState {
  const TaskDetailLoading();
}

class TaskDetailLoaded extends TaskDetailState {
  final TaskDetailEntity task;
  const TaskDetailLoaded(this.task);
}

class TaskDetailError extends TaskDetailState {
  final String message;
  const TaskDetailError(this.message);
}
