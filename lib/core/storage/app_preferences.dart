import 'package:shared_preferences/shared_preferences.dart';

/// Plain (non-secure) local preferences: onboarding completion and the chosen
/// app language. Tokens stay in [TokenStorage]/secure storage — nothing here
/// is sensitive. Deliberately NOT cleared on logout: onboarding and language
/// are device-level settings, not session state.
class AppPreferences {
  static const _kOnboardingCompleted = 'onboarding_completed';
  static const _kLanguageCode = 'language_code';
  static const _kSensorDeviceId = 'sensor_device_id';

  final SharedPreferences _prefs;

  AppPreferences(this._prefs);

  bool get onboardingCompleted =>
      _prefs.getBool(_kOnboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted() =>
      _prefs.setBool(_kOnboardingCompleted, true);

  /// The saved language code ('en' / 'ar'), or null when the user has never
  /// chosen one (the app then follows the system locale).
  String? get languageCode => _prefs.getString(_kLanguageCode);

  Future<void> setLanguageCode(String code) =>
      _prefs.setString(_kLanguageCode, code);

  /// The sensor Device ID that unlocks the Sensors feature, or null when the
  /// user hasn't configured one yet. Trimmed; empty is treated as unset.
  String? get sensorDeviceId {
    final id = _prefs.getString(_kSensorDeviceId)?.trim();
    return (id == null || id.isEmpty) ? null : id;
  }

  Future<void> setSensorDeviceId(String deviceId) =>
      _prefs.setString(_kSensorDeviceId, deviceId.trim());

  Future<void> clearSensorDeviceId() => _prefs.remove(_kSensorDeviceId);
}
