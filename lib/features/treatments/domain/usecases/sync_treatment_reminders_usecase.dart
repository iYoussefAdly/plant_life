import '../entities/treatment_plan_entity.dart';
import '../services/treatment_reminder_scheduler.dart';

/// Syncs on-device task reminders with the current state of a plan (schedules
/// incomplete tasks, cancels completed ones / cancelled plans).
class SyncTreatmentRemindersUseCase {
  final TreatmentReminderScheduler _scheduler;

  const SyncTreatmentRemindersUseCase(this._scheduler);

  /// Callers invoke this fire-and-forget, so scheduling failures are swallowed
  /// here rather than surfacing as unobserved async errors — reminders are
  /// best-effort and must never break a treatment flow.
  Future<void> call(TreatmentPlanEntity plan) async {
    try {
      await _scheduler.syncPlan(plan);
    } catch (_) {
      // Ignore — on-device reminders are non-critical.
    }
  }
}
