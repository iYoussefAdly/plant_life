import '../../../../core/errors/api_result.dart';
import '../../../treatments/domain/entities/treatment_plan_entity.dart';
import '../../../treatments/domain/repos/treatments_repository.dart';
import '../entities/notification_entity.dart';

/// Builds reminder notifications on the device from the user's active treatment
/// plans, one per incomplete task scheduled for today.
///
/// The backend only creates `task_reminder` notifications via a scheduler at
/// task-due times and nothing on-demand, so a freshly started plan would show
/// no reminders. These derived reminders fill that gap using existing endpoints
/// only; they are merged with (and deduped against) real backend notifications
/// by [NotificationsCubit]. A reminder disappears once its task is completed.
class GetTreatmentRemindersUseCase {
  final TreatmentsRepository _treatmentsRepository;

  GetTreatmentRemindersUseCase(this._treatmentsRepository);

  Future<List<NotificationEntity>> call() async {
    final result = await _treatmentsRepository.getTreatmentPlans();
    final plans = switch (result) {
      Success(:final data) => data,
      Error() => const <TreatmentPlanEntity>[],
    };

    final now = DateTime.now();
    final reminders = <NotificationEntity>[];
    for (final plan
        in plans.where((p) => p.status == TreatmentPlanStatus.active)) {
      for (final step in plan.steps) {
        if (step.isCompleted) continue;
        if (!_isSameDay(step.scheduledAt, now)) continue;
        reminders.add(
          NotificationEntity(
            // Stable id so local read-state and dedupe survive reloads.
            id: 'reminder:${plan.id}:${step.id}',
            type: NotificationType.treatmentTask,
            title: 'Treatment task due today',
            message: step.title,
            timestamp: step.scheduledAt,
            relatedId: plan.id,
            isLocal: true,
          ),
        );
      }
    }
    return reminders;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
