import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/models/reminder_scope.dart';

void main() {
  group('ReminderScope.includes', () {
    test('matches only today for today scope', () {
      final reference = DateTime(2025, 3, 3); // Monday
      expect(
        ReminderScope.today.includes(DateTime(2025, 3, 3, 8), reference),
        isTrue,
      );
      expect(
        ReminderScope.today.includes(DateTime(2025, 3, 4, 8), reference),
        isFalse,
      );
    });

    test('covers start and end of week for week scope', () {
      final reference = DateTime(2025, 3, 3); // Monday
      expect(
        ReminderScope.week.includes(DateTime(2025, 3, 9), reference),
        isTrue,
      ); // Sunday of same week
      expect(
        ReminderScope.week.includes(DateTime(2025, 3, 10), reference),
        isFalse,
      ); // Next Monday
    });

    test('all scope always matches', () {
      final reference = DateTime(2025, 3, 3);
      expect(
        ReminderScope.all.includes(DateTime(1990, 1, 1), reference),
        isTrue,
      );
    });
  });
}
