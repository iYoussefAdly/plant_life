import '../../domain/entities/task_detail_entity.dart';

class TaskDetailModel extends TaskDetailEntity {
  const TaskDetailModel({
    required super.taskIndex,
    required super.planId,
    required super.disease,
    required super.planStatus,
    required super.day,
    required super.dayTitle,
    required super.title,
    required super.description,
    required super.why,
    required super.tips,
    required super.warnings,
    required super.estimatedTime,
    required super.completed,
    required super.completedAt,
    required super.scheduledDate,
  });

  /// Parses the `data` object of the task-detail response:
  /// `{ taskIndex, planId, disease, planStatus, task: { ... } }`.
  factory TaskDetailModel.fromData(Map<String, dynamic> data) {
    final task = (data['task'] as Map?)?.cast<String, dynamic>() ?? const {};
    return TaskDetailModel(
      taskIndex: (data['taskIndex'] as num?)?.toInt() ?? 0,
      planId: (data['planId'] ?? '').toString(),
      disease: data['disease'] as String? ?? '',
      planStatus: data['planStatus'] as String? ?? '',
      day: (task['day'] as num?)?.toInt() ?? 1,
      dayTitle: task['dayTitle'] as String? ?? '',
      title: task['title'] as String? ?? '',
      description: task['description'] as String? ?? '',
      why: task['why'] as String? ?? '',
      tips: _stringList(task['tips']),
      warnings: _stringList(task['warnings']),
      estimatedTime: task['estimatedTime'] as String? ?? '',
      completed: task['completed'] as bool? ?? false,
      completedAt:
          DateTime.tryParse(task['completedAt'] as String? ?? '')?.toLocal(),
      scheduledDate:
          DateTime.tryParse(task['scheduledDate'] as String? ?? '')?.toLocal(),
    );
  }

  /// Coerces a backend list into non-empty trimmed strings, tolerating either
  /// plain strings or objects that stringify meaningfully.
  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
