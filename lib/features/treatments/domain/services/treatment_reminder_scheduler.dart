import '../entities/treatment_plan_entity.dart';

/// Schedules and cancels on-device reminders for a plan's tasks. The
/// implementation lives in the data layer over the platform notification
/// service; the domain only depends on this pure contract.
abstract interface class TreatmentReminderScheduler {
  /// Rebuilds all reminders for [plan]: cancels the plan's existing reminders,
  /// then — for an active plan — schedules the recurring reminder series for
  /// each incomplete task. A completed/cancelled plan (or completed task) ends
  /// up with no reminders, so this one call keeps notifications in sync with
  /// task completion.
  Future<void> syncPlan(TreatmentPlanEntity plan);

  /// Cancels every reminder belonging to [planId].
  Future<void> cancelPlan(String planId);
}
