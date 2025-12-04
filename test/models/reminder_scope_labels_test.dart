import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/models/reminder_scope.dart';

void main() {
  group('ReminderScope', () {
    test('has all expected values', () {
      expect(ReminderScope.values.length, 3);
      expect(ReminderScope.values.contains(ReminderScope.today), true);
      expect(ReminderScope.values.contains(ReminderScope.week), true);
      expect(ReminderScope.values.contains(ReminderScope.all), true);
    });
  });

  group('ReminderScopeLabels', () {
    test('today label', () {
      expect(ReminderScope.today.label, 'Today');
    });

    test('week label', () {
      expect(ReminderScope.week.label, 'This week');
    });

    test('all label', () {
      expect(ReminderScope.all.label, 'All');
    });
  });

  group('ReminderScope.includes', () {
    // Use a fixed reference date: Monday, 2024-06-10
    final monday = DateTime(2024, 6, 10);
    final tuesday = DateTime(2024, 6, 11);
    final sunday = DateTime(2024, 6, 16);
    final nextMonday = DateTime(2024, 6, 17);
    final previousSunday = DateTime(2024, 6, 9);

    group('today scope', () {
      test('includes same day', () {
        expect(ReminderScope.today.includes(monday, monday), true);
      });

      test('excludes different day', () {
        expect(ReminderScope.today.includes(tuesday, monday), false);
      });

      test('ignores time component', () {
        final morningRef = DateTime(2024, 6, 10, 8, 0);
        final eveningDue = DateTime(2024, 6, 10, 20, 0);
        expect(ReminderScope.today.includes(eveningDue, morningRef), true);
      });
    });

    group('week scope', () {
      test('includes same day', () {
        expect(ReminderScope.week.includes(monday, monday), true);
      });

      test('includes later in same week', () {
        expect(ReminderScope.week.includes(tuesday, monday), true);
        expect(ReminderScope.week.includes(sunday, monday), true);
      });

      test('excludes previous week', () {
        expect(ReminderScope.week.includes(previousSunday, monday), false);
      });

      test('excludes next week', () {
        expect(ReminderScope.week.includes(nextMonday, monday), false);
      });

      test('works when reference is mid-week', () {
        // Reference is Wednesday, 2024-06-12
        final wednesday = DateTime(2024, 6, 12);
        
        // Week starts on Monday (2024-06-10)
        expect(ReminderScope.week.includes(monday, wednesday), true);
        expect(ReminderScope.week.includes(tuesday, wednesday), true);
        expect(ReminderScope.week.includes(sunday, wednesday), true);
        expect(ReminderScope.week.includes(previousSunday, wednesday), false);
        expect(ReminderScope.week.includes(nextMonday, wednesday), false);
      });

      test('works when reference is Sunday', () {
        // Sunday is last day of week
        expect(ReminderScope.week.includes(monday, sunday), true);
        expect(ReminderScope.week.includes(sunday, sunday), true);
        expect(ReminderScope.week.includes(previousSunday, sunday), false);
        expect(ReminderScope.week.includes(nextMonday, sunday), false);
      });
    });

    group('all scope', () {
      test('includes any date', () {
        expect(ReminderScope.all.includes(monday, monday), true);
        expect(ReminderScope.all.includes(previousSunday, monday), true);
        expect(ReminderScope.all.includes(nextMonday, monday), true);
        
        // Very far past and future dates
        final farPast = DateTime(2000, 1, 1);
        final farFuture = DateTime(2100, 12, 31);
        expect(ReminderScope.all.includes(farPast, monday), true);
        expect(ReminderScope.all.includes(farFuture, monday), true);
      });
    });
  });
}
