import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../storage/app_preferences.dart';

/// App-level locale state. `null` means "follow the system locale" (the user
/// has never picked a language). Injected with [AppPreferences] directly —
/// like `AppEventBus`/`TokenStorage`, this is core infrastructure state, not
/// feature business logic, so it sits outside the use-case contract.
class LocaleCubit extends Cubit<Locale?> {
  static const supported = [Locale('en'), Locale('ar')];

  final AppPreferences _prefs;

  LocaleCubit(this._prefs) : super(_initialLocale(_prefs)) {
    _syncIntl(state);
  }

  static Locale? _initialLocale(AppPreferences prefs) {
    final code = prefs.languageCode;
    return code == null ? null : Locale(code);
  }

  /// Keeps `intl` date formatting (used by context-free helpers such as
  /// `formatShortDate`) in step with the app locale.
  static void _syncIntl(Locale? locale) {
    Intl.defaultLocale = locale?.languageCode;
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setLanguageCode(locale.languageCode);
    _syncIntl(locale);
    emit(locale);
  }
}
