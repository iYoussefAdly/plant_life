class TreatmentStepEntity {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime scheduledAt;
  final int dayNumber;

  const TreatmentStepEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.scheduledAt,
    required this.dayNumber,
  });

  /// A task can only be acted on once its scheduled day has arrived — future
  /// days stay locked. Completed tasks are always considered unlocked so a
  /// past completion never appears disabled.
  bool get isUnlocked {
    if (isCompleted) return true;
    final now = DateTime.now();
    final scheduledDay =
        DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day);
    final today = DateTime(now.year, now.month, now.day);
    return !scheduledDay.isAfter(today);
  }

  TreatmentStepEntity copyWith({bool? isCompleted}) {
    return TreatmentStepEntity(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
      scheduledAt: scheduledAt,
      dayNumber: dayNumber,
    );
  }
}
