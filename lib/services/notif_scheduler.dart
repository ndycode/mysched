import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_log.dart';
import '../utils/local_notifs.dart';
import 'schedule_api.dart';
import 'user_scope.dart';

class NotifScheduler {
  static const _nativeIdsKey = 'scheduled_native_alarm_ids';
  static void Function(int classId, int minutes)? onSnoozed;

  static Future<void> resync({ScheduleApi? api, String? userId}) async {
    if (!_isAndroid()) return;

    final sp = await SharedPreferences.getInstance();
    await ensurePreferenceMigration(prefs: sp);
    final appNotifs = sp.getBool('app_notifs') ?? true;
    final classAlarms = sp.getBool('class_alarms') ?? true;
    final quietWeek = sp.getBool('quiet_week_enabled') ?? false;
    if (!appNotifs || !classAlarms) {
      await _cancelAllTracked(sp);
      return;
    }
    if (quietWeek) {
      await _cancelAllTracked(sp);
      return;
    }

    final uid = userId ?? UserScope.currentUserId();
    if (uid == null) {
      await _cancelAllTracked(sp);
      return;
    }

    if (!await LocalNotifs.canScheduleExactAlarms()) {
      AppLog.warn(
        'NotifScheduler',
        'Exact alarm permission missing; skipping resync',
      );
      await _cancelAllTracked(sp, uid);
      return;
    }

    final leadMinutes = _readPositive(
          sp.getInt('notifLeadMinutes'),
        ) ??
        10;

    final scheduleApi = api ?? ScheduleApi();
    final classes = await scheduleApi.getMyClasses();

    final plan = _buildPlan(
      uid: uid,
      classes: classes,
      leadMinutes: leadMinutes,
      now: DateTime.now(),
    );

    final expectedNative = <int>{};
    for (final req in plan.requests) {
      if (req.shouldScheduleAlarm(plan.now)) {
        expectedNative.add(req.nativeId);
      }
      if (req.preNotifId != null && req.shouldScheduleHeadsUp(plan.now)) {
        expectedNative.add(req.preNotifId!);
      }
    }

    final previousNative = _readIdSet(sp, _nativeIdsKey, uid);
    final diff = diffScheduled(
      previousNative: previousNative,
      previousNotif: const <int>{},
      nextNative: expectedNative,
      nextNotif: const <int>{},
    );

    await LocalNotifs.cancelMany(diff.nativeToCancel, userId: uid);

    final actualNative = <int>{};
    for (final req in plan.requests) {
      if (req.preNotifId != null && req.shouldScheduleHeadsUp(plan.now)) {
        final scheduledHeadsUp = await LocalNotifs.scheduleNativeAlarmAt(
          id: req.preNotifId!,
          at: req.preNotifAt!,
          title: req.title,
          body: req.body,
          classId: req.classId,
          occurrenceKey: req.occurrenceKey,
          subject: req.subject,
          room: req.room,
          startTime: req.startLabel,
          endTime: req.endLabel,
          headsUpOnly: true,
          userId: uid,
        );
        if (scheduledHeadsUp) {
          actualNative.add(req.preNotifId!);
        }
      }

      if (!req.shouldScheduleAlarm(plan.now)) continue;

      final scheduled = await LocalNotifs.scheduleNativeAlarmAt(
        id: req.nativeId,
        at: req.alarmAt,
        title: req.title,
        body: req.body,
        classId: req.classId,
        occurrenceKey: req.occurrenceKey,
        subject: req.subject,
        room: req.room,
        startTime: req.startLabel,
        endTime: req.endLabel,
        userId: uid,
      );
      if (scheduled) {
        actualNative.add(req.nativeId);
      }
    }

    await _storeIdSet(sp, _nativeIdsKey, actualNative, uid);
  }

