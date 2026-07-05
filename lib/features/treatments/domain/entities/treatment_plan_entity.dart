import 'treatment_day_entity.dart';
import 'treatment_step_entity.dart';

enum TreatmentPlanStatus { active, completed, cancelled }

class TreatmentPlanEntity {
  final String id;
  final String title;
  final String description;
  final TreatmentPlanStatus status;

  /// The scan this plan was created from — used to open the Recovery screen.
  final String scanId;
  final List<TreatmentStepEntity> steps;
  final DateTime createdAt;

  /// Product names the backend recommends for this treatment. Used to offer a
  /// "Search in Store" shortcut where a product is mentioned.
  final List<String> recommendedProducts;

  const TreatmentPlanEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.scanId,
    required this.steps,
    required this.createdAt,
    this.recommendedProducts = const [],
  });

  double get progress {
    if (steps.isEmpty) return 0;
    return steps.where((s) => s.isCompleted).length / steps.length;
  }

  /// Steps grouped by [TreatmentStepEntity.dayNumber], ordered ascending.
  List<TreatmentDayEntity> get days {
    final grouped = <int, List<TreatmentStepEntity>>{};
    for (final step in steps) {
      grouped.putIfAbsent(step.dayNumber, () => []).add(step);
    }
    final dayNumbers = grouped.keys.toList()..sort();
    return dayNumbers
        .map((d) => TreatmentDayEntity(dayNumber: d, tasks: grouped[d]!))
        .toList();
  }

  /// Returns a copy with the given step's completion flipped — used for the
  /// optimistic UI update while the toggle request is in flight.
  TreatmentPlanEntity copyWithStep(String stepId, {required bool isCompleted}) {
    return TreatmentPlanEntity(
      id: id,
      title: title,
      description: description,
      status: status,
      scanId: scanId,
      steps: steps
          .map((s) =>
              s.id == stepId ? s.copyWith(isCompleted: isCompleted) : s)
          .toList(),
      createdAt: createdAt,
      recommendedProducts: recommendedProducts,
    );
  }
}
