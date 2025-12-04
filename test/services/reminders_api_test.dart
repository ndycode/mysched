import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/reminders_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../test_helpers/supabase_stub.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await SupabaseTestBootstrap.ensureInitialized();
  });

  group('Reminder status helpers', () {
    test('round-trips between enum and string', () {
      expect(reminderStatusFromString('completed'), ReminderStatus.completed);
      expect(reminderStatusFromString('pending'), ReminderStatus.pending);
      expect(reminderStatusFromString('unknown'), ReminderStatus.pending);

      expect(reminderStatusToString(ReminderStatus.completed), 'completed');
      expect(reminderStatusToString(ReminderStatus.pending), 'pending');
    });
  });

  group('ReminderEntry', () {
    test('parses from map and exposes flags', () {
      final now = DateTime.now().toUtc();
      final entry = ReminderEntry.fromMap({
        'id': 1,
        'user_id': 'u1',
        'title': 'Exam',
        'details': 'Chapter 3',
        'due_at': now.subtract(const Duration(hours: 1)).toIso8601String(),
        'status': 'pending',
        'snooze_until': now.add(const Duration(minutes: 30)).toIso8601String(),
        'completed_at': null,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      expect(entry.isCompleted, isFalse);
      expect(entry.isOverdue, isTrue);
      expect(entry.isSnoozed, isTrue);
      expect(entry.details, 'Chapter 3');
    });

    test('computed flags respect completion', () {
      final now = DateTime.now();
      final pending = ReminderEntry(
        id: 5,
        userId: 'u2',
        title: 'Submit report',
        details: null,
        dueAt: now.subtract(const Duration(minutes: 10)),
        status: ReminderStatus.pending,
        snoozeUntil: null,
        completedAt: null,
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now,
      );

      expect(pending.isOverdue, isTrue);
      expect(pending.isSnoozed, isFalse);

      final completed = pending.copyWith(
        status: ReminderStatus.completed,
        completedAt: now,
      );

      expect(completed.isCompleted, isTrue);
      expect(completed.isOverdue, isFalse);
      expect(completed.isSnoozed, isFalse);
    });

    test('snoozed flag holds for future snooze window', () {
      final now = DateTime.now();
      final due = now.add(const Duration(hours: 1));
      final snoozed = due.add(const Duration(hours: 2));
      final entry = ReminderEntry(
        id: 6,
        userId: 'u4',
        title: 'Snoozed',
        details: null,
        dueAt: due,
        status: ReminderStatus.pending,
        snoozeUntil: snoozed,
        completedAt: null,
        createdAt: now,
        updatedAt: now,
      );

      expect(entry.isSnoozed, isTrue);
      expect(entry.isOverdue, isFalse);
    });

    test('copyWith updates fields immutably', () {
      final now = DateTime.now();
      final entry = ReminderEntry(
        id: 9,
        userId: 'u3',
        title: 'Original',
        details: null,
        dueAt: now,
        status: ReminderStatus.pending,
        snoozeUntil: null,
        completedAt: null,
        createdAt: now,
        updatedAt: now,
      );

      final updated = entry.copyWith(
        title: 'Updated',
        details: 'More info',
        dueAt: now.add(const Duration(hours: 2)),
        status: ReminderStatus.completed,
      );

      expect(updated.title, 'Updated');
      expect(updated.details, 'More info');
      expect(updated.status, ReminderStatus.completed);
      expect(updated.dueAt.isAfter(entry.dueAt), isTrue);
      expect(entry.title, 'Original', reason: 'original should remain untouched');
    });
  });

  group('retry logic', () {
    test('retries transient errors and succeeds', () async {
      final api = RemindersApi(client: Supabase.instance.client);
      var attempts = 0;
      final result = await api.debugRetry<int>(() async {
        attempts++;
        if (attempts < 3) throw Exception('socket timeout');
        return 7;
      });
      expect(result, 7);
      expect(attempts, 3);
    });

    test('stops on non-retryable error', () async {
      final api = RemindersApi(client: Supabase.instance.client);
      var attempts = 0;
      expect(
        () => api.debugRetry<void>(() async {
          attempts++;
          throw const AuthException('not authenticated');
        }),
        throwsA(isA<AuthException>()),
      );
      expect(attempts, 1);
    });

    test('classifies retryable errors', () {
      final api = RemindersApi(client: Supabase.instance.client);
      expect(api.debugIsRetryable(Exception('network down')), isTrue);
      expect(api.debugIsRetryable(Exception('timeout')), isTrue);
      expect(api.debugIsRetryable(Exception('already exists')), isFalse);
      expect(api.debugIsRetryable(const AuthException('nope')), isFalse);
    });
  });
}
