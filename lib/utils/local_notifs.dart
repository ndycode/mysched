import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_log.dart';
import '../services/user_scope.dart';
import '../ui/kit/battery_optimization_sheet.dart';
import '../ui/kit/modals.dart';
import 'nav.dart';

/// Android-only wrapper around `flutter_local_notifications`.
class LocalNotifs {
  LocalNotifs._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const MethodChannel _channel = MethodChannel('mysched/native_alarm');
  static bool _initialized = false;

  @visibleForTesting
  static bool debugForceAndroid = false;

  @visibleForTesting
  static Future<bool> Function({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required int classId,
    required String occurrenceKey,
    String? subject,
    String? room,
    String? startTime,
    String? endTime,
    bool headsUpOnly,
    String? userId,
  })? debugScheduleOverride;

  @visibleForTesting
  static Future<void> Function(int id, {String? userId})? debugCancelOverride;

  @visibleForTesting
  static Future<void> Function(Set<int> ids, {String? userId})?
      debugCancelManyOverride;

  @visibleForTesting
  static Future<void> Function(int minutes)? debugSnoozeFeedbackOverride;

  static bool debugLogExactAlarms = false;

  static const _classScheduleKey = 'notif_class_schedule_map';
  static const _ackStoreKey = 'notif_ack_map';
  static const _nativeIdsKey = 'scheduled_native_alarm_ids';
  static const _anonUserKey = '_anon';
  static const _readinessChannel = 'alarmReadiness';
  static const _openNotificationSettingsChannel = 'openNotificationSettings';
  static const _openBatteryOptimizationSettingsChannel =
      'openBatteryOptimizationSettings';

