class WeeklyImageEntity {
  final int weekNumber;
  final String? imagePath;
  final String notes;
  final DateTime date;

  const WeeklyImageEntity({
    required this.weekNumber,
    this.imagePath,
    required this.notes,
    required this.date,
  });
}
