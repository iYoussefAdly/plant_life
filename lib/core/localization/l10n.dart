import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';

export '../../l10n/generated/app_localizations.dart';

/// Shorthand for the generated localizations: `context.l10n.someKey`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Maps the fixed, data-layer error message constants (see
/// `ApiErrorHandler`/`StoreResponse`) to their localized equivalents at the
/// presentation edge. Unknown messages — e.g. text sent by the backend — are
/// shown as-is.
String localizeMessage(BuildContext context, String message) {
  final l10n = context.l10n;
  return switch (message) {
    'An unexpected error occurred' => l10n.errUnexpected,
    'Connection timed out. Please try again.' => l10n.errTimeout,
    'No internet connection.' => l10n.errNoInternet,
    'Request was cancelled.' => l10n.errCancelled,
    'Something went wrong. Please try again.' => l10n.errGeneric,
    'Invalid server response. Please try again.' => l10n.errInvalidResponse,
    'Please enter a valid email address' => l10n.pleaseEnterValidEmail,
    'Password must be at least 6 characters' => l10n.passwordMinSix,
    'Please enter your name' => l10n.pleaseEnterName,
    'Failed to load dashboard data' => l10n.errLoadDashboard,
    'Failed to load sensor data' => l10n.errLoadSensors,
    'No checkout URL was returned.' => l10n.errNoCheckoutUrl,
    'Could not start a store session.' => l10n.errStoreSession,
    'Invalid task reference' => l10n.errInvalidTask,
    _ => message,
  };
}
