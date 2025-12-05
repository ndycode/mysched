/// Centralized app-wide constants.
class AppConstants {
  AppConstants._();

  /// The display name of the application.
  static const String appName = 'MySched';

  /// Default notification lead time in minutes.
  static const int defaultLeadMinutes = 5;

  /// Default snooze duration in minutes.
  static const int defaultSnoozeMinutes = 5;

  /// SharedPreferences keys for settings.
  static const String keyClassAlarms = 'class_alarms';
  static const String keyAppNotifs = 'app_notifs';
  static const String keyQuietWeek = 'quiet_week_enabled';
  static const String keyVerboseLogging = 'alarm_verbose_logging';
  static const String keyLeadMinutes = 'notifLeadMinutes';
  static const String keySnoozeMinutes = 'snoozeMinutes';
  static const String keyAlarmVolume = 'alarm_volume';
  static const String keyAlarmVibration = 'alarm_vibration';
  static const String keyAlarmRingtone = 'alarm_ringtone';

  /// Default alarm settings
  static const int defaultAlarmVolume = 80;
  static const bool defaultAlarmVibration = true;
  static const String defaultAlarmRingtone = 'default';

  // ─────────────────────────────────────────────────────────────────────────
  // Validation Constants (non-UI)
  // ─────────────────────────────────────────────────────────────────────────

  /// Minimum password length for registration
  static const int minPasswordLength = 8;

  /// Minimum password length for login (legacy accounts)
  static const int minPasswordLengthLogin = 6;

  // ─────────────────────────────────────────────────────────────────────────
  // Image Upload Constants (non-UI)
  // ─────────────────────────────────────────────────────────────────────────

  /// Maximum width for uploaded images
  static const double imageMaxWidth = 1200;

  /// JPEG quality for uploaded images (0-100)
  static const int imageQuality = 85;
}


