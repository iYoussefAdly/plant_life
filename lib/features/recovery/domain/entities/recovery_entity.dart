import 'rescan_entity.dart';

class RecoveryEntity {
  /// The original scan the heal plan was created from (parent of the rescans).
  final String scanId;
  final String title;

  /// Overall recovery, 0.0–1.0 (derived from severity reduction).
  final double progressPercent;
  final List<RescanEntity> rescans;

  const RecoveryEntity({
    required this.scanId,
    required this.title,
    required this.progressPercent,
    required this.rescans,
  });
}