  static Future<void> snooze(
    int classId, {
    required int minutes,
    ScheduleApi? api,
    String? userId,
  }) async {
    if (!_isAndroid()) return;

    final sp = await SharedPreferences.getInstance();
    await ensurePreferenceMigration(prefs: sp);
    final uid = userId ?? UserScope.currentUserId();
    if (uid == null) return;

    final appliedMinutes = max(1, minutes);

    final existing = await LocalNotifs.scheduledIdsForClass(classId);
    if (existing.isNotEmpty) {
      await LocalNotifs.cancelMany(existing);
    }

    if (!await LocalNotifs.canScheduleExactAlarms()) {
      await LocalNotifs.showSnoozeFeedback(minutes: appliedMinutes);
      onSnoozed?.call(classId, appliedMinutes);
      return;
    }

    final quietWeek = sp.getBool('quiet_week_enabled') ?? false;
    if (quietWeek) {
      await LocalNotifs.showSnoozeFeedback(minutes: appliedMinutes);
      onSnoozed?.call(classId, appliedMinutes);
      return;
    }

    final scheduleApi = api ?? ScheduleApi();
    final classes = await scheduleApi.getMyClasses();
    ClassItem? classItem;
    for (final item in classes) {
      if (item.id == classId) {
        classItem = item;
        break;
      }
    }
    if (classItem == null) return;

    final target = DateTime.now().add(Duration(minutes: appliedMinutes));
    final id = _nativeId(
      uid: uid,
      classId: classItem.id,
      occurrence: target,
      isCustom: classItem.isCustom,
      isHeadsUp: false,
    );
    final subject = _titleForClass(classItem);
    final success = await LocalNotifs.scheduleNativeAlarmAt(
      id: id,
      at: target,
      title: subject,
      body: _bodyForClass(classItem),
      classId: classItem.id,
      occurrenceKey: _occurrenceKey(target),
      subject: subject,
      room: _normalizeRoom(classItem.room),
      startTime: _formatTimeLabel(classItem.start),
      endTime: _formatTimeLabel(classItem.end),
      userId: uid,
    );

    final nativeIds = _readIdSet(sp, _nativeIdsKey, uid);
    nativeIds.removeAll(existing);
    if (success) {
      nativeIds.add(id);
      final actualScheduled = await _collectScheduledNativeIds(userId: uid);
      if (actualScheduled.isNotEmpty) {
        nativeIds
          ..clear()
          ..addAll(actualScheduled);
      }
      await LocalNotifs.showSnoozeFeedback(minutes: appliedMinutes);
      onSnoozed?.call(classItem.id, appliedMinutes);
    }
    await _storeIdSet(sp, _nativeIdsKey, nativeIds, uid);
  }

  @visibleForTesting
  static ({Set<int> nativeToCancel, Set<int> notifToCancel}) diffScheduled({
    required Set<int> previousNative,
    required Set<int> previousNotif,
    required Set<int> nextNative,
    required Set<int> nextNotif,
  }) {
    final nativeToCancel = previousNative.difference(nextNative);
    final notifToCancel = previousNotif.difference(nextNotif);
    return (
      nativeToCancel: nativeToCancel,
      notifToCancel: notifToCancel,
    );
  }

  @visibleForTesting
  static List<SchedulePreview> preview({
    required String uid,
    required List<ClassItem> classes,
    required int leadMinutes,
    required DateTime now,
  }) {
    final plan = _buildPlan(
      uid: uid,
      classes: classes,
      leadMinutes: leadMinutes,
      now: now,
    );
    final result = <SchedulePreview>[];
    for (final req in plan.requests) {
      result.add(
        SchedulePreview(
          classId: req.classId,
          alarmAt: req.alarmAt,
          preNotifAt: null,
        ),
      );
    }
    return result;
  }

  static Future<void> _cancelAllTracked(
    SharedPreferences sp, [
    String? userId,
  ]) async {
    if (userId == null) {
      final raw = sp.getString(_nativeIdsKey);
      if (raw != null) {
        final decoded = _decodeScoped(raw);
        for (final entry in decoded.entries) {
          final ids = (entry.value as List<dynamic>)
              .map((e) => e is int ? e : int.tryParse('$e'))
              .whereType<int>()
              .toSet();
          if (ids.isNotEmpty) {
            await LocalNotifs.cancelMany(ids, userId: entry.key);
          }
        }
      }
      await LocalNotifs.cancelAllNativeAlarms();
      await sp.remove(_nativeIdsKey);
      return;
    }

    final tracked = _readIdSet(sp, _nativeIdsKey, userId);
    if (tracked.isNotEmpty) {
      await LocalNotifs.cancelMany(tracked, userId: userId);
    }
    await _storeIdSet(sp, _nativeIdsKey, <int>{}, userId);
  }

  static Set<int> _readIdSet(
    SharedPreferences sp,
    String key,
    String userId,
  ) {
    final stored = sp.get(key);
    if (stored == null) return <int>{};

    Map<String, dynamic>? decoded;
    if (stored is String) {
      try {
        decoded = jsonDecode(stored) as Map<String, dynamic>;
      } catch (_) {
        decoded = null;
      }
    } else if (stored is List) {
      decoded = {userId: stored};
      unawaited(
        sp.setString(
          key,
          jsonEncode({userId: stored.map((e) => '$e').toList()}),
        ),
      );
    }

    if (decoded == null) return <int>{};
    final scoped = decoded[userId];
    if (scoped is! List) return <int>{};
    return scoped
        .map((e) => e is int ? e : int.tryParse('$e'))
        .whereType<int>()
        .toSet();
  }

