import 'dart:convert';
import 'dart:ui';

import '../../../../core/localization/l10n.dart';
import '../../../../core/notifications/local_notifications_service.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../domain/entities/treatment_plan_entity.dart';
import '../../domain/services/treatment_reminder_scheduler.dart';

/// Schedules treatment-task reminders over [LocalNotificationsService].
///
/// Each incomplete task gets a bounded, deterministic series of up to
/// [_maxRemindersPerTask] reminders, [_intervalHours] hours apart. A task
/// already due (today or overdue — typically the day-1 task the moment a plan
/// is created) is reminded right away; a task due on a future day gets its
/// first reminder at [_firstReminderHour] on that day.
///
/// A task is only (re)scheduled when it has no reminders queued, so re-syncs on
/// app open don't reset the cadence or re-fire the immediate reminder. That,
/// plus per-task cancellation of completed tasks, keeps reminders in step with
/// completion. Cancellation reads the OS-persisted pending list (filtered by
/// the payload), so no separate registry has to be kept in sync.
class TreatmentReminderSchedulerImpl implements TreatmentReminderScheduler {
  final LocalNotificationsService _notifications;
  final AppPreferences _prefs;

  TreatmentReminderSchedulerImpl(this._notifications, this._prefs);

  static const _firstReminderHour = 9; // 09:00 local for a future due day
  static const _intervalHours = 5;
  static const _maxRemindersPerTask = 6; // ~25h window; app re-syncs extend it
  // Tiny lead so the "immediate" reminder is a real (future) scheduled alarm —
  // which makes it pending, gating re-syncs from firing another one.
  static const _immediateLead = Duration(seconds: 5);

  @override
  Future<void> syncPlan(TreatmentPlanEntity plan) async {
    if (plan.status != TreatmentPlanStatus.active) {
      await cancelPlan(plan.id);
      return;
    }

    final l10n = _l10n();
    final now = DateTime.now();
    for (final step in plan.steps) {
      bool isThisTask(Map<String, dynamic> data) =>
          data['planId'] == plan.id && data['stepId'] == step.id;

      if (step.isCompleted) {
        // Completing a task stops its reminders.
        await _notifications.cancelWhere(isThisTask);
        continue;
      }
      // Leave an existing series alone so re-syncs stay idempotent (no cadence
      // reset, no repeated immediate reminder); only schedule when there's none.
      if (await _notifications.hasPendingWhere(isThisTask)) continue;

      final times = _reminderTimes(step.scheduledAt, now);
      if (times.isEmpty) continue;
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

  /// Reminder slots for a task due on [dueDate], every [_intervalHours] hours.
  /// Already-due tasks start immediately ([now] + a tiny lead); future tasks
  /// start at [_firstReminderHour] on their due day. Only times still ahead of
  /// [now] are kept.
  List<DateTime> _reminderTimes(DateTime dueDate, DateTime now) {
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final anchor = dueDay.isAfter(today)
        ? DateTime(dueDate.year, dueDate.month, dueDate.day, _firstReminderHour)
        : now.add(_immediateLead);

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
