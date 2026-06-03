class TreatmentTaskEntity {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime scheduledAt;

  const TreatmentTaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.scheduledAt,
  });
}
