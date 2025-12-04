import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/data_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DataSync', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      DataSync.resetInstance();
    });

    tearDown(() {
      DataSync.resetInstance();
    });

    test('singleton returns same instance', () {
      final instance1 = DataSync.instance;
      final instance2 = DataSync.instance;
      expect(identical(instance1, instance2), true);
    });

    test('initial sync timestamps are null', () {
      final sync = DataSync.instance;
      expect(sync.lastScheduleSync.value, isNull);
      expect(sync.lastRemindersSync.value, isNull);
      expect(sync.lastProfileSync.value, isNull);
    });

    test('initial syncing states are false', () {
      final sync = DataSync.instance;
      expect(sync.isScheduleSyncing.value, false);
      expect(sync.isRemindersSyncing.value, false);
    });

    group('notifyScheduleChanged', () {
      test('updates lastScheduleSync timestamp', () {
        final sync = DataSync.instance;
        expect(sync.lastScheduleSync.value, isNull);

        sync.notifyScheduleChanged();

        expect(sync.lastScheduleSync.value, isNotNull);
        expect(
          sync.lastScheduleSync.value!.difference(DateTime.now()).inSeconds.abs(),
          lessThan(2),
        );
      });

      test('emits event on schedule stream', () async {
        final sync = DataSync.instance;
        final events = <ScheduleEvent>[];
        final sub = sync.scheduleEvents.listen(events.add);

        sync.notifyScheduleChanged(type: ScheduleChangeType.classAdded, classId: 42);

        await Future.delayed(const Duration(milliseconds: 50));
        await sub.cancel();

        expect(events.length, 1);
        expect(events.first.type, ScheduleChangeType.classAdded);
        expect(events.first.classId, 42);
      });
    });

    group('notifyRemindersChanged', () {
      test('updates lastRemindersSync timestamp', () {
        final sync = DataSync.instance;
        expect(sync.lastRemindersSync.value, isNull);

        sync.notifyRemindersChanged();

        expect(sync.lastRemindersSync.value, isNotNull);
      });

      test('emits event on reminders stream', () async {
        final sync = DataSync.instance;
        final events = <RemindersEvent>[];
        final sub = sync.remindersEvents.listen(events.add);

        sync.notifyRemindersChanged(
          type: RemindersChangeType.reminderCompleted,
          reminderId: 123,
        );

        await Future.delayed(const Duration(milliseconds: 50));
        await sub.cancel();

        expect(events.length, 1);
        expect(events.first.type, RemindersChangeType.reminderCompleted);
        expect(events.first.reminderId, 123);
      });
    });

    group('notifyProfileChanged', () {
      test('updates lastProfileSync timestamp', () {
        final sync = DataSync.instance;
        expect(sync.lastProfileSync.value, isNull);

        sync.notifyProfileChanged();

        expect(sync.lastProfileSync.value, isNotNull);
      });

      test('emits event on profile stream', () async {
        final sync = DataSync.instance;
        final events = <ProfileEvent>[];
        final sub = sync.profileEvents.listen(events.add);

        sync.notifyProfileChanged(type: ProfileChangeType.nameUpdated, userId: 'user-123');

        await Future.delayed(const Duration(milliseconds: 50));
        await sub.cancel();

        expect(events.length, 1);
        expect(events.first.type, ProfileChangeType.nameUpdated);
        expect(events.first.userId, 'user-123');
      });
    });

    test('init restores persisted timestamps', () async {
      // Set initial values
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().subtract(const Duration(hours: 1));
      await prefs.setInt('sync_last_schedule', timestamp.millisecondsSinceEpoch);

      DataSync.resetInstance();
      final sync = DataSync.instance;
      await sync.init();

      expect(sync.lastScheduleSync.value, isNotNull);
      expect(
        sync.lastScheduleSync.value!.millisecondsSinceEpoch,
        timestamp.millisecondsSinceEpoch,
      );
    });
  });

  group('ScheduleEvent', () {
    test('stores all properties', () {
      final now = DateTime.now();
      final event = ScheduleEvent(
        type: ScheduleChangeType.classDeleted,
        classId: 42,
        userId: 'user-abc',
        timestamp: now,
      );

      expect(event.type, ScheduleChangeType.classDeleted);
      expect(event.classId, 42);
      expect(event.userId, 'user-abc');
      expect(event.timestamp, now);
    });
  });

  group('ScheduleChangeType', () {
    test('has expected values', () {
      expect(ScheduleChangeType.values.contains(ScheduleChangeType.refresh), true);
      expect(ScheduleChangeType.values.contains(ScheduleChangeType.classAdded), true);
      expect(ScheduleChangeType.values.contains(ScheduleChangeType.classUpdated), true);
      expect(ScheduleChangeType.values.contains(ScheduleChangeType.classDeleted), true);
    });
  });

  group('RemindersChangeType', () {
    test('has expected values', () {
      expect(RemindersChangeType.values.contains(RemindersChangeType.refresh), true);
      expect(RemindersChangeType.values.contains(RemindersChangeType.reminderAdded), true);
      expect(RemindersChangeType.values.contains(RemindersChangeType.reminderCompleted), true);
      expect(RemindersChangeType.values.contains(RemindersChangeType.reminderDeleted), true);
    });
  });
}
