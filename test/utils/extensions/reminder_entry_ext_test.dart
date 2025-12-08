import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/reminders_repository.dart';
import 'package:mysched/utils/extensions/reminder_entry_ext.dart';

void main() {
  group('ReminderEntryJson', () {
    test('toJson converts entry to map', () {
      final entry = ReminderEntry(
        id: 1,
        userId: 'user-123',
        title: 'Test Reminder',
        details: 'Test details',
        dueAt: DateTime(2024, 6, 15, 10, 30),
        status: ReminderStatus.pending,
        snoozeUntil: DateTime(2024, 6, 15, 11, 0),
        completedAt: null,
        createdAt: DateTime(2024, 6, 1, 9, 0),
        updatedAt: DateTime(2024, 6, 10, 12, 0),
      );

      final json = entry.toJson();

      expect(json['id'], 1);
      expect(json['user_id'], 'user-123');
      expect(json['title'], 'Test Reminder');
      expect(json['details'], 'Test details');
      expect(json['due_at'], '2024-06-15T10:30:00.000');
      expect(json['status'], 'pending');
      expect(json['snooze_until'], '2024-06-15T11:00:00.000');
      expect(json['completed_at'], isNull);
      expect(json['created_at'], '2024-06-01T09:00:00.000');
      expect(json['updated_at'], '2024-06-10T12:00:00.000');
    });

    test('toJson handles completed status', () {
      final entry = ReminderEntry(
        id: 2,
        userId: 'user-456',
        title: 'Completed Task',
        details: null,
        dueAt: DateTime(2024, 6, 10),
        status: ReminderStatus.completed,
        snoozeUntil: null,
        completedAt: DateTime(2024, 6, 9, 15, 0),
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 9, 15, 0),
      );

      final json = entry.toJson();

      expect(json['status'], 'completed');
      expect(json['completed_at'], isNotNull);
      expect(json['snooze_until'], isNull);
      expect(json['details'], isNull);
    });

    test('toJson handles null optional fields', () {
      final entry = ReminderEntry(
        id: 3,
        userId: 'user-789',
        title: 'Minimal Task',
        details: null,
        dueAt: DateTime(2024, 6, 15),
        status: ReminderStatus.pending,
        snoozeUntil: null,
        completedAt: null,
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 15),
      );

      final json = entry.toJson();

      expect(json['details'], isNull);
      expect(json['snooze_until'], isNull);
      expect(json['completed_at'], isNull);
    });
  });
}
