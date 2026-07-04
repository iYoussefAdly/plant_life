/// Full details of a single treatment task, returned by
/// `GET /heal-plans/:id/tasks/:taskIndex`. Carries the rich guidance fields
/// (why / tips / warnings / estimated time) that the compact task tile does
/// not show, plus its plan context.
class TaskDetailEntity {
  final int taskIndex;
  final String planId;

  /// Raw disease key of the parent plan (e.g. `Powdery_Mildew`).
  final String disease;
  final String planStatus;

  final int day;
  final String dayTitle;
  final String title;
  final String description;

  /// Why this task matters for the treatment.
  final String why;
  final List<String> tips;
  final List<String> warnings;

  /// Human-readable estimate, e.g. "15 min".
  final String estimatedTime;

  final bool completed;
  final DateTime? completedAt;
  final DateTime? scheduledDate;

  const TaskDetailEntity({
    required this.taskIndex,
    required this.planId,
    required this.disease,
    required this.planStatus,
    required this.day,
    required this.dayTitle,
    required this.title,
    required this.description,
    required this.why,
    required this.tips,
    required this.warnings,
    required this.estimatedTime,
    required this.completed,
    required this.completedAt,
    required this.scheduledDate,
  });

  bool get hasDescription => description.trim().isNotEmpty;
  bool get hasWhy => why.trim().isNotEmpty;
  bool get hasTips => tips.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasEstimatedTime => estimatedTime.trim().isNotEmpty;
  bool get hasDayTitle => dayTitle.trim().isNotEmpty;

  /// True when the backend supplied no extra guidance beyond the title, so the
  /// UI can show a graceful "no further details" message.
  bool get hasExtraDetails =>
      hasDescription ||
      hasWhy ||
      hasTips ||
      hasWarnings ||
      hasEstimatedTime ||
      hasDayTitle;
}
