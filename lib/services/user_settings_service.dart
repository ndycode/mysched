import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/constants.dart';
import '../env.dart';
import 'user_scope.dart';
import '../utils/app_log.dart';

/// Model for user settings that sync to Supabase.
class UserSettings {
  // Appearance
  final String weekStartDay;
  final bool use24HourFormat;
  final bool hapticFeedback;
  
  // Notifications - basic
  final bool classAlarms;
  final bool appNotifs;
  final bool quietWeek;
  final bool verboseLogging;
  
  // Notifications - timing
  final int classLeadMinutes;
  final int snoozeMinutes;
  final int reminderLeadMinutes;
  
  // Notifications - DND
  final bool dndEnabled;
  final String dndStartTime;
  final String dndEndTime;
  
  // Alarm settings
  final int alarmVolume;
  final bool alarmVibration;
  final String alarmRingtone;
  
  // Sync
  final int autoRefreshMinutes;

  const UserSettings({
    // Appearance
    this.weekStartDay = 'monday',
    this.use24HourFormat = false,
    this.hapticFeedback = true,
    // Notifications - basic
    this.classAlarms = true,
    this.appNotifs = true,
    this.quietWeek = false,
    this.verboseLogging = false,
    // Notifications - timing
    this.classLeadMinutes = 5,
    this.snoozeMinutes = 5,
    this.reminderLeadMinutes = 0,
    // Notifications - DND
    this.dndEnabled = false,
    this.dndStartTime = '22:00',
    this.dndEndTime = '07:00',
    // Alarm settings
    this.alarmVolume = 80,
    this.alarmVibration = true,
    this.alarmRingtone = 'default',
    // Sync
    this.autoRefreshMinutes = 30,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      weekStartDay: json['week_start_day'] as String? ?? 'monday',
      use24HourFormat: json['use_24_hour_format'] as bool? ?? false,
      hapticFeedback: json['haptic_feedback'] as bool? ?? true,
      classAlarms: json['class_alarms'] as bool? ?? true,
      appNotifs: json['app_notifs'] as bool? ?? true,
      quietWeek: json['quiet_week'] as bool? ?? false,
      verboseLogging: json['verbose_logging'] as bool? ?? false,
      classLeadMinutes: json['class_lead_minutes'] as int? ?? 5,
      snoozeMinutes: json['snooze_minutes'] as int? ?? 5,
      reminderLeadMinutes: json['reminder_lead_minutes'] as int? ?? 0,
      dndEnabled: json['dnd_enabled'] as bool? ?? false,
      dndStartTime: json['dnd_start_time'] as String? ?? '22:00',
      dndEndTime: json['dnd_end_time'] as String? ?? '07:00',
      alarmVolume: json['alarm_volume'] as int? ?? 80,
      alarmVibration: json['alarm_vibration'] as bool? ?? true,
      alarmRingtone: json['alarm_ringtone'] as String? ?? 'default',
      autoRefreshMinutes: json['auto_refresh_minutes'] as int? ?? 30,
    );
  }

  Map<String, dynamic> toJson() => {
    'use_24_hour_format': use24HourFormat,
    'haptic_feedback': hapticFeedback,
    'class_alarms': classAlarms,
    'app_notifs': appNotifs,
    'quiet_week': quietWeek,
    'verbose_logging': verboseLogging,
    'class_lead_minutes': classLeadMinutes,
    'snooze_minutes': snoozeMinutes,
    'reminder_lead_minutes': reminderLeadMinutes,
    'dnd_enabled': dndEnabled,
    'dnd_start_time': dndStartTime,
    'dnd_end_time': dndEndTime,
    'alarm_volume': alarmVolume,
    'alarm_vibration': alarmVibration,
    'alarm_ringtone': alarmRingtone,
    'auto_refresh_minutes': autoRefreshMinutes,
  };

