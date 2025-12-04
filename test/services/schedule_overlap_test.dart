import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/schedule_api.dart';
import 'package:mysched/utils/schedule_overlap.dart';

ClassItem buildClass({
  required int id,
  required int day,
  required String start,
  required String end,
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
    enabled: true,
    isCustom: false,
  );
}

void main() {
  group('classesOverlap', () {
    test('detects overlap on same day', () {
      final a = buildClass(id: 1, day: DateTime.monday, start: '08:00', end: '09:00');
      final b = buildClass(id: 2, day: DateTime.monday, start: '08:30', end: '10:00');

      expect(classesOverlap(a, b), isTrue);
      expect(classesOverlap(b, a), isTrue);
    });

    test('treats boundary-touching sessions as non-overlapping', () {
      final a = buildClass(id: 1, day: DateTime.tuesday, start: '10:00', end: '11:00');
      final b = buildClass(id: 2, day: DateTime.tuesday, start: '11:00', end: '12:00');

      expect(classesOverlap(a, b), isFalse);
    });

    test('ignores sessions on different days', () {
      final a = buildClass(id: 1, day: DateTime.wednesday, start: '09:00', end: '10:00');
      final b = buildClass(id: 2, day: DateTime.thursday, start: '09:00', end: '10:00');

      expect(classesOverlap(a, b), isFalse);
    });

    test('handles overnight class overlapping next-day morning', () {
      final overnight = buildClass(
        id: 1,
        day: DateTime.friday,
        start: '23:30',
        end: '01:00',
      ); // spills into Saturday
      final morning = buildClass(
        id: 2,
        day: DateTime.saturday,
        start: '00:45',
        end: '02:00',
      );

      expect(classesOverlap(overnight, morning), isTrue);
      expect(classesOverlap(morning, overnight), isTrue);
    });

    test('handles overlapping overnights on same start day', () {
      final a = buildClass(
        id: 1,
        day: DateTime.sunday,
        start: '22:00',
        end: '00:30',
      );
      final b = buildClass(
        id: 2,
        day: DateTime.sunday,
        start: '23:45',
        end: '01:15',
      ); // both spill into Monday

      expect(classesOverlap(a, b), isTrue);
    });
  });
}
