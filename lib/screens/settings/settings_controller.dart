import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/constants.dart';
import '../../services/admin_service.dart';
import '../../services/notification_scheduler.dart';
import '../../services/profile_cache.dart';
import '../../services/theme_controller.dart';
import '../../services/user_settings_service.dart';
import '../../utils/local_notifs.dart';
import '../../utils/time_format.dart';

class SettingsController extends ChangeNotifier {
  SettingsController() {
    _init();
  }

  final ThemeController _themeController = ThemeController.instance;

  bool _loading = true;
  bool get loading => _loading;

  bool _saving = false;
  bool get saving => _saving;

  bool _classAlarms = true;
  bool get classAlarms => _classAlarms;

  bool _appNotifs = true;
  bool get appNotifs => _appNotifs;

  bool _quietWeek = false;
  bool get quietWeek => _quietWeek;

  bool _verboseLogging = false;
  bool get verboseLogging => _verboseLogging;

  int _leadMinutes = AppConstants.defaultLeadMinutes;
  int get leadMinutes => _leadMinutes;

  int _snoozeMinutes = AppConstants.defaultSnoozeMinutes;
  int get snoozeMinutes => _snoozeMinutes;

  int _alarmVolume = AppConstants.defaultAlarmVolume;
  int get alarmVolume => _alarmVolume;

  bool _alarmVibration = AppConstants.defaultAlarmVibration;
  bool get alarmVibration => _alarmVibration;

  String _alarmRingtone = AppConstants.defaultAlarmRingtone;
  String get alarmRingtone => _alarmRingtone;

  bool _use24HourFormat = false;
  bool get use24HourFormat => _use24HourFormat;

  // New settings
  String _weekStartDay = AppConstants.defaultWeekStartDay;
  String get weekStartDay => _weekStartDay;

  bool _hapticFeedback = AppConstants.defaultHapticFeedback;
  bool get hapticFeedback => _hapticFeedback;

  int _reminderLeadMinutes = AppConstants.defaultReminderLeadMinutes;
  int get reminderLeadMinutes => _reminderLeadMinutes;

  bool _dndEnabled = AppConstants.defaultDndEnabled;
  bool get dndEnabled => _dndEnabled;

  String _dndStartTime = AppConstants.defaultDndStartTime;
  String get dndStartTime => _dndStartTime;

  String _dndEndTime = AppConstants.defaultDndEndTime;
  String get dndEndTime => _dndEndTime;

  int _autoRefreshMinutes = AppConstants.defaultAutoRefreshMinutes;
  int get autoRefreshMinutes => _autoRefreshMinutes;

  String? _studentName;
  String? get studentName => _studentName;

  String? _studentEmail;
  String? get studentEmail => _studentEmail;

  String? _avatarUrl;
  String? get avatarUrl => _avatarUrl;

  bool _profileHydrated = false;
  bool get profileHydrated => _profileHydrated;

  bool _adminLoaded = false;
  bool get adminLoaded => _adminLoaded;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  String? _adminError;
  String? get adminError => _adminError;

  AppThemeMode _themeMode = AppThemeMode.system;
  AppThemeMode get themeMode => _themeMode;

  bool? _exactAlarmAllowed;
  bool? get exactAlarmAllowed => _exactAlarmAllowed;

  bool? _notificationsAllowed;
  bool? get notificationsAllowed => _notificationsAllowed;

  bool? _ignoringBatteryOptimizations;
  bool? get ignoringBatteryOptimizations => _ignoringBatteryOptimizations;

  bool _readinessLoading = false;
  bool get readinessLoading => _readinessLoading;

  // Callbacks for UI interactions
  void Function(String message)? onSnack;
  void Function(String message, VoidCallback? onRetry)? onSupportError;
  void Function(int count)? onNewAdminReports;

  void _init() {
    _themeMode = _themeController.currentMode;
    _themeController.mode.addListener(_handleThemeChanged);
    
    _restorePreferences();
    _listenToProfile();
    _bootstrapAdminState();
    _installSnoozeListener();
    _refreshAlarmReadiness();
  }