  UserSettings copyWith({
    String? weekStartDay,
    bool? use24HourFormat,
    bool? hapticFeedback,
    bool? classAlarms,
    bool? appNotifs,
    bool? quietWeek,
    bool? verboseLogging,
    int? classLeadMinutes,
    int? snoozeMinutes,
    int? reminderLeadMinutes,
    bool? dndEnabled,
    String? dndStartTime,
    String? dndEndTime,
    int? alarmVolume,
    bool? alarmVibration,
    String? alarmRingtone,
    int? autoRefreshMinutes,
  }) {
    return UserSettings(
      weekStartDay: weekStartDay ?? this.weekStartDay,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      classAlarms: classAlarms ?? this.classAlarms,
      appNotifs: appNotifs ?? this.appNotifs,
      quietWeek: quietWeek ?? this.quietWeek,
      verboseLogging: verboseLogging ?? this.verboseLogging,
      classLeadMinutes: classLeadMinutes ?? this.classLeadMinutes,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      reminderLeadMinutes: reminderLeadMinutes ?? this.reminderLeadMinutes,
      dndEnabled: dndEnabled ?? this.dndEnabled,
      dndStartTime: dndStartTime ?? this.dndStartTime,
      dndEndTime: dndEndTime ?? this.dndEndTime,
      alarmVolume: alarmVolume ?? this.alarmVolume,
      alarmVibration: alarmVibration ?? this.alarmVibration,
      alarmRingtone: alarmRingtone ?? this.alarmRingtone,
      autoRefreshMinutes: autoRefreshMinutes ?? this.autoRefreshMinutes,
    );
  }
}

/// Service for syncing user settings to Supabase.
/// 
/// On login: fetches settings from cloud and applies locally.
/// On change: pushes update to cloud (with local fallback if offline).
class UserSettingsService {
  UserSettingsService._();

  static UserSettingsService? _instance;
  static UserSettingsService get instance {
    _instance ??= UserSettingsService._();
    return _instance!;
  }

  static const String _tableName = 'user_settings';
  
  final ValueNotifier<UserSettings> settings = ValueNotifier(const UserSettings());
  bool _initialized = false;

  /// Initialize and fetch settings from cloud (or local fallback).
  Future<void> init() async {
    if (_initialized) return;
    await _loadFromLocalOrCloud();
    _initialized = true;
  }

  /// Called after login to fetch user's cloud settings.
  Future<void> onLogin() async {
    await _fetchFromCloud();
  }

  /// Called after logout to reset to defaults.
  Future<void> onLogout() async {
    settings.value = const UserSettings();
    final sp = await SharedPreferences.getInstance();
    await _clearLocalSettings(sp);
  }

  Future<void> _loadFromLocalOrCloud() async {
    final sp = await SharedPreferences.getInstance();
    final userId = UserScope.currentUserId();
    
    // Try cloud first if logged in
    if (userId != null) {
      try {
        await _fetchFromCloud();
        return;
      } catch (e) {
        AppLog.debug('UserSettingsService', 'Cloud fetch failed, using local', data: {'error': e.toString()});
      }
    }
    
    // Fallback to local
    settings.value = _loadFromLocal(sp);
  }

