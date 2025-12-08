import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/notification_scheduler.dart';
import 'package:mysched/services/schedule_repository.dart';
import 'package:mysched/utils/local_notifs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers/supabase_stub.dart';

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
  });

  tearDown(() {
    LocalNotifs.debugForceAndroid = false;
    LocalNotifs.debugScheduleOverride = null;
    LocalNotifs.debugCancelOverride = null;
    LocalNotifs.debugCancelManyOverride = null;
    LocalNotifs.debugSnoozeFeedbackOverride = null;
  });

  test('resync schedules alarms for custom classes', () async {
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
        'title': title,
        'isCustom': true, // We can't easily check this here without decoding ID, but classId helps
      });
      return true;
    };

    // Create a custom class that starts 1 hour from now
    final now = DateTime.now();
    final start = now.add(const Duration(hours: 1));
    final end = start.add(const Duration(hours: 1));
    
    // Format time as HH:MM
    String formatTime(DateTime dt) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    final customClass = ClassItem(
      id: 999,
      day: start.weekday,
      start: formatTime(start),
      end: formatTime(end),
      title: 'Custom Study Session',
      room: 'Library',
      instructor: 'Self',
      enabled: true,
      isCustom: true,
    );

    final api = _FakeScheduleApi([customClass]);

    await NotifScheduler.resync(
      api: api,
      userId: 'user-custom-test',
    );

    // Should schedule an alarm (and maybe a heads-up notification)
    // Default lead time is 10 minutes.
    // So alarm should be at start - 10 mins.
    
    expect(scheduledCalls, isNotEmpty);
    
    final alarmCall = scheduledCalls.firstWhere(
      (call) => call['classId'] == 999,
      orElse: () => {},
    );
    
    expect(alarmCall, isNotEmpty, reason: 'Custom class alarm should be scheduled');
    expect(alarmCall['title'], 'Custom Study Session');
  });
}