  static Future<void> _storeIdSet(
    SharedPreferences sp,
    String key,
    Set<int> ids,
    String userId,
  ) async {
    final raw = sp.getString(key);
    final decoded = raw == null ? <String, dynamic>{} : _decodeScoped(raw);
    if (ids.isEmpty) {
      decoded.remove(userId);
    } else {
      decoded[userId] = ids.map((e) => e.toString()).toList();
    }
    if (decoded.isEmpty) {
      await sp.remove(key);
      return;
    }
    await sp.setString(key, jsonEncode(decoded));
  }

  static Map<String, dynamic> _decodeScoped(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  static int? _readPositive(int? value) {
    if (value == null || value <= 0) return null;
    return value;
  }

  static _AlarmPlan _buildPlan({
    required String uid,
    required List<ClassItem> classes,
    required int leadMinutes,
    required DateTime now,
  }) {
    final requests = <_AlarmRequest>[];
    final lead = Duration(minutes: max(0, leadMinutes));
    for (final item in classes) {
      if (!item.enabled) continue;
      final start = _parseTime(item.start);
      if (start == null) continue;
      final occurrence = _nextOccurrences(now, item.day, start, count: 2);
      for (final classStart in occurrence) {
        final alarmAt = classStart.subtract(lead);
        if (!alarmAt.isAfter(now)) continue;
        final title = _titleForClass(item);

        DateTime? preNotifAt;
        int? preNotifId;
        final headsUpAt = alarmAt.subtract(const Duration(minutes: 1));
        if (headsUpAt.isAfter(now)) {
          preNotifAt = headsUpAt;
          preNotifId = _nativeId(
            uid: uid,
            classId: item.id,
            occurrence: headsUpAt,
            isCustom: item.isCustom,
            isHeadsUp: true,
          );
        }

        final request = _AlarmRequest(
          classId: item.id,
          nativeId: _nativeId(
            uid: uid,
            classId: item.id,
            occurrence: classStart,
            isCustom: item.isCustom,
            isHeadsUp: false,
          ),
          alarmAt: alarmAt,
          title: title,
          body: _bodyForClass(item),
          occurrenceKey: _occurrenceKey(classStart),
          subject: title,
          room: _normalizeRoom(item.room),
          startLabel: _formatTimeLabel(item.start),
          endLabel: _formatTimeLabel(item.end),
          preNotifId: preNotifId,
          preNotifAt: preNotifAt,
        );
        requests.add(request);
      }
    }
    requests.sort((a, b) => a.alarmAt.compareTo(b.alarmAt));
    return _AlarmPlan(now: now, requests: requests);
  }

  static List<DateTime> _nextOccurrences(
    DateTime now,
    int dayOfWeek,
    Duration start, {
    int count = 1,
  }) {
    if (dayOfWeek < DateTime.monday || dayOfWeek > DateTime.sunday) {
      return <DateTime>[];
    }
    final results = <DateTime>[];
    var base = DateTime(
      now.year,
      now.month,
      now.day,
      start.inHours,
      start.inMinutes.remainder(60),
    );
    var daysToAdd = (dayOfWeek - now.weekday) % 7;
    if (daysToAdd < 0) daysToAdd += 7;
    base = base.add(Duration(days: daysToAdd));
    while (results.length < count) {
      if (!base.isAfter(now)) {
        base = base.add(const Duration(days: 7));
        continue;
      }
      results.add(base);
      base = base.add(const Duration(days: 7));
    }
    return results;
  }

  static Duration? _parseTime(String value) {
    final trimmed = value.trim();
    final pattern =
        RegExp(r'^\s*(\d{1,2}):(\d{2})(?::(\d{2}))?(?:\s*(AM|PM))?\s*$');
    final match = pattern.firstMatch(trimmed);
    if (match == null) return null;
    var hours = int.tryParse(match.group(1) ?? '') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '') ?? 0;
    final meridiem = match.group(4)?.toUpperCase();
    if (meridiem == 'AM') {
      if (hours == 12) hours = 0;
    } else if (meridiem == 'PM') {
      if (hours != 12) hours += 12;
    }
    hours %= 24;
    return Duration(hours: hours, minutes: minutes);
  }