  static String _userKey([String? explicitUserId]) {
    if (explicitUserId != null && explicitUserId.trim().isNotEmpty) {
      return explicitUserId.trim();
    }
    final id = UserScope.currentUserId();
    if (id == null || id.trim().isEmpty) return _anonUserKey;
    return id.trim();
  }

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    if (debugForceAndroid) {
      _initialized = true;
      return;
    }
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) {
        unawaited(openReminders());
      },
    );
    _initialized = true;
  }

  /// Schedule an exact alarm notification for the provided occurrence.
  static Future<bool> scheduleNativeAlarmAt({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required int classId,
    required String occurrenceKey,
    String? subject,
    String? room,
    String? startTime,
    String? endTime,
    bool headsUpOnly = false,
    String? userId,
  }) async {
    if (!isAndroidContext) return false;
    if (!at.isAfter(DateTime.now())) return false;

    if (debugScheduleOverride != null) {
      final ok = await debugScheduleOverride!(
        id: id,
        at: at,
        title: title,
        body: body,
        classId: classId,
        occurrenceKey: occurrenceKey,
        subject: subject,
        room: room,
        startTime: startTime,
        endTime: endTime,
        headsUpOnly: headsUpOnly,
        userId: userId,
      );
      if (ok) {
        await _recordScheduledId(classId, id, userId: userId);
        await _clearOccurrenceAck(
          classId: classId,
          occurrenceKey: occurrenceKey,
          userId: userId,
        );
      }
      return ok;
    }

    if (debugForceAndroid) {
      await _recordScheduledId(classId, id, userId: userId);
      await _clearOccurrenceAck(
        classId: classId,
        occurrenceKey: occurrenceKey,
        userId: userId,
      );
      return true;
    }

    try {
      final success = await _channel.invokeMethod<bool>(
            'scheduleNativeAlarmAt',
            {
              'id': id,
              'atMillis': at.millisecondsSinceEpoch,
              'title': title,
              'body': body,
              'classId': classId,
              'occurrenceKey': occurrenceKey,
              'subject': subject,
              'room': room,
              'startTime': startTime,
              'endTime': endTime,
              'headsUpOnly': headsUpOnly,
            },
          ) ??
          false;
      if (success) {
        await _recordScheduledId(classId, id, userId: userId);
        await _clearOccurrenceAck(
          classId: classId,
          occurrenceKey: occurrenceKey,
          userId: userId,
        );
        _logScheduled(
          id: id,
          at: at,
          headsUp: headsUpOnly,
        );
      }
      return success;
    } on PlatformException catch (err, stack) {
      _logScheduleError(id: id, error: err, stack: stack);
      return false;
    }
  }

  /// Cancel a previously scheduled alarm and update stored metadata.
  static Future<void> cancelNativeAlarm(
    int id, {
    bool silent = false,
    String? userId,
  }) async {
    if (!isAndroidContext) return;
    if (debugLogExactAlarms && !silent) {
      AppLog.debug(
        'LocalNotifs',
        'Cancel alarm request',
        data: {'id': id},
      );
    }
    if (debugCancelOverride != null) {
      await debugCancelOverride!(id, userId: userId);
    } else if (debugForceAndroid) {
      // no-op in debug simulation
    } else {
      try {
        await _channel.invokeMethod('cancelNativeAlarm', {'id': id});
      } on PlatformException catch (err) {
        AppLog.warn(
          'LocalNotifs',
          'Failed to cancel alarm natively',
          data: {'id': id},
          error: err,
        );
      }
    }
    await _removeScheduledId(id, userId: userId);
  }

  /// Cancel many alarms by id.
  static Future<void> cancelMany(
    Set<int> ids, {
    String? userId,
  }) async {
    if (debugCancelManyOverride != null) {
      await debugCancelManyOverride!(ids, userId: userId);
      for (final id in ids) {
        await _removeScheduledId(id, userId: userId);
      }
      return;
    }
    for (final id in ids) {
      if (debugLogExactAlarms) {
        AppLog.debug(
          'LocalNotifs',
          'CancelMany dispatch',
          data: {'id': id},
        );
      }
      await cancelNativeAlarm(id, silent: true, userId: userId);
      await _removeScheduledId(id, userId: userId);
    }
    if (ids.isEmpty || !debugLogExactAlarms) return;
    final sample = ids.take(5).join(', ');
    final suffix = ids.length > 5 ? '...' : '';
    AppLog.debug(
      'LocalNotifs',
      'Cancelled ${ids.length} alarms',
      data: {'ids': '$sample$suffix'},
    );
  }

  static Future<void> cancelAllNativeAlarms() async {
    if (!isAndroidContext) return;
    if (debugForceAndroid) return;
    try {
      await _channel.invokeMethod('cancelAllNativeAlarms');
    } on PlatformException catch (err) {
      if (debugLogExactAlarms) {
        AppLog.warn(
          'LocalNotifs',
          'cancelAllNativeAlarms failed',
          error: err,
        );
      }
    }
  }

  /// Show an immediate heads-up notification.
  static Future<bool> showHeadsUp({
    required int id,
    required String title,
    required String body,
  }) async {
    await _ensureInitialized();
    if (!Platform.isAndroid && !debugForceAndroid) return false;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'mysched_heads_up',
        'Heads Up',
        channelDescription: 'High priority alerts',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    try {
      await _plugin.show(id, title, body, details);
      return true;
    } catch (err, stack) {
      AppLog.error(
        'LocalNotifs',
        'Failed to show heads-up',
        data: {'id': id},
        error: err,
        stack: stack,
      );
      return false;
    }
  }

  /// Schedule a one-off full-screen alarm a few seconds from now for testing.
  static Future<bool> scheduleTestAlarm({
    int seconds = 1,
    String title = 'Alarm test',
    String body = 'This is how the full-screen alarm appears.',
  }) async {
    if (!isAndroidContext && !debugForceAndroid) return false;
    try {
      final ok = await _channel.invokeMethod<bool>(
            'scheduleTestAlarm',
            {
              'seconds': seconds,
              'title': title,
              'body': body,
            },
          ) ??
          false;
      if (!ok && debugLogExactAlarms) {
        AppLog.warn(
          'LocalNotifs',
          'scheduleTestAlarm returned false',
        );
      }
      return ok;
    } on PlatformException catch (err, stack) {
      AppLog.error(
        'LocalNotifs',
        'scheduleTestAlarm failed',
        error: err,
        stack: stack,
      );
      return false;
    }
  }

  /// Opens the Android exact alarm settings screen so users can grant access.
  static Future<void> openExactAlarmSettings() async {
    if (!isAndroidContext) return;
    if (debugForceAndroid) return;
    try {
      await _channel.invokeMethod('openExactAlarmSettings');
    } on PlatformException catch (err) {
      if (debugLogExactAlarms) {
        AppLog.warn(
          'LocalNotifs',
          'openExactAlarmSettings failed',
          error: err,
        );
      }
    }
  }

  static Future<bool> canScheduleExactAlarms() async {
    if (!isAndroidContext) return false;
    if (debugForceAndroid) return true;
    try {
      final result =
          await _channel.invokeMethod<bool>('canScheduleExactAlarms');
      return result ?? false;
    } on PlatformException catch (err) {
      if (debugLogExactAlarms) {
        AppLog.warn(
          'LocalNotifs',
          'canScheduleExactAlarms failed',
          error: err,
        );
      }
      return false;
    }
  }

  /// Aggregates alarm readiness signals for UI prompts.
  static Future<AlarmReadiness> alarmReadiness() async {
    if (!isAndroidContext) {
      return const AlarmReadiness(
        exactAlarmAllowed: false,
        notificationsAllowed: false,
        ignoringBatteryOptimizations: false,
        sdkInt: 0,
      );
    }
    if (debugForceAndroid) {
      return const AlarmReadiness(
        exactAlarmAllowed: true,
        notificationsAllowed: true,
        ignoringBatteryOptimizations: true,
        sdkInt: 33,
      );
    }
    try {
      final result =
          await _channel.invokeMethod<Map<dynamic, dynamic>>(_readinessChannel);
      return AlarmReadiness.fromMap(result);
    } on PlatformException catch (err) {
      if (debugLogExactAlarms) {
        AppLog.warn(
          'LocalNotifs',
          'alarmReadiness failed',
          error: err,
        );
      }
      return const AlarmReadiness(
        exactAlarmAllowed: false,
        notificationsAllowed: false,
        ignoringBatteryOptimizations: false,
        sdkInt: 0,
      );
    }
  }

  static Future<void> openNotificationSettings() async {
    if (!isAndroidContext) return;
    if (debugForceAndroid) return;
    try {
      await _channel.invokeMethod(_openNotificationSettingsChannel);
    } on PlatformException catch (err) {
      if (debugLogExactAlarms) {
        AppLog.warn(
          'LocalNotifs',
          'openNotificationSettings failed',
          error: err,
        );
      }
    }
  }

  static Future<void> openBatteryOptimizationSettings({bool preferAppInfo = true}) async {
    if (!isAndroidContext) return;
    if (debugForceAndroid) return;
    try {
      await _channel.invokeMethod(_openBatteryOptimizationSettingsChannel, {
        'preferAppInfo': preferAppInfo,
      });
    } on PlatformException catch (err) {
      if (debugLogExactAlarms) {
        AppLog.warn(
          'LocalNotifs',
          'openBatteryOptimizationSettings failed',
          error: err,
        );
      }
    }
  }

  static Future<void> openBatteryOptimizationDialog(BuildContext context) async {
    await AppModal.alert(
      context: context,
      builder: (context) => const BatteryOptimizationDialog(),
    );
  }

  /// Check whether an occurrence has been acknowledged.
  static Future<bool> isOccurrenceAcknowledged({
    required int classId,
    required String occurrenceKey,
  }) async {
    if (debugForceAndroid) {
      final sp = await SharedPreferences.getInstance();
      final ackMap = await _loadAckMap(sp);
      final keys = ackMap[classId];
      return keys != null && keys.contains(occurrenceKey);
    }
    try {
      final ack = await _channel.invokeMethod<bool>(
        'isOccurrenceAcknowledged',
        {
          'classId': classId,
          'occurrenceKey': occurrenceKey,
        },
      );
      if (ack != null) return ack;
    } on PlatformException catch (err) {
      if (debugLogExactAlarms) {
        AppLog.warn(
          'LocalNotifs',
          'isOccurrenceAcknowledged failed',
          error: err,
        );
      }
    }
    final sp = await SharedPreferences.getInstance();
    final ackMap = await _loadAckMap(sp);
    final keys = ackMap[classId];
    return keys?.contains(occurrenceKey) ?? false;
  }

  /// Mark the occurrence as acknowledged.
  static Future<void> markOccurrenceAcknowledged({
    required int classId,
    required String occurrenceKey,
  }) async {
    if (debugForceAndroid) {
      final sp = await SharedPreferences.getInstance();
      final ackMap = await _loadAckMap(sp);
      final keys = ackMap.putIfAbsent(classId, () => <String>{});
      if (keys.add(occurrenceKey)) {
        await _storeAckMap(sp, ackMap);
      }
      return;
    }
    try {
      await _channel.invokeMethod(
        'markOccurrenceAcknowledged',
        {
          'classId': classId,
          'occurrenceKey': occurrenceKey,
        },
      );
    } on PlatformException catch (err) {
      if (debugLogExactAlarms) {
        AppLog.warn(
          'LocalNotifs',
          'markOccurrenceAcknowledged failed',
          error: err,
        );
      }
    }
    final sp = await SharedPreferences.getInstance();
    final ackMap = await _loadAckMap(sp);
    final keys = ackMap.putIfAbsent(classId, () => <String>{});
    if (keys.add(occurrenceKey)) {
      await _storeAckMap(sp, ackMap);
    }
  }

  static Future<void> _clearOccurrenceAck({
    required int classId,
    required String occurrenceKey,
    String? userId,
  }) async {
    if (debugForceAndroid) {
      final sp = await SharedPreferences.getInstance();
      final ackMap = await _loadAckMap(sp, userId: userId);
      final keys = ackMap[classId];
      if (keys != null && keys.remove(occurrenceKey)) {
        if (keys.isEmpty) {
          ackMap.remove(classId);
        }
        await _storeAckMap(sp, ackMap, userId: userId);
      }
      return;
    }
    try {
      await _channel.invokeMethod(
        'clearOccurrenceAcknowledged',
        {
          'classId': classId,
          'occurrenceKey': occurrenceKey,
        },
      );
    } on PlatformException catch (err) {
      if (debugLogExactAlarms) {
        AppLog.warn(
          'LocalNotifs',
          'clearOccurrenceAcknowledged failed',
          error: err,
        );
      }
    }
    final sp = await SharedPreferences.getInstance();
    final ackMap = await _loadAckMap(sp, userId: userId);
    final keys = ackMap[classId];
    if (keys != null && keys.remove(occurrenceKey)) {
      if (keys.isEmpty) {
        ackMap.remove(classId);
      }
      await _storeAckMap(sp, ackMap, userId: userId);
    }
  }

  static Future<void> _recordScheduledId(
    int classId,
    int id, {
    String? userId,
  }) async {
    final sp = await SharedPreferences.getInstance();
    final map = await _loadClassMap(sp, userId: userId);
    final ids = map.putIfAbsent(classId, () => <int>{});
    ids.add(id);
    await _storeClassMap(sp, map, userId: userId);
  }

  static Future<void> _removeScheduledId(
    int id, {
    String? userId,
  }) async {
    final sp = await SharedPreferences.getInstance();
    final map = await _loadClassMap(sp, userId: userId);
    var dirty = false;
    final toRemove = <int>[];
    map.forEach((classId, ids) {
      if (ids.remove(id)) {
        dirty = true;
      }
      if (ids.isEmpty) {
        toRemove.add(classId);
      }
    });
    for (final classId in toRemove) {
      map.remove(classId);
    }
    if (dirty || toRemove.isNotEmpty) {
      await _storeClassMap(sp, map, userId: userId);
    }
  }

  static Future<Map<int, Set<int>>> _loadClassMap(
    SharedPreferences sp, {
    String? userId,
  }) async {
    final raw = sp.getString(_classScheduleKey);
    if (raw == null) return {};
    final userKey = _userKey(userId);
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final scoped = decoded[userKey];
      if (scoped is! Map) return {};
      final result = <int, Set<int>>{};
      scoped.forEach((key, value) {
        final classId = int.tryParse('$key');
        if (classId == null) return;
        final list = (value as List<dynamic>)
            .map((e) => e is int ? e : int.tryParse('$e'))
            .whereType<int>()
            .toSet();
        if (list.isNotEmpty) {
          result[classId] = list;
        }
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  static Future<void> _storeClassMap(
    SharedPreferences sp,
    Map<int, Set<int>> map, {
    String? userId,
  }) async {
    final userKey = _userKey(userId);
    final raw = sp.getString(_classScheduleKey);
    final decoded = _decodedScopedMap(raw);
    final data = <String, List<int>>{};
    map.forEach((key, value) {
      if (value.isNotEmpty) {
        data['$key'] = value.toList();
      }
    });
    if (data.isEmpty) {
      decoded.remove(userKey);
    } else {
      decoded[userKey] = data;
    }
    await _writeScopedMap(sp, _classScheduleKey, decoded);
  }

  static Future<Map<int, Set<String>>> _loadAckMap(
    SharedPreferences sp, {
    String? userId,
  }) async {
    final raw = sp.getString(_ackStoreKey);
    if (raw == null) return {};
    final userKey = _userKey(userId);
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final scoped = decoded[userKey];
      if (scoped is! Map) return {};
      final result = <int, Set<String>>{};
      scoped.forEach((key, value) {
        final classId = int.tryParse('$key');
        if (classId == null) return;
        final list = (value as List<dynamic>)
            .map((e) => e?.toString())
            .whereType<String>()
            .toSet();
        if (list.isNotEmpty) {
          result[classId] = list;
        }
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  static Future<void> _storeAckMap(
    SharedPreferences sp,
    Map<int, Set<String>> map, {
    String? userId,
  }) async {
    final userKey = _userKey(userId);
    final raw = sp.getString(_ackStoreKey);
    final decoded = _decodedScopedMap(raw);
    final data = <String, List<String>>{};
    map.forEach((key, value) {
      if (value.isNotEmpty) {
        data['$key'] = value.toList();
      }
    });
    if (data.isEmpty) {
      decoded.remove(userKey);
    } else {
      decoded[userKey] = data;
    }
    await _writeScopedMap(sp, _ackStoreKey, decoded);
  }

  static Future<void> clearPersistentState({String? userId}) async {
    final sp = await SharedPreferences.getInstance();
    if (userId == null) {
      await sp.remove(_classScheduleKey);
      await sp.remove(_ackStoreKey);
      await sp.remove(_nativeIdsKey);
      await cancelAllNativeAlarms();
      return;
    }
    final key = _userKey(userId);
    await _removeUserEntry(sp, _classScheduleKey, key);
    await _removeUserEntry(sp, _ackStoreKey, key);
    await _removeUserEntry(sp, _nativeIdsKey, key);
  }

  static Map<String, dynamic> _decodedScopedMap(String? raw) {
    if (raw == null) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Ignore corrupt payloads.
    }
    return <String, dynamic>{};
  }

  static Future<void> _writeScopedMap(
    SharedPreferences sp,
    String key,
    Map<String, dynamic> data,
  ) async {
    if (data.isEmpty) {
      await sp.remove(key);
    } else {
      await sp.setString(key, jsonEncode(data));
    }
  }

  static Future<void> _removeUserEntry(
    SharedPreferences sp,
    String key,
    String userKey,
  ) async {
    final raw = sp.getString(key);
    if (raw == null) return;
    final decoded = _decodedScopedMap(raw);
    if (!decoded.containsKey(userKey)) return;
    decoded.remove(userKey);
    await _writeScopedMap(sp, key, decoded);
  }

  /// Snapshot of scheduled ids per class.
  static Future<Map<int, Set<int>>> scheduledIdMap({String? userId}) async {
    final sp = await SharedPreferences.getInstance();
    final map = await _loadClassMap(sp, userId: userId);
    final copy = <int, Set<int>>{};
    map.forEach((key, value) {
      copy[key] = Set<int>.from(value);
    });
    return copy;
  }

  /// Scheduled ids for a single class.
  static Future<Set<int>> scheduledIdsForClass(
    int classId, {
    String? userId,
  }) async {
    final map = await scheduledIdMap(userId: userId);
    return map[classId] ?? <int>{};
  }

  static bool get isAndroidContext => Platform.isAndroid || debugForceAndroid;

  static Future<void> showSnoozeFeedback({required int minutes}) async {
    await _ensureInitialized();
    if (!isAndroidContext) return;
    if (debugSnoozeFeedbackOverride != null) {
      await debugSnoozeFeedbackOverride!(minutes);
      return;
    }
    final text = minutes == 1
        ? 'Reminder snoozed for 1 minute'
        : 'Reminder snoozed for $minutes minutes';
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'mysched_snooze_feedback',
        'Snooze Feedback',
        channelDescription: 'Confirms when reminders are snoozed',
        importance: Importance.low,
        priority: Priority.low,
        playSound: false,
        enableVibration: false,
      ),
    );
    await _plugin.show(
      0x5A5A,
      'Snoozed',
      text,
      details,
      payload: 'snooze_feedback',
    );
  }

  static void setDebugLoggingEnabled(bool enabled) {
    debugLogExactAlarms = enabled;
  }

  static void _logScheduled({
    required int id,
    required DateTime at,
    required bool headsUp,
  }) {
    if (!debugLogExactAlarms && !headsUp) return;
    final formatter = DateFormat('EEE, MMM d • h:mm a');
    final label = formatter.format(at.toLocal());
    AppLog.debug(
      'LocalNotifs',
      headsUp ? 'Scheduled heads-up alarm' : 'Scheduled alarm',
      data: {'id': id, 'when': label},
    );
  }

  static void _logScheduleError({
    required int id,
    required Object error,
    StackTrace? stack,
  }) {
    AppLog.error(
      'LocalNotifs',
      'Failed to schedule alarm',
      data: {'id': id},
      error: error,
      stack: stack,
    );
  }

  /// Get available alarm sounds from device.
  /// Returns list of maps with 'title' and 'uri' keys.
  static Future<List<AlarmSound>> getAlarmSounds() async {
    if (!isAndroidContext) return [];
    if (debugForceAndroid) {
      return [
        const AlarmSound(title: 'Default Alarm', uri: 'default'),
      ];
    }
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getAlarmSounds');
      if (result == null) return [];
      return result
          .whereType<Map>()
          .map((m) => AlarmSound(
                title: m['title']?.toString() ?? 'Unknown',
                uri: m['uri']?.toString() ?? 'default',
              ))
          .toList();
    } on PlatformException catch (err) {
      if (debugLogExactAlarms) {
        AppLog.warn(
          'LocalNotifs',
          'getAlarmSounds failed',
          error: err,
        );
      }
      return [];
    }
  }

  /// Preview a ringtone by URI. Plays for ~2 seconds.
  static Future<void> playRingtonePreview(String ringtoneUri) async {
    if (!isAndroidContext) return;
    if (debugForceAndroid) return;
    try {
      await _channel.invokeMethod('playRingtonePreview', {
        'ringtoneType': ringtoneUri,
      });
    } on PlatformException catch (err) {
      if (debugLogExactAlarms) {
        AppLog.warn(
          'LocalNotifs',
          'playRingtonePreview failed',
          error: err,
        );
      }
    }
  }

  /// Stop any currently playing ringtone preview.
  static Future<void> stopRingtonePreview() async {
    if (!isAndroidContext) return;
    if (debugForceAndroid) return;
    try {
      await _channel.invokeMethod('stopRingtonePreview');
    } on PlatformException catch (_) {
      // Ignore errors
    }
  }
}

class AlarmReadiness {
  final bool exactAlarmAllowed;
  final bool notificationsAllowed;
  final bool ignoringBatteryOptimizations;
  final int sdkInt;

  const AlarmReadiness({
    required this.exactAlarmAllowed,
    required this.notificationsAllowed,
    required this.ignoringBatteryOptimizations,
    required this.sdkInt,
  });

  factory AlarmReadiness.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const AlarmReadiness(
        exactAlarmAllowed: false,
        notificationsAllowed: false,
        ignoringBatteryOptimizations: false,
        sdkInt: 0,
      );
    }
    bool asBool(String key) => map[key] == true;
    final sdk = map['sdkInt'];
    return AlarmReadiness(
      exactAlarmAllowed: asBool('exactAlarmAllowed'),
      notificationsAllowed: asBool('notificationsAllowed'),
      ignoringBatteryOptimizations: asBool('ignoringBatteryOptimizations'),
      sdkInt: sdk is int ? sdk : 0,
    );
  }
}

/// Represents an alarm sound available on the device.
class AlarmSound {
  final String title;
  final String uri;

  const AlarmSound({
    required this.title,
    required this.uri,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmSound &&
          runtimeType == other.runtimeType &&
          uri == other.uri;

  @override
  int get hashCode => uri.hashCode;
}

