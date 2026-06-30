import '../../domain/entities/treatment_plan_entity.dart';
import '../../domain/entities/treatment_step_entity.dart';

class HealPlanModel extends TreatmentPlanEntity {
  const HealPlanModel({
    required super.id,
    required super.title,
    required super.description,
    required super.status,
    required super.scanId,
    required super.steps,
    required super.createdAt,
  });

  factory HealPlanModel.fromJson(Map<String, dynamic> json) {
    final rawTasks = (json['tasks'] as List?) ?? const [];
    final steps = <TreatmentStepEntity>[];
    for (var i = 0; i < rawTasks.length; i++) {
      final task = rawTasks[i];
      if (task is! Map<String, dynamic>) continue;
      steps.add(
        TreatmentStepEntity(
          // The id is the task's index in the backend `tasks` array — the
          // toggle endpoint identifies tasks by index, not by id.
          id: '$i',
          title: task['title'] as String? ?? '',
          description: task['description'] as String? ?? '',
          isCompleted: task['completed'] as bool? ?? false,
          scheduledAt:
              DateTime.tryParse(task['scheduledDate'] as String? ?? '')
                      ?.toLocal() ??
                  DateTime.now(),
          dayNumber: (task['day'] as num?)?.toInt() ?? 1,
        ),
      );
    }

    final disease = json['disease'] as String? ?? '';
    return HealPlanModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: _title(json['disease_display'] as String?, disease),
      description: json['description'] as String? ?? '',
      status: _status(json['status'] as String?),
      scanId: (json['scanId'] ?? json['scan'] ?? '').toString(),
      steps: steps,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
              DateTime.now(),
    );
  }

  /// Backend heal plans are keyed by disease. Prefer a localized
  /// `disease_display` when present, otherwise prettify the machine name
  /// (e.g. `Early_blight` -> `Early Blight`).
  static String _title(String? display, String disease) {
    if (display != null && display.trim().isNotEmpty) return display.trim();
    if (disease.isEmpty) return 'Treatment Plan';
    return disease
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static TreatmentPlanStatus _status(String? status) {
    switch (status) {
      case 'completed':
        return TreatmentPlanStatus.completed;
      case 'cancelled':
        return TreatmentPlanStatus.cancelled;
      case 'active':
      default:
        return TreatmentPlanStatus.active;
    }
  }
}