  @override
  void dispose() {
    _themeController.mode.removeListener(_handleThemeChanged);
    ProfileCache.notifier.removeListener(_onProfileChanged);
    AdminService.instance.role.removeListener(_onAdminRoleChanged);
    AdminService.instance.newReportCount.removeListener(_onAdminCountChanged);
    _removeSnoozeListener();
    super.dispose();
  }

  Future<void> _restorePreferences() async {
    final sp = await SharedPreferences.getInstance();
    await NotifScheduler.ensurePreferenceMigration(prefs: sp);
    
    _classAlarms = sp.getBool(AppConstants.keyClassAlarms) ?? true;
    _appNotifs = sp.getBool(AppConstants.keyAppNotifs) ?? true;
    _quietWeek = sp.getBool(AppConstants.keyQuietWeek) ?? false;
    _verboseLogging = sp.getBool(AppConstants.keyVerboseLogging) ?? false;
    _leadMinutes = sp.getInt(AppConstants.keyLeadMinutes) ?? AppConstants.defaultLeadMinutes;
    _snoozeMinutes = sp.getInt(AppConstants.keySnoozeMinutes) ?? AppConstants.defaultSnoozeMinutes;
    _alarmVolume = (sp.getInt(AppConstants.keyAlarmVolume) ?? AppConstants.defaultAlarmVolume).clamp(0, 100);
    _alarmVibration = sp.getBool(AppConstants.keyAlarmVibration) ?? AppConstants.defaultAlarmVibration;
    _alarmRingtone = sp.getString(AppConstants.keyAlarmRingtone) ?? AppConstants.defaultAlarmRingtone;
    _use24HourFormat = sp.getBool(AppConstants.keyUse24HourFormat) ?? false;
    
    // New settings
    _weekStartDay = sp.getString(AppConstants.keyWeekStartDay) ?? AppConstants.defaultWeekStartDay;
    _hapticFeedback = sp.getBool(AppConstants.keyHapticFeedback) ?? AppConstants.defaultHapticFeedback;
    _reminderLeadMinutes = sp.getInt(AppConstants.keyReminderLeadMinutes) ?? AppConstants.defaultReminderLeadMinutes;
    _dndEnabled = sp.getBool(AppConstants.keyDndEnabled) ?? AppConstants.defaultDndEnabled;
    _dndStartTime = sp.getString(AppConstants.keyDndStartTime) ?? AppConstants.defaultDndStartTime;
    _dndEndTime = sp.getString(AppConstants.keyDndEndTime) ?? AppConstants.defaultDndEndTime;
    _autoRefreshMinutes = sp.getInt(AppConstants.keyAutoRefreshMinutes) ?? AppConstants.defaultAutoRefreshMinutes;
    
    _loading = false;
    notifyListeners();
  }

  /// Sync all current settings to cloud (fire-and-forget).
  void _syncToCloud() {
    UserSettingsService.instance.update((current) => current.copyWith(
      use24HourFormat: _use24HourFormat,
      hapticFeedback: _hapticFeedback,
      classAlarms: _classAlarms,
      appNotifs: _appNotifs,
      quietWeek: _quietWeek,
      verboseLogging: _verboseLogging,
      classLeadMinutes: _leadMinutes,
      snoozeMinutes: _snoozeMinutes,
      reminderLeadMinutes: _reminderLeadMinutes,
      dndEnabled: _dndEnabled,
      dndStartTime: _dndStartTime,
      dndEndTime: _dndEndTime,
      alarmVolume: _alarmVolume,
      alarmVibration: _alarmVibration,
      alarmRingtone: _alarmRingtone,
      autoRefreshMinutes: _autoRefreshMinutes,
    ));
  }

