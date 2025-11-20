import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/utils/local_notifs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    LocalNotifs.debugForceAndroid = true;
  });

  tearDown(() {
    LocalNotifs.debugForceAndroid = false;
  });

  test('ack store records and reads occurrence flags', () async {
    const classId = 42;
    const occurrenceKey = '20240115';

    expect(
      await LocalNotifs.isOccurrenceAcknowledged(
        classId: classId,
        occurrenceKey: occurrenceKey,
      ),
      isFalse,
    );

    await LocalNotifs.markOccurrenceAcknowledged(
      classId: classId,
      occurrenceKey: occurrenceKey,
    );

    expect(
      await LocalNotifs.isOccurrenceAcknowledged(
        classId: classId,
        occurrenceKey: occurrenceKey,
      ),
      isTrue,
    );
  });

  test('clearPersistentState removes tracked notification data', () async {
    SharedPreferences.setMockInitialValues(const {
      'scheduled_native_alarm_ids': '{"_anon":["101","102"]}',
      'notif_class_schedule_map': '{"_anon":{"42":[9001]}}',
      'notif_ack_map': '{"_anon":{"42":["20240201"]}}',
    });

    await LocalNotifs.clearPersistentState();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('scheduled_native_alarm_ids'), isFalse);
    expect(prefs.containsKey('notif_class_schedule_map'), isFalse);
    expect(prefs.containsKey('notif_ack_map'), isFalse);
  });
}
