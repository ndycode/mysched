import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/reminders_repository.dart';

void main() {
  group('ReminderStatus', () {
    test('has expected values', () {
      expect(ReminderStatus.values.length, 2);
      expect(ReminderStatus.values.contains(ReminderStatus.pending), true);
      expect(ReminderStatus.values.contains(ReminderStatus.completed), true);
    });
  });

  group('reminderStatusFromString', () {
    test('parses pending', () {
      expect(reminderStatusFromString('pending'), ReminderStatus.pending);
    });

    test('parses completed', () {
      expect(reminderStatusFromString('completed'), ReminderStatus.completed);
    });

    test('defaults to pending for unknown values', () {
      expect(reminderStatusFromString('unknown'), ReminderStatus.pending);
      expect(reminderStatusFromString(''), ReminderStatus.pending);
    });
  });

  group('reminderStatusToString', () {
    test('converts pending', () {
      expect(reminderStatusToString(ReminderStatus.pending), 'pending');
    });

    test('converts completed', () {
      expect(reminderStatusToString(ReminderStatus.completed), 'completed');
    });
  });

  group('ReminderEntry', () {
    group('fromMap', () {
      test('parses complete map', () {
        final map = {
          'id': 1,
          'user_id': 'user-123',
          'title': 'Test Reminder',
          'details': 'Some details',
          'due_at': '2024-06-15T10:30:00.000Z',
          'status': 'pending',
          'snooze_until': '2024-06-15T11:00:00.000Z',
          'completed_at': null,
          'created_at': '2024-06-01T09:00:00.000Z',
          'updated_at': '2024-06-10T12:00:00.000Z',
        };

        final entry = ReminderEntry.fromMap(map);

        expect(entry.id, 1);
        expect(entry.userId, 'user-123');
        expect(entry.title, 'Test Reminder');
        expect(entry.details, 'Some details');
        expect(entry.dueAt.year, 2024);
        expect(entry.dueAt.month, 6);
        expect(entry.dueAt.day, 15);
        expect(entry.status, ReminderStatus.pending);
        expect(entry.snoozeUntil, isNotNull);
        expect(entry.completedAt, isNull);
      });

      test('parses completed reminder', () {
        final map = {
          'id': 2,
          'user_id': 'user-456',
          'title': 'Done Task',
          'details': null,
          'due_at': '2024-06-10T08:00:00.000Z',
          'status': 'completed',
          'snooze_until': null,
          'completed_at': '2024-06-09T15:00:00.000Z',
          'created_at': '2024-06-01T00:00:00.000Z',
          'updated_at': '2024-06-09T15:00:00.000Z',
        };

        final entry = ReminderEntry.fromMap(map);

        expect(entry.status, ReminderStatus.completed);
        expect(entry.completedAt, isNotNull);
        expect(entry.isCompleted, true);
      });

      test('handles null optional fields', () {
        final map = {
          'id': 3,
          'user_id': 'user-789',
          'title': 'Minimal',
          'details': null,
          'due_at': '2024-06-15T12:00:00.000Z',
          'status': 'pending',
          'snooze_until': null,
          'completed_at': null,
          'created_at': '2024-06-01T00:00:00.000Z',
          'updated_at': '2024-06-01T00:00:00.000Z',
        };

        final entry = ReminderEntry.fromMap(map);

        expect(entry.details, isNull);
        expect(entry.snoozeUntil, isNull);
        expect(entry.completedAt, isNull);
      });
    });

    group('computed properties', () {
      test('isCompleted returns true for completed status', () {
        final entry = ReminderEntry(
          id: 1,
          userId: 'user',
          title: 'Test',
          dueAt: DateTime.now(),
          status: ReminderStatus.completed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(entry.isCompleted, true);
      });

      test('isCompleted returns false for pending status', () {
        final entry = ReminderEntry(
          id: 1,
          userId: 'user',
          title: 'Test',
          dueAt: DateTime.now(),
          status: ReminderStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(entry.isCompleted, false);
      });

      test('isOverdue returns true for past due pending reminder', () {
        final entry = ReminderEntry(
          id: 1,
          userId: 'user',
          title: 'Test',
          dueAt: DateTime.now().subtract(const Duration(days: 1)),
          status: ReminderStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(entry.isOverdue, true);
      });

      test('isOverdue returns false for completed reminder', () {
        final entry = ReminderEntry(
          id: 1,
          userId: 'user',
          title: 'Test',
          dueAt: DateTime.now().subtract(const Duration(days: 1)),
          status: ReminderStatus.completed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(entry.isOverdue, false);
      });

      test('isOverdue returns false for future due date', () {
        final entry = ReminderEntry(
          id: 1,
          userId: 'user',
          title: 'Test',
          dueAt: DateTime.now().add(const Duration(days: 1)),
          status: ReminderStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(entry.isOverdue, false);
      });

      test('isSnoozed returns true when snoozed until future', () {
        final entry = ReminderEntry(
          id: 1,
          userId: 'user',
          title: 'Test',
          dueAt: DateTime.now(),
          status: ReminderStatus.pending,
          snoozeUntil: DateTime.now().add(const Duration(hours: 1)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(entry.isSnoozed, true);
      });

      test('isSnoozed returns false when snooze time has passed', () {
        final entry = ReminderEntry(
          id: 1,
          userId: 'user',
          title: 'Test',
          dueAt: DateTime.now(),
          status: ReminderStatus.pending,
          snoozeUntil: DateTime.now().subtract(const Duration(hours: 1)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(entry.isSnoozed, false);
      });

      test('isSnoozed returns false for completed reminder', () {
        final entry = ReminderEntry(
          id: 1,
          userId: 'user',
          title: 'Test',
          dueAt: DateTime.now(),
          status: ReminderStatus.completed,
          snoozeUntil: DateTime.now().add(const Duration(hours: 1)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(entry.isSnoozed, false);
      });

      test('isSnoozed returns false when snoozeUntil is null', () {
        final entry = ReminderEntry(
          id: 1,
          userId: 'user',
          title: 'Test',
          dueAt: DateTime.now(),
          status: ReminderStatus.pending,
          snoozeUntil: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(entry.isSnoozed, false);
      });
    });

    group('copyWith', () {
      test('copies with new values', () {
        final original = ReminderEntry(
          id: 1,
          userId: 'user',
          title: 'Original',
          dueAt: DateTime(2024, 6, 15),
          status: ReminderStatus.pending,
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        final copy = original.copyWith(
          title: 'Modified',
          status: ReminderStatus.completed,
        );

        expect(copy.id, 1);
        expect(copy.userId, 'user');
        expect(copy.title, 'Modified');
        expect(copy.status, ReminderStatus.completed);
        expect(copy.dueAt, original.dueAt);
      });

      test('preserves original when no values provided', () {
        final original = ReminderEntry(
          id: 1,
          userId: 'user',
          title: 'Original',
          details: 'Details',
          dueAt: DateTime(2024, 6, 15),
          status: ReminderStatus.pending,
          snoozeUntil: DateTime(2024, 6, 16),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.userId, original.userId);
        expect(copy.title, original.title);
        expect(copy.details, original.details);
        expect(copy.dueAt, original.dueAt);
        expect(copy.status, original.status);
        expect(copy.snoozeUntil, original.snoozeUntil);
      });
    });
  });
}