  Future<void> _fetchFromCloud() async {
    final userId = UserScope.currentUserId();
    if (userId == null) return;

    try {
      final response = await Env.supa
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        settings.value = UserSettings.fromJson(response);
        await _saveToLocal(settings.value);
        AppLog.debug('UserSettingsService', 'Fetched from cloud');
      } else {
        // No cloud settings yet, push current local settings
        await _pushToCloud(settings.value);
      }
    } catch (e) {
      AppLog.warn('UserSettingsService', 'Cloud fetch error', data: {'error': e.toString()});
    }
  }

  /// Update a setting and sync to cloud.
  Future<void> update(UserSettings Function(UserSettings current) updater) async {
    final newSettings = updater(settings.value);
    settings.value = newSettings;
    
    // Save locally first (immediate)
    await _saveToLocal(newSettings);
    
    // Then push to cloud (async, can fail)
    await _pushToCloud(newSettings);
  }

  Future<void> _pushToCloud(UserSettings settings) async {
    final userId = UserScope.currentUserId();
    if (userId == null) {
      AppLog.debug('UserSettingsService', 'No user logged in, skipping cloud sync');
      return;
    }

    try {
      final data = settings.toJson();
      data['user_id'] = userId;
      data['updated_at'] = DateTime.now().toIso8601String();

      AppLog.debug('UserSettingsService', 'Pushing to cloud', data: {'userId': userId});
      
      await Env.supa
          .from(_tableName)
          .upsert(data, onConflict: 'user_id');
      
      AppLog.debug('UserSettingsService', 'Push successful');
    } catch (e, stack) {
      AppLog.error('UserSettingsService', 'Cloud push failed', error: e, stack: stack);
    }
  }

  UserSettings _loadFromLocal(SharedPreferences sp) {
    return UserSettings(
      weekStartDay: sp.getString(AppConstants.keyWeekStartDay) ?? AppConstants.defaultWeekStartDay,
      use24HourFormat: sp.getBool(AppConstants.keyUse24HourFormat) ?? false,
      hapticFeedback: sp.getBool(AppConstants.keyHapticFeedback) ?? AppConstants.defaultHapticFeedback,
      classAlarms: sp.getBool(AppConstants.keyClassAlarms) ?? true,
      appNotifs: sp.getBool(AppConstants.keyAppNotifs) ?? true,
      quietWeek: sp.getBool(AppConstants.keyQuietWeek) ?? false,
      verboseLogging: sp.getBool(AppConstants.keyVerboseLogging) ?? false,
      classLeadMinutes: sp.getInt(AppConstants.keyLeadMinutes) ?? AppConstants.defaultLeadMinutes,
      snoozeMinutes: sp.getInt(AppConstants.keySnoozeMinutes) ?? AppConstants.defaultSnoozeMinutes,
      reminderLeadMinutes: sp.getInt(AppConstants.keyReminderLeadMinutes) ?? AppConstants.defaultReminderLeadMinutes,
      dndEnabled: sp.getBool(AppConstants.keyDndEnabled) ?? AppConstants.defaultDndEnabled,
      dndStartTime: sp.getString(AppConstants.keyDndStartTime) ?? AppConstants.defaultDndStartTime,
      dndEndTime: sp.getString(AppConstants.keyDndEndTime) ?? AppConstants.defaultDndEndTime,
      alarmVolume: sp.getInt(AppConstants.keyAlarmVolume) ?? AppConstants.defaultAlarmVolume,
      alarmVibration: sp.getBool(AppConstants.keyAlarmVibration) ?? AppConstants.defaultAlarmVibration,
      alarmRingtone: sp.getString(AppConstants.keyAlarmRingtone) ?? AppConstants.defaultAlarmRingtone,
      autoRefreshMinutes: sp.getInt(AppConstants.keyAutoRefreshMinutes) ?? AppConstants.defaultAutoRefreshMinutes,
    );
  }

  Future<void> _saveToLocal(UserSettings s) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(AppConstants.keyWeekStartDay, s.weekStartDay);
    await sp.setBool(AppConstants.keyUse24HourFormat, s.use24HourFormat);
    await sp.setBool(AppConstants.keyHapticFeedback, s.hapticFeedback);
    await sp.setBool(AppConstants.keyClassAlarms, s.classAlarms);
    await sp.setBool(AppConstants.keyAppNotifs, s.appNotifs);
    await sp.setBool(AppConstants.keyQuietWeek, s.quietWeek);
    await sp.setBool(AppConstants.keyVerboseLogging, s.verboseLogging);
    await sp.setInt(AppConstants.keyLeadMinutes, s.classLeadMinutes);
    await sp.setInt(AppConstants.keySnoozeMinutes, s.snoozeMinutes);
    await sp.setInt(AppConstants.keyReminderLeadMinutes, s.reminderLeadMinutes);
    await sp.setBool(AppConstants.keyDndEnabled, s.dndEnabled);
    await sp.setString(AppConstants.keyDndStartTime, s.dndStartTime);
    await sp.setString(AppConstants.keyDndEndTime, s.dndEndTime);
    await sp.setInt(AppConstants.keyAlarmVolume, s.alarmVolume);
    await sp.setBool(AppConstants.keyAlarmVibration, s.alarmVibration);
    await sp.setString(AppConstants.keyAlarmRingtone, s.alarmRingtone);
    await sp.setInt(AppConstants.keyAutoRefreshMinutes, s.autoRefreshMinutes);
  }

  Future<void> _clearLocalSettings(SharedPreferences sp) async {
    await sp.remove(AppConstants.keyWeekStartDay);
    await sp.remove(AppConstants.keyHapticFeedback);
    await sp.remove(AppConstants.keyReminderLeadMinutes);
    await sp.remove(AppConstants.keyDndEnabled);
    await sp.remove(AppConstants.keyDndStartTime);
    await sp.remove(AppConstants.keyDndEndTime);
    await sp.remove(AppConstants.keyAutoRefreshMinutes);
  }

  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }
}
