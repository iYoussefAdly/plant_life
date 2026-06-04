class ReminderEntity {
  final String id;
  final String treatmentPlanId;
  final String scanResultId;
  final DateTime scheduledAt;
  final bool isDismissed;

  const ReminderEntity({
    required this.id,
    required this.treatmentPlanId,
    required this.scanResultId,
    required this.scheduledAt,
    this.isDismissed = false,
  });
}