  void _listenToProfile() {
    ProfileCache.notifier.addListener(_onProfileChanged);
    Future.microtask(() => _applyProfile(ProfileCache.notifier.value));
    ProfileCache.load();
  }

  void _onProfileChanged() {
    _applyProfile(ProfileCache.notifier.value);
  }

  void _applyProfile(ProfileSummary? profile) {
    if (profile == null) {
      if (_profileHydrated) return;
      _profileHydrated = true;
      notifyListeners();
      return;
    }
    _studentName = profile.name;
    _studentEmail = profile.email;
    _avatarUrl = profile.avatarUrl;
    _profileHydrated = true;
    notifyListeners();
  }

  void _bootstrapAdminState() {
    AdminService.instance.role.addListener(_onAdminRoleChanged);
    AdminService.instance.newReportCount.addListener(_onAdminCountChanged);
    AdminService.instance.refreshRole().ignore();
  }

  void _onAdminRoleChanged() {
    final state = AdminService.instance.role.value;
    _adminLoaded = state != AdminRoleState.unknown;
    _isAdmin = state == AdminRoleState.admin;
    _adminError = state == AdminRoleState.error
        ? 'Unable to verify admin access.'
        : null;
    notifyListeners();
    
    if (state == AdminRoleState.admin) {
      AdminService.instance.refreshNewReportCount();
    }
  }

  void _onAdminCountChanged() {
    final count = AdminService.instance.newReportCount.value;
    onNewAdminReports?.call(count);
  }

  void _handleThemeChanged() {
    _themeMode = _themeController.currentMode;
    notifyListeners();
  }

  void setMode(AppThemeMode mode) {
    _themeMode = mode;
    _themeController.setMode(mode);
    notifyListeners();
  }

  /// Returns the currently selected accent color (null = default blue).
  Color? get accentColor => _themeController.accentColor.value;

  /// Sets a custom accent color (null to reset to default blue).
  void setAccentColor(Color? color) {
    _themeController.setAccentColor(color);
    notifyListeners();
  }

  void _installSnoozeListener() {
    NotifScheduler.onSnoozed = (classId, minutes) {
      onSnack?.call('Reminder snoozed for $minutes minutes.');
    };
  }

  void _removeSnoozeListener() {
    NotifScheduler.onSnoozed = null;
  }

  Future<void> _refreshAlarmReadiness() async {
    if (!Platform.isAndroid) return;
    _readinessLoading = true;
    notifyListeners();
    
    final readiness = await LocalNotifs.alarmReadiness();
    
    _exactAlarmAllowed = readiness.exactAlarmAllowed;
    _notificationsAllowed = readiness.notificationsAllowed;
    _ignoringBatteryOptimizations = readiness.ignoringBatteryOptimizations;
    _readinessLoading = false;
    notifyListeners();
  }

  Future<void> refreshAlarmReadiness() => _refreshAlarmReadiness();

  Future<void> sendTestNotification() async {
    if (!Platform.isAndroid) {
      onSnack?.call('Heads-up notifications are Android only.');
      return;
    }
    final success = await LocalNotifs.showHeadsUp(
      id: DateTime.now().millisecondsSinceEpoch & 0x7fffffff,
      title: 'Heads-up test',
      body: 'This is how reminder alerts will look.',
    );
    if (success) {
      onSnack?.call('Heads-up sent.');
    } else {
      onSupportError?.call(
        'Unable to show notification. Check alarm permissions.',
        sendTestNotification,
      );
    }
  }

  Future<void> triggerAlarmTest(VoidCallback openExactAlarmSettings) async {
    if (!Platform.isAndroid) {
      onSnack?.call('Full-screen alarm preview is Android only.');
      return;
    }
    final readiness = await LocalNotifs.alarmReadiness();
    if (!readiness.exactAlarmAllowed) {
      onSupportError?.call(
        'Exact alarm permission is off. Allow exact alarms, then retry.',
        openExactAlarmSettings,
      );
      return;
    }
    final ok = await LocalNotifs.scheduleTestAlarm(
      seconds: 1,
      title: 'Alarm preview',
      body: 'Swipe to snooze or stop.',
    );
    if (ok) {
      onSnack?.call('Launching alarm preview…');
      await _refreshAlarmReadiness();
    } else {
      onSupportError?.call(
        'Unable to start the alarm preview. Check alarm permissions.',
        () => triggerAlarmTest(openExactAlarmSettings),
      );
    }
  }

