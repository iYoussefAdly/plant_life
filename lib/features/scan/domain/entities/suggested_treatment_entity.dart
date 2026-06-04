class SuggestedTreatmentEntity {
  final String treatmentPlanId;
  final String title;
  final String summary;
  final String estimatedDuration;
  final int totalSteps;

  const SuggestedTreatmentEntity({
    required this.treatmentPlanId,
    required this.title,
    required this.summary,
    required this.estimatedDuration,
    required this.totalSteps,
  });
}
