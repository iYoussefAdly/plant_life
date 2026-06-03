import 'treatment_step_entity.dart';

class TreatmentPlanEntity {
  final String id;
  final String title;
  final String description;
  final String plantName;
  final List<TreatmentStepEntity> steps;
  final DateTime createdAt;

  const TreatmentPlanEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.plantName,
    required this.steps,
    required this.createdAt,
  });

  double get progress {
    if (steps.isEmpty) return 0;
    return steps.where((s) => s.isCompleted).length / steps.length;
  }

  TreatmentPlanEntity copyWithStep(String stepId, {required bool isCompleted}) {
    return TreatmentPlanEntity(
      id: id,
      title: title,
      description: description,
      plantName: plantName,
      steps: steps.map((s) {
        if (s.id == stepId) return s.copyWith(isCompleted: isCompleted);
        return s;
      }).toList(),
      createdAt: createdAt,
    );
  }
}
