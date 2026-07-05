import 'dart:convert';
import 'dart:ui';

import '../../../../core/localization/l10n.dart';
import '../../../../core/notifications/local_notifications_service.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../domain/entities/treatment_plan_entity.dart';
import '../../domain/services/treatment_reminder_scheduler.dart';

/// Schedules treatment-task reminders over [LocalNotificationsService].
///
/// For each incomplete task it schedules a bounded, deterministic series: the
/// first reminder at [_firstReminderHour] on the task's due day, then one every
/// [_intervalHours] hours, up to [_maxRemindersPerTask]. The whole plan is
/// rebuilt on every sync, so completing a task or cancelling a plan drops its
/// reminders. Cancellation reads the OS-persisted pending list (filtered by the
/// `planId` in each payload), so no separate registry has to be kept in sync.
class TreatmentReminderSchedulerImpl implements TreatmentReminderScheduler {
  final LocalNotificationsService _notifications;
  final AppPreferences _prefs;

  TreatmentReminderSchedulerImpl(this._notifications, this._prefs);

  static const _firstReminderHour = 9; // 09:00 local on the due day
  static const _intervalHours = 5;
  static const _maxRemindersPerTask = 6; // ~25h window; app re-syncs extend it

  @override
  Future<void> syncPlan(TreatmentPlanEntity plan) async {
    // Rebuild from scratch so completed tasks / cancelled plans drop out.
    await cancelPlan(plan.id);
    if (plan.status != TreatmentPlanStatus.active) return;

    final l10n = _l10n();
    final now = DateTime.now();
    for (final step in plan.steps) {
      if (step.isCompleted) continue;
      final times = _reminderTimes(step.scheduledAt, now);
      final body = step.title.isNotEmpty
          ? step.title
          : l10n.notifTreatmentReminderBody;
      final payload = jsonEncode({'planId': plan.id, 'stepId': step.id});
      for (var i = 0; i < times.length; i++) {
        await _notifications.schedule(
          id: _idFor(plan.id, step.id, i),
          when: times[i],
          title: l10n.notifTreatmentReminderTitle,
          body: body,
          payload: payload,
        );
      }
    }
  }

  @override
  Future<void> cancelPlan(String planId) {
    return _notifications.cancelWhere((data) => data['planId'] == planId);
  }

  /// Future reminder slots for a task due on [dueDate]: 09:00 on the due day,
  /// then every [_intervalHours] hours, keeping only times still ahead of
  /// [now]. Anchoring to the due day (not "now") keeps re-syncs idempotent — a
  /// reopened app never fires a fresh burst of reminders.
  List<DateTime> _reminderTimes(DateTime dueDate, DateTime now) {
    final anchor = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      _firstReminderHour,
    );
    final times = <DateTime>[];
    for (var k = 0; k < _maxRemindersPerTask; k++) {
      final time = anchor.add(Duration(hours: _intervalHours * k));
      if (time.isAfter(now)) times.add(time);
    }
    return times;
  }

  /// Deterministic id per (plan, task, occurrence). Cancellation matches on the
  /// payload rather than recomputing this, so cross-run stability isn't needed.
  int _idFor(String planId, String stepId, int occurrence) {
    return '$planId|$stepId|$occurrence'.hashCode & 0x7fffffff;
  }

  AppLocalizations _l10n() {
    // Scheduling happens outside the widget tree, so resolve the saved language
    // directly. Guard to the supported set — lookupAppLocalizations throws on
    // any other code — falling back to English (also the follow-system case).
    final code = _prefs.languageCode == 'ar' ? 'ar' : 'en';
    return lookupAppLocalizations(Locale(code));
  }
}
