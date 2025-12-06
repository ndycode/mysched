import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/constants.dart';

/// Centralized time formatting utility that respects user preference.
/// 
/// Uses a [ValueNotifier] so screens can react to changes via
/// [ValueListenableBuilder] or by calling [addListener].
class AppTimeFormat {
  AppTimeFormat._();

  /// Notifier that broadcasts when the time format preference changes.
  /// Screens can wrap time-displaying widgets with:
  /// ```dart
  /// ValueListenableBuilder<bool>(
  ///   valueListenable: AppTimeFormat.notifier,
  ///   builder: (context, use24Hour, child) => ...
  /// )
  /// ```
  static final ValueNotifier<bool> notifier = ValueNotifier<bool>(false);

  static bool _initialized = false;

  /// Initialize from SharedPreferences. Call early in app startup.
  static Future<void> init() async {
    if (_initialized) return;
    final sp = await SharedPreferences.getInstance();
    notifier.value = sp.getBool(AppConstants.keyUse24HourFormat) ?? false;
    _initialized = true;
  }

  /// Current preference value.
  static bool get use24Hour => notifier.value;

  /// Update preference (also persists to SharedPreferences).
  static Future<void> setUse24Hour(bool value) async {
    notifier.value = value;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(AppConstants.keyUse24HourFormat, value);
  }

  /// Synchronously update the in-memory value (for immediate UI updates).
  static void updateValue(bool value) {
    notifier.value = value;
  }

  /// Format a single time.
  /// 
  /// Examples:
  /// - 12-hour: "8:00 AM"
  /// - 24-hour: "08:00"
  static String formatTime(DateTime time) {
    final pattern = notifier.value ? 'HH:mm' : 'h:mm a';
    return DateFormat(pattern).format(time);
  }

  /// Format a time range.
  /// 
  /// Examples:
  /// - 12-hour: "8:00 AM - 9:30 AM"
  /// - 24-hour: "08:00 - 09:30"
  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }
}

