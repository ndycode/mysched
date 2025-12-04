import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/constants.dart';

/// User settings service with persistence and change notifications.
class UserSettings {
  UserSettings._();

  static UserSettings? _instance;
  static UserSettings get instance {
    _instance ??= UserSettings._();
    return _instance!;
  }

  SharedPreferences? _prefs;
  final ValueNotifier<bool> appNotifsEnabled = ValueNotifier(true);
  final ValueNotifier<bool> classAlarmsEnabled = ValueNotifier(true);
  final ValueNotifier<bool> quietWeekEnabled = ValueNotifier(false);
  final ValueNotifier<int> leadMinutes = ValueNotifier(AppConstants.defaultLeadMinutes);
  final ValueNotifier<int> snoozeMinutes = ValueNotifier(AppConstants.defaultSnoozeMinutes);
  final ValueNotifier<bool> verboseLogging = ValueNotifier(false);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    await refresh();
    _initialized = true;
  }

  Future<void> refresh() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;

    appNotifsEnabled.value = prefs.getBool(AppConstants.keyAppNotifs) ?? true;
    classAlarmsEnabled.value = prefs.getBool(AppConstants.keyClassAlarms) ?? true;
    quietWeekEnabled.value = prefs.getBool(AppConstants.keyQuietWeek) ?? false;
    leadMinutes.value = prefs.getInt(AppConstants.keyLeadMinutes) ?? AppConstants.defaultLeadMinutes;
    snoozeMinutes.value = prefs.getInt(AppConstants.keySnoozeMinutes) ?? AppConstants.defaultSnoozeMinutes;
    verboseLogging.value = prefs.getBool(AppConstants.keyVerboseLogging) ?? false;
  }

  Future<void> setAppNotifsEnabled(bool value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyAppNotifs, value);
    appNotifsEnabled.value = value;
  }

  Future<void> setClassAlarmsEnabled(bool value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyClassAlarms, value);
    classAlarmsEnabled.value = value;
  }

  Future<void> setQuietWeekEnabled(bool value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyQuietWeek, value);
    quietWeekEnabled.value = value;
  }

  Future<void> setLeadMinutes(int value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final clamped = value.clamp(1, 120);
    await prefs.setInt(AppConstants.keyLeadMinutes, clamped);
    leadMinutes.value = clamped;
  }

  Future<void> setSnoozeMinutes(int value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final clamped = value.clamp(1, 60);
    await prefs.setInt(AppConstants.keySnoozeMinutes, clamped);
    snoozeMinutes.value = clamped;
  }

  Future<void> setVerboseLogging(bool value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyVerboseLogging, value);
    verboseLogging.value = value;
  }

  /// Reset all settings to defaults.
  Future<void> resetToDefaults() async {
    await setAppNotifsEnabled(true);
    await setClassAlarmsEnabled(true);
    await setQuietWeekEnabled(false);
    await setLeadMinutes(AppConstants.defaultLeadMinutes);
    await setSnoozeMinutes(AppConstants.defaultSnoozeMinutes);
    await setVerboseLogging(false);
  }

  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }
}
