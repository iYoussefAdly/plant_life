import '../../domain/entities/rescan_entity.dart';

class RescanModel extends RescanEntity {
  const RescanModel({
    required super.id,
    required super.imageUrl,
    required super.severityPercent,
    required super.improved,
    required super.severityDelta,
    required super.capturedAt,
  });

  factory RescanModel.fromJson(Map<String, dynamic> json) {
    // A rescan combines the scan fields with a `comparison` block. Both shapes
    // are read defensively so a contract tweak is a one-place change.
    final result = json['result'] as Map<String, dynamic>? ?? const {};
    final comparison = json['comparison'] as Map<String, dynamic>? ?? const {};

    final images = json['images'] as List?;
    final firstImage = (images != null &&
            images.isNotEmpty &&
            images.first is Map<String, dynamic>)
        ? images.first as Map<String, dynamic>
        : null;

    final severity = (comparison['currentSeverity'] as num?) ??
        (result['avg_severity_all_images'] as num?) ??
        0;

    return RescanModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      imageUrl: firstImage?['url'] as String? ?? '',
      severityPercent: severity.toDouble(),
      improved: comparison['improved'] as bool? ?? false,
      severityDelta: (comparison['severityDelta'] as num?)?.toDouble() ?? 0,
      capturedAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
              DateTime.now(),
    );
  }
}
