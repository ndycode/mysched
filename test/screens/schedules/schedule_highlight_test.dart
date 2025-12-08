import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/screens/schedules/schedules_data.dart';
import 'package:mysched/services/schedule_repository.dart';

ClassItem classItem({
  required int id,
  required int day,
  required String start,
  required String end,
  bool enabled = true,
  bool isCustom = false,
}) {
  return ClassItem(
    id: id,
    day: day,
    start: start,
    end: end,
    title: 'Class $id',
    code: 'C$id',
    units: 3,
    room: 'Room',
    instructor: 'Prof',
    enabled: enabled,
    isCustom: isCustom,
  );
}

void main() {
  group('ScheduleHighlight.resolve', () {
    test('marks ongoing when now is within range', () {
      final item = classItem(
        id: 1,
        day: DateTime.monday,
        start: '09:00',
        end: '10:00',
      );
      final now = DateTime(2025, 3, 3, 9, 30); // Monday

      final highlight = ScheduleHighlight.resolve(item, now);

      expect(highlight.status, ScheduleHighlightStatus.ongoing);
      expect(highlight.start.isBefore(now), isTrue);
      expect(highlight.end.isAfter(now), isTrue);
    });

    test('rolls to next week when class already ended today', () {
      final item = classItem(
        id: 2,
        day: DateTime.tuesday,
        start: '08:00',
        end: '09:00',
      );
      final now = DateTime(2025, 3, 4, 12, 0); // Tuesday noon

      final highlight = ScheduleHighlight.resolve(item, now);

      expect(highlight.status, ScheduleHighlightStatus.upcoming);
      expect(highlight.start.isAfter(now), isTrue);
      expect(
        highlight.start.difference(now).inDays,
        greaterThanOrEqualTo(6),
        reason: 'next occurrence should land next week',
      );
    });

    test('supports overnight classes crossing midnight (DST/overnight)', () {
      final item = classItem(
        id: 3,
        day: DateTime.friday,
        start: '23:30',
        end: '00:45',
      );
      final now = DateTime(2025, 3, 7, 23, 45); // Friday

      final highlight = ScheduleHighlight.resolve(item, now);

      expect(highlight.status, ScheduleHighlightStatus.ongoing);
      expect(highlight.start.day, now.day);
      expect(
        highlight.end.isAfter(highlight.start),
        isTrue,
        reason: 'end should roll into the next day for overnight spans',
      );
      expect(highlight.end.day, isNot(now.day));
    });

    test('handles DST transition without throwing', () {
      // US DST starts March 9, 2025: clocks jump at 2:00 AM
      final item = classItem(
        id: 4,
        day: DateTime.sunday,
        start: '01:30',
        end: '03:00',
      );
      final now = DateTime(2025, 3, 9, 1, 45); // pre-jump local time

      final highlight = ScheduleHighlight.resolve(item, now);

      expect(highlight.status, isNotNull);
      expect(highlight.start.weekday, DateTime.sunday);
      expect(highlight.end.isAfter(highlight.start), isTrue);
    });
  });

  group('groupClassesByDay', () {
    test('sorts classes by start time within each day', () {
      final grouped = groupClassesByDay([
        classItem(id: 1, day: DateTime.wednesday, start: '10:30', end: '11:00'),
        classItem(id: 2, day: DateTime.wednesday, start: '08:00', end: '09:00'),
        classItem(id: 3, day: DateTime.tuesday, start: '12:00', end: '13:00'),
      ]);

      expect(grouped, hasLength(2));
      expect(grouped.first.day, DateTime.tuesday);
      expect(grouped.first.items.first.id, 3);
      expect(grouped.last.items.first.id, 2);
      expect(grouped.last.items.last.id, 1);
    });
  });
}
