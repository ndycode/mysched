import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/notif_scheduler.dart';
import 'package:mysched/services/schedule_api.dart';
import '../test_helpers/supabase_stub.dart';
import 'package:mysched/utils/local_notifs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeScheduleApi extends ScheduleApi {
  _FakeScheduleApi(this.classes);

  final List<ClassItem> classes;

  @override
  Future<List<ClassItem>> getMyClasses({bool forceRefresh = false}) async =>
      List<ClassItem>.from(classes);

  @override
  Future<List<ClassItem>> fetchClasses() async => classes;
}

void main() {
  setUpAll(() async {
    await SupabaseTestBootstrap.ensureInitialized();
  });
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    LocalNotifs.debugForceAndroid = true;
    LocalNotifs.debugScheduleOverride = null;
    LocalNotifs.debugCancelOverride = null;
    LocalNotifs.debugCancelManyOverride = null;
    LocalNotifs.debugSnoozeFeedbackOverride = (_) async {};
    NotifScheduler.onSnoozed = null;
  });

  tearDown(() {
    LocalNotifs.debugForceAndroid = false;
    LocalNotifs.debugScheduleOverride = null;
    LocalNotifs.debugCancelOverride = null;
    LocalNotifs.debugCancelManyOverride = null;
    LocalNotifs.debugSnoozeFeedbackOverride = null;
    NotifScheduler.onSnoozed = null;
  });

  group('preview', () {
    test('applies lead minutes when computing alarm times', () {
      final now = DateTime(2024, 1, 1, 7, 0);
      final classes = [
        ClassItem(
          id: 12,
          day: DateTime.monday,
          start: '08:00',
          end: '09:00',
          title: 'Linear Algebra',
          room: 'Room 204',
          instructor: 'Prof. Smith',
          enabled: true,
          isCustom: false,
        ),
      ];

      final previews = NotifScheduler.preview(
        uid: 'user-123',
        classes: classes,
        leadMinutes: 15,
        now: now,
      );

      expect(previews, hasLength(greaterThanOrEqualTo(1)));
      expect(previews.first.alarmAt, DateTime(2024, 1, 1, 7, 45));
    });
  });

  group('snooze', () {
    test('replaces stale ids when stored map is corrupt', () async {
      SharedPreferences.setMockInitialValues(const {
        'scheduled_native_alarm_ids': '{"user-123":["1001"]}',
        'notif_class_schedule_map': 'corrupt',
      });

      final scheduledCalls = <Map<String, Object?>>[];

      LocalNotifs.debugCancelManyOverride = (_, {String? userId}) async {};
      LocalNotifs.debugScheduleOverride = ({
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
        scheduledCalls.add({
          'id': id,
          'at': at,
          'classId': classId,
        });
        return true;
      };

      final api = _FakeScheduleApi([
        ClassItem(
          id: 7,
          day: DateTime.monday,
          start: '10:00',
          end: '11:00',
          title: 'Physics',
          room: 'Lab 1',
          instructor: 'Dr. Ray',
          enabled: true,
          isCustom: false,
        ),
      ]);

      await NotifScheduler.snooze(
        7,
        minutes: 5,
        api: api,
        userId: 'user-123',
      );

      expect(scheduledCalls, hasLength(1));
      final call = scheduledCalls.single;
      final newId = call['id'] as int;

      final storedIds =
          (await _readStoredIds('user-123')).map(int.parse).toSet();
      expect(storedIds, equals({newId}));

      final prefs = await SharedPreferences.getInstance();
      final mapJson = prefs.getString('notif_class_schedule_map');
      expect(mapJson, isNotNull);
      final decoded = jsonDecode(mapJson!) as Map<String, dynamic>;
      final scoped = decoded['user-123'] as Map<String, dynamic>;
      final classIds =
          (scoped['7'] as List<dynamic>).map((e) => int.parse('$e')).toSet();
      expect(classIds, equals({newId}));
    });

    test('snooze with zero minutes schedules at least one minute out',
        () async {
      SharedPreferences.setMockInitialValues(const {});

      final scheduledCalls = <Map<String, Object?>>[];

      LocalNotifs.debugSnoozeFeedbackOverride = (_) async {};
      LocalNotifs.debugCancelManyOverride = (_, {String? userId}) async {};
      LocalNotifs.debugScheduleOverride = ({
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
        scheduledCalls.add({
          'id': id,
          'at': at,
          'classId': classId,
        });
        return true;
      };

      final api = _FakeScheduleApi([
        ClassItem(
          id: 9,
          day: DateTime.tuesday,
          start: '12:00',
          end: '13:00',
          title: 'Chemistry',
          room: 'Lab 2',
          instructor: 'Dr. Ana',
          enabled: true,
          isCustom: false,
        ),
      ]);

      final before = DateTime.now();
      await NotifScheduler.snooze(
        9,
        minutes: 0,
        api: api,
        userId: 'user-321',
      );

      expect(scheduledCalls, hasLength(1));
      final at = scheduledCalls.single['at'] as DateTime;
      expect(at.difference(before).inMinutes, greaterThanOrEqualTo(1));

      final storedIds = await _readStoredIds('user-321');
      expect(storedIds.length, 1);
    });

    test('triggers snooze feedback callbacks and notifications', () async {
      SharedPreferences.setMockInitialValues(const {});

      LocalNotifs.debugCancelManyOverride = (_, {String? userId}) async {};
      LocalNotifs.debugScheduleOverride = ({
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
        return true;
      };

      var feedbackMinutes = 0;
      var callback = 0;
      LocalNotifs.debugSnoozeFeedbackOverride = (minutes) async {
        feedbackMinutes = minutes;
      };
      NotifScheduler.onSnoozed = (classId, minutes) {
        callback = minutes;
      };

      final api = _FakeScheduleApi([
        ClassItem(
          id: 11,
          day: DateTime.wednesday,
          start: '14:00',
          end: '15:00',
          title: 'Biology',
          room: 'Lab 5',
          instructor: 'Dr. M',
          enabled: true,
          isCustom: false,
        ),
      ]);

      await NotifScheduler.snooze(11, minutes: 7, api: api, userId: 'user-111');

      expect(feedbackMinutes, 7);
      expect(callback, 7);
    });

    test('quiet week skips scheduling but still reports feedback', () async {
      SharedPreferences.setMockInitialValues(const {
        'quiet_week_enabled': true,
      });

      var feedbackMinutes = 0;
      LocalNotifs.debugSnoozeFeedbackOverride = (minutes) async {
        feedbackMinutes = minutes;
      };
      var scheduled = false;
      LocalNotifs.debugScheduleOverride = ({
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
        scheduled = true;
        return true;
      };

      final api = _FakeScheduleApi([
        ClassItem(
          id: 21,
          day: DateTime.thursday,
          start: '09:00',
          end: '10:00',
          title: 'History',
          room: 'Hall A',
          instructor: 'Dr. W',
          enabled: true,
          isCustom: false,
        ),
      ]);

      await NotifScheduler.snooze(21,
          minutes: 4, api: api, userId: 'user-quiet');

      expect(scheduled, isFalse);
      expect(feedbackMinutes, 4);
    });
  });

  group('resync', () {
    test('cancels alarms when quiet week enabled', () async {
      SharedPreferences.setMockInitialValues(const {
        'quiet_week_enabled': true,
        'scheduled_native_alarm_ids': '{"user-quiet":[101,102]}',
      });

      final cancelled = <int>[];
      LocalNotifs.debugCancelManyOverride = (ids, {String? userId}) async {
        cancelled.addAll(ids);
      };

      await NotifScheduler.resync(
        api: _FakeScheduleApi([
          ClassItem(
            id: 1,
            day: DateTime.friday,
            start: '08:00',
            end: '09:00',
            title: 'PE',
            room: 'Gym',
            instructor: 'Coach',
            enabled: true,
            isCustom: false,
          ),
        ]),
        userId: 'user-quiet',
      );

      expect(cancelled.toSet(), equals({101, 102}));
    });
  });

  group('preference migration', () {
    test('promotes legacy keys when new ones missing', () async {
      SharedPreferences.setMockInitialValues(const {
        'default_notif_minutes': 12,
        'default_snooze_minutes': 6,
      });

      final prefs = await SharedPreferences.getInstance();
      await NotifScheduler.ensurePreferenceMigration(prefs: prefs);

      expect(prefs.getInt('notifLeadMinutes'), 12);
      expect(prefs.getInt('snoozeMinutes'), 6);
      expect(prefs.getBool('quiet_week_enabled'), isFalse);
      expect(prefs.getBool('alarm_verbose_logging'), isFalse);
    });

    test('ignores invalid legacy values and applies defaults', () async {
      SharedPreferences.setMockInitialValues(const {
        'default_notif_minutes': 0,
        'default_snooze_minutes': -2,
      });

      final prefs = await SharedPreferences.getInstance();
      await NotifScheduler.ensurePreferenceMigration(prefs: prefs);

      expect(prefs.getInt('notifLeadMinutes'), 5);
      expect(prefs.getInt('snoozeMinutes'), 5);
      expect(prefs.getBool('quiet_week_enabled'), isFalse);
      expect(prefs.getBool('alarm_verbose_logging'), isFalse);
    });
  });
}

Future<List<String>> _readStoredIds(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('scheduled_native_alarm_ids');
  if (raw == null) return <String>[];
  try {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = decoded[userId];
    if (list is List) {
      return list.map((e) => '$e').toList();
    }
  } catch (_) {
    return <String>[];
  }
  return <String>[];
}