  static String _titleForClass(ClassItem item) {
    return item.title?.trim().isNotEmpty == true
        ? item.title!.trim()
        : (item.code?.trim().isNotEmpty == true
            ? item.code!.trim()
            : 'Class Reminder');
  }

  static String _bodyForClass(ClassItem item) {
    final room = item.room?.trim();
    final range = _formatRange(item.start, item.end);
    if (room != null && room.isNotEmpty) {
      return '$room - $range';
    }
    return range;
  }

  static String? _normalizeRoom(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String _formatTimeLabel(String value) {
    final duration = _parseTime(value);
    if (duration == null) return value.trim();
    var hour = duration.inHours;
    final minute = duration.inMinutes.remainder(60);
    final suffix = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm $suffix';
  }

  static String _formatRange(String start, String end) {
    String format(String value) {
      final parts = value.split(':');
      if (parts.length < 2) return value;
      var hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final suffix = hour < 12 ? 'AM' : 'PM';
      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }
      final hh = hour.toString().padLeft(2, '0');
      final mm = minute.toString().padLeft(2, '0');
      return '$hh:$mm $suffix';
    }

    return '${format(start)} - ${format(end)}';
  }

  static int _nativeId({
    required String uid,
    required int classId,
    required DateTime occurrence,
    required bool isCustom,
    required bool isHeadsUp,
  }) {
    final millis = occurrence.millisecondsSinceEpoch;
    final hash = Object.hashAll([
      uid,
      classId,
      millis,
      isCustom ? 1 : 0,
      isHeadsUp ? 1 : 0,
    ]);
    return hash & 0x7fffffff;
  }

  static String _occurrenceKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$y$m$dd';
  }

  static Future<Set<int>> _collectScheduledNativeIds({String? userId}) async {
    final map = await LocalNotifs.scheduledIdMap(userId: userId);
    final result = <int>{};
    for (final ids in map.values) {
      result.addAll(ids);
    }
    return result;
  }

  static bool _isAndroid() => LocalNotifs.isAndroidContext;

  static Future<void> ensurePreferenceMigration(
      {SharedPreferences? prefs}) async {
    final sp = prefs ?? await SharedPreferences.getInstance();
    var changed = false;

    int? positiveOrNull(int? value) =>
        value != null && value > 0 ? value : null;

    final lead = sp.getInt('notifLeadMinutes');
    if (positiveOrNull(lead) == null) {
      final legacy = positiveOrNull(
            sp.getInt('default_notif_minutes') ?? sp.getInt('alert_minutes'),
          ) ??
          10;
      await sp.setInt('notifLeadMinutes', legacy);
      changed = true;
    }

    final snooze = sp.getInt('snoozeMinutes');
    if (positiveOrNull(snooze) == null) {
      final legacy = positiveOrNull(sp.getInt('default_snooze_minutes')) ?? 5;
      await sp.setInt('snoozeMinutes', legacy);
      changed = true;
    }

    if (!sp.containsKey('quiet_week_enabled')) {
      await sp.setBool('quiet_week_enabled', false);
    }

    if (!sp.containsKey('alarm_verbose_logging')) {
      await sp.setBool('alarm_verbose_logging', false);
    }

    if (changed) {
      if (LocalNotifs.debugLogExactAlarms) {
        AppLog.info(
          'NotifScheduler',
          'Migrated legacy notification prefs',
        );
      }
    }
  }
}

class SchedulePreview {
  const SchedulePreview({
    required this.classId,
    required this.alarmAt,
    required this.preNotifAt,
  });

  final int classId;
  final DateTime alarmAt;
  final DateTime? preNotifAt;
}

class _AlarmPlan {
  _AlarmPlan({required this.now, required this.requests});

  final DateTime now;
  final List<_AlarmRequest> requests;
}

class _AlarmRequest {
  _AlarmRequest({
    required this.classId,
    required this.nativeId,
    required this.alarmAt,
    required this.title,
    required this.body,
    required this.occurrenceKey,
    this.subject,
    this.room,
    this.startLabel,
    this.endLabel,
    this.preNotifId,
    this.preNotifAt,
  });

  final int classId;
  final int nativeId;
  final DateTime alarmAt;
  final String title;
  final String body;
  final String occurrenceKey;
  final String? subject;
  final String? room;
  final String? startLabel;
  final String? endLabel;
  final int? preNotifId;
  final DateTime? preNotifAt;

  bool shouldScheduleAlarm(DateTime now) => alarmAt.isAfter(now);

  bool shouldScheduleHeadsUp(DateTime now) =>
      preNotifAt != null && preNotifAt!.isAfter(now);
}
