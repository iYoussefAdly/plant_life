import 'treatment_step_entity.dart';

/// A derived grouping of treatment steps that share the same [dayNumber].
///
/// This is computed from a plan's flat step list — the steps remain the
/// single source of truth, so a day is considered completed automatically
/// when every task inside it is completed.
class TreatmentDayEntity {
  final int dayNumber;
  final List<TreatmentStepEntity> tasks;

  const TreatmentDayEntity({
    required this.dayNumber,
    required this.tasks,
  });

  bool get isCompleted =>
      tasks.isNotEmpty && tasks.every((t) => t.isCompleted);

  int get completedCount => tasks.where((t) => t.isCompleted).length;
}
