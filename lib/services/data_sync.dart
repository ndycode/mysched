import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized data synchronization and cache invalidation broadcast.
/// 
/// Provides a reactive mechanism for UI components to subscribe to
/// data changes and refresh when cache is invalidated.
class DataSync {
  DataSync._();

  static DataSync? _instance;
  static DataSync get instance {
    _instance ??= DataSync._();
    return _instance!;
  }

  static const String _keyLastScheduleSync = 'sync_last_schedule';
  static const String _keyLastRemindersSync = 'sync_last_reminders';
  static const String _keyLastProfileSync = 'sync_last_profile';

  // Stream controllers for different data types
  final _scheduleController = StreamController<ScheduleEvent>.broadcast();
  final _remindersController = StreamController<RemindersEvent>.broadcast();
  final _profileController = StreamController<ProfileEvent>.broadcast();

  // Value notifiers for simple state
  final ValueNotifier<DateTime?> lastScheduleSync = ValueNotifier(null);
  final ValueNotifier<DateTime?> lastRemindersSync = ValueNotifier(null);
  final ValueNotifier<DateTime?> lastProfileSync = ValueNotifier(null);

  // Loading state
  final ValueNotifier<bool> isScheduleSyncing = ValueNotifier(false);
  final ValueNotifier<bool> isRemindersSyncing = ValueNotifier(false);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final schedule = prefs.getInt(_keyLastScheduleSync);
    final reminders = prefs.getInt(_keyLastRemindersSync);
    final profile = prefs.getInt(_keyLastProfileSync);

    if (schedule != null) {
      lastScheduleSync.value = DateTime.fromMillisecondsSinceEpoch(schedule);
    }
    if (reminders != null) {
      lastRemindersSync.value = DateTime.fromMillisecondsSinceEpoch(reminders);
    }
    if (profile != null) {
      lastProfileSync.value = DateTime.fromMillisecondsSinceEpoch(profile);
    }
  }

  /// Stream of schedule-related events.
  Stream<ScheduleEvent> get scheduleEvents => _scheduleController.stream;

  /// Stream of reminder-related events.
  Stream<RemindersEvent> get remindersEvents => _remindersController.stream;

  /// Stream of profile-related events.
  Stream<ProfileEvent> get profileEvents => _profileController.stream;

  /// Notify listeners that schedule data has changed.
  void notifyScheduleChanged({
    ScheduleChangeType type = ScheduleChangeType.refresh,
    int? classId,
    String? userId,
  }) {
    final now = DateTime.now();
    lastScheduleSync.value = now;
    _persist(_keyLastScheduleSync, now);
    _scheduleController.add(ScheduleEvent(
      type: type,
      classId: classId,
      userId: userId,
      timestamp: now,
    ));
  }

  /// Notify listeners that reminders have changed.
  void notifyRemindersChanged({
    RemindersChangeType type = RemindersChangeType.refresh,
    int? reminderId,
    String? userId,
  }) {
    final now = DateTime.now();
    lastRemindersSync.value = now;
    _persist(_keyLastRemindersSync, now);
    _remindersController.add(RemindersEvent(
      type: type,
      reminderId: reminderId,
      userId: userId,
      timestamp: now,
    ));
  }

  /// Notify listeners that profile has changed.
  void notifyProfileChanged({
    ProfileChangeType type = ProfileChangeType.refresh,
    String? userId,
  }) {
    final now = DateTime.now();
    lastProfileSync.value = now;
    _persist(_keyLastProfileSync, now);
    _profileController.add(ProfileEvent(
      type: type,
      userId: userId,
      timestamp: now,
    ));
  }

  Future<void> _persist(String key, DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(key, date.millisecondsSinceEpoch);
    } catch (e) {
      // Ignore storage errors
    }
  }

  /// Mark schedule as syncing.
  void setScheduleSyncing(bool syncing) {
    isScheduleSyncing.value = syncing;
  }

  /// Mark reminders as syncing.
  void setRemindersSyncing(bool syncing) {
    isRemindersSyncing.value = syncing;
  }

  /// Trigger a full data refresh.
  void requestFullRefresh() {
    notifyScheduleChanged(type: ScheduleChangeType.refresh);
    notifyRemindersChanged(type: RemindersChangeType.refresh);
    notifyProfileChanged(type: ProfileChangeType.refresh);
  }

  /// Clear all sync timestamps (e.g., on logout).
  Future<void> reset() async {
    lastScheduleSync.value = null;
    lastRemindersSync.value = null;
    lastProfileSync.value = null;
    isScheduleSyncing.value = false;
    isRemindersSyncing.value = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastScheduleSync);
    await prefs.remove(_keyLastRemindersSync);
    await prefs.remove(_keyLastProfileSync);
  }

  void dispose() {
    _scheduleController.close();
    _remindersController.close();
    _profileController.close();
  }

  @visibleForTesting
  static void resetInstance() {
    _instance?.dispose();
    _instance = null;
  }
}

// Event types

enum ScheduleChangeType {
  refresh,
  classAdded,
  classUpdated,
  classDeleted,
  classEnabled,
  classDisabled,
  cacheInvalidated,
}

enum RemindersChangeType {
  refresh,
  reminderAdded,
  reminderUpdated,
  reminderDeleted,
  reminderCompleted,
  reminderSnoozed,
}

enum ProfileChangeType {
  refresh,
  nameUpdated,
  avatarUpdated,
  emailUpdated,
}

class ScheduleEvent {
  const ScheduleEvent({
    required this.type,
    required this.timestamp,
    this.classId,
    this.userId,
  });

  final ScheduleChangeType type;
  final int? classId;
  final String? userId;
  final DateTime timestamp;
}

class RemindersEvent {
  const RemindersEvent({
    required this.type,
    required this.timestamp,
    this.reminderId,
    this.userId,
  });

  final RemindersChangeType type;
  final int? reminderId;
  final String? userId;
  final DateTime timestamp;
}

class ProfileEvent {
  const ProfileEvent({
    required this.type,
    required this.timestamp,
    this.userId,
  });

  final ProfileChangeType type;
  final String? userId;
  final DateTime timestamp;
}


