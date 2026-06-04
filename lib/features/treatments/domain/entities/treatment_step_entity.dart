class TreatmentStepEntity {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime scheduledAt;

  const TreatmentStepEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.scheduledAt,
  });

  TreatmentStepEntity copyWith({bool? isCompleted}) {
    return TreatmentStepEntity(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
      scheduledAt: scheduledAt,
    );
  }
}
