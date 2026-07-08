import '../../domain/entities/disease_entity.dart';
import '../../domain/entities/scan_result_entity.dart';

class ScanModel extends ScanResultEntity {
  const ScanModel({
    required super.id,
    required super.imagePath,
    required super.status,
    required super.diseases,
    required super.scannedAt,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>? ?? const {};
    final isInfected = result['is_infected'] as bool? ??
        (result['tree_status'] as String?)?.toLowerCase() == 'diseased';

    final images = json['images'] as List?;
    final firstImage = (images != null && images.isNotEmpty)
        ? images.first as Map<String, dynamic>?
        : null;

    return ScanModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      imagePath: firstImage?['url'] as String? ?? '',
      status: isInfected ? ScanStatus.diseased : ScanStatus.healthy,
      diseases: isInfected ? _diseases(result) : const [],
      scannedAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
              DateTime.now(),
    );
  }

  /// Parses the AI model service's `/analyze` response (used for camera
  /// captures): `{ source, images_count, leaves_count, result, confidence }`.
  ///
  /// `result` is the predicted class (e.g. `Early_blight` / `healthy`) and
  /// `confidence` its score. This service returns no persisted scan, so there
  /// is no id/image URL. If `result` ever arrives object-shaped, fall back to
  /// the standard [ScanModel.fromJson] parsing.
  factory ScanModel.fromCameraJson(Map<String, dynamic> json) {
    final rawResult = json['result'];
    if (rawResult is Map<String, dynamic>) {
      return ScanModel.fromJson(json);
    }

    final label = rawResult?.toString().trim() ?? '';
    final isHealthy =
        label.isEmpty || label.toLowerCase().contains('healthy');
    final confidence = _normalizeConfidence(json['confidence'] as num?);

    return ScanModel(
      id: '',
      imagePath: '',
      status: isHealthy ? ScanStatus.healthy : ScanStatus.diseased,
      diseases: isHealthy
          ? const []
          : [
              DiseaseEntity(
                name: _prettify(label),
                confidence: confidence,
                // The model service doesn't report severity — the UI renders 0%.
                severityPercent: 0,
              ),
            ],
      scannedAt: DateTime.now(),
    );
  }

  /// Builds the disease list from `per_image_details`, falling back to the
  /// overall `main_disease` + `avg_severity_all_images` when details are absent.
  static List<DiseaseEntity> _diseases(Map<String, dynamic> result) {
    final details = result['per_image_details'] as List?;
    if (details != null && details.isNotEmpty) {
      final diseases = <DiseaseEntity>[];
      for (final raw in details.whereType<Map<String, dynamic>>()) {
        final name = raw['disease'] as String? ?? '';
        if (name.isEmpty || name.toLowerCase() == 'healthy') continue;
        diseases.add(
          DiseaseEntity(
            name: _prettify(name),
            confidence: _normalizeConfidence(raw['confidence'] as num?),
            severityPercent: (raw['severity_percent'] as num?)?.toDouble() ?? 0,
          ),
        );
      }
      if (diseases.isNotEmpty) return diseases;
    }

    final main = result['main_disease'] as String?;
    if (main != null && main.isNotEmpty && main.toLowerCase() != 'healthy') {
      return [
        DiseaseEntity(
          name: _prettify(main),
          confidence: 1,
          severityPercent:
              (result['avg_severity_all_images'] as num?)?.toDouble() ?? 0,
        ),
      ];
    }
    return const [];
  }

  /// Confidence comes back inconsistently — sometimes a 0–1 fraction (e.g.
  /// 0.98), sometimes a 0–100 percentage (e.g. 99.95). Normalize to a 0–1
  /// fraction so the UI's `* 100` always yields a valid percentage.
  static double _normalizeConfidence(num? raw) {
    final value = raw?.toDouble() ?? 0;
    final fraction = value > 1 ? value / 100 : value;
    return fraction.clamp(0.0, 1.0);
  }

  /// `Early_blight` -> `Early Blight`.
  static String _prettify(String raw) {
    return raw
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
