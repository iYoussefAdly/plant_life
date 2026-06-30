class DiseaseEntity {
  final String name;

  /// Model confidence, 0.0–1.0.
  final double confidence;

  /// Infection severity as a percentage, 0–100 (from the backend result).
  final double severityPercent;

  const DiseaseEntity({
    required this.name,
    required this.confidence,
    required this.severityPercent,
  });
}
