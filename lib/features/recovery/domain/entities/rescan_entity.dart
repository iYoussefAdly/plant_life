/// A single follow-up scan of the plant, used to track recovery over time.
class RescanEntity {
  final String id;
  final String imageUrl;

  /// Infection severity at this rescan, 0–100.
  final double severityPercent;

  /// Whether this rescan improved vs. the previous one.
  final bool improved;

  /// Change in severity vs. the previous scan (negative = improvement).
  final double severityDelta;

  final DateTime capturedAt;

  const RescanEntity({
    required this.id,
    required this.imageUrl,
    required this.severityPercent,
    required this.improved,
    required this.severityDelta,
    required this.capturedAt,
  });
}
