import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../localization/l10n.dart';

/// Formats a date as a short month + day (e.g. `Jul 1` / `١ يوليو`).
/// Locale-aware via `Intl.defaultLocale`, which [LocaleCubit] keeps in sync
/// with the app language.
String formatShortDate(DateTime date) => DateFormat.MMMd().format(date);

/// Formats a price in Egyptian pounds, e.g. `125 EGP` / `125 ج.م`.
String formatPrice(num value) {
  final str = value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
  final isArabic = Intl.defaultLocale?.startsWith('ar') ?? false;
  return isArabic ? '$str ج.م' : '$str EGP';
}

/// Relative "time ago" label, e.g. `just now`, `5m ago`, `3h ago`, `2d ago`.
/// Takes a [BuildContext] so the label follows the app language.
String formatTimeAgo(BuildContext context, DateTime timestamp) {
  final l10n = context.l10n;
  final diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 1) return l10n.timeJustNow;
  if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
  return l10n.timeDaysAgo(diff.inDays);
}
