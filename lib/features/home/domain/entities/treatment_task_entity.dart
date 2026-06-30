class TreatmentTaskEntity {
  /// The heal plan this task belongs to (used to open its detail screen).
  final String planId;

  /// The task's id within the plan (used to highlight it on the detail screen).
  final String stepId;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime scheduledAt;

  const TreatmentTaskEntity({
    required this.planId,
    required this.stepId,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.scheduledAt,
  });
}