  Future<void> toggleClassAlarms(bool value) async {
    _classAlarms = value;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(AppConstants.keyClassAlarms, value);
    await NotifScheduler.resync();
  }

  Future<void> toggleAppNotifs(bool value) async {
    _appNotifs = value;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(AppConstants.keyAppNotifs, value);
    await NotifScheduler.resync();
  }

  Future<void> toggleQuietWeek(bool value) async {
    _quietWeek = value;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(AppConstants.keyQuietWeek, value);
    await NotifScheduler.resync();
    onSnack?.call(
      value
          ? 'Quiet week enabled. Alarms paused.'
          : 'Quiet week disabled. Alarms resuming.',
    );
  }

  Future<void> toggleVerboseLogging(bool value) async {
    _verboseLogging = value;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(AppConstants.keyVerboseLogging, value);
    LocalNotifs.debugLogExactAlarms = value;
  }

  Future<void> setLeadMinutes(int value) async {
    _leadMinutes = value;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(AppConstants.keyLeadMinutes, value);
    await NotifScheduler.resync();
  }

  Future<void> setSnoozeMinutes(int value) async {
    _snoozeMinutes = value;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(AppConstants.keySnoozeMinutes, value);
  }

  Future<void> resyncReminders() async {
    _saving = true;
    notifyListeners();
    await NotifScheduler.resync();
    _saving = false;
    notifyListeners();
    onSnack?.call('Resync in progress.');
  }
  
  Future<void> setAlarmVolume(int value) async {
    _alarmVolume = value.clamp(0, 100);
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(AppConstants.keyAlarmVolume, _alarmVolume);
  }

  Future<void> toggleAlarmVibration(bool value) async {
    _alarmVibration = value;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(AppConstants.keyAlarmVibration, value);
  }

  Future<void> setAlarmRingtone(String value) async {
    _alarmRingtone = value;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setString(AppConstants.keyAlarmRingtone, value);
  }

  Future<void> toggle24HourFormat(bool value) async {
    _use24HourFormat = value;
    // Sync static AppTimeFormat immediately so all screens update
    AppTimeFormat.updateValue(value);
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(AppConstants.keyUse24HourFormat, value);
    _syncToCloud();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // New Settings Toggle Methods
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> setWeekStartDay(String value) async {
    _weekStartDay = value;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setString(AppConstants.keyWeekStartDay, value);
  }

  Future<void> toggleHapticFeedback(bool value) async {
    _hapticFeedback = value;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(AppConstants.keyHapticFeedback, value);
    _syncToCloud();
  }

  Future<void> setReminderLeadMinutes(int value) async {
    _reminderLeadMinutes = value;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(AppConstants.keyReminderLeadMinutes, value);
    _syncToCloud();
  }

  Future<void> toggleDndEnabled(bool value) async {
    _dndEnabled = value;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(AppConstants.keyDndEnabled, value);
    _syncToCloud();
  }

  Future<void> setDndStartTime(String value) async {
    _dndStartTime = value;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setString(AppConstants.keyDndStartTime, value);
    _syncToCloud();
  }

  Future<void> setDndEndTime(String value) async {
    _dndEndTime = value;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setString(AppConstants.keyDndEndTime, value);
    _syncToCloud();
  }

  Future<void> setAutoRefreshMinutes(int value) async {
    _autoRefreshMinutes = value;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(AppConstants.keyAutoRefreshMinutes, value);
  }

  Future<void> refreshProfile() async {
    await ProfileCache.load(forceRefresh: true);
  }
}
