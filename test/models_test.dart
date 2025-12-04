import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/models/section.dart';
import 'package:mysched/models/schedule_class.dart';

void main() {
  group('Section', () {
    test('fromMap maps id and code', () {
      final s = Section.fromMap({'id': 10, 'code': 'BSCS 3-1'});
      expect(s.id, 10);
      expect(s.code, 'BSCS 3-1');
    });

    test('fromMap tolerates string id and missing code', () {
      final s = Section.fromMap({'id': 7, 'code': ''});
      expect(s.id, 7);
      expect(s.code, '');
    });
  });

  group('ScheduleClass', () {
    test('fromMap with standard keys', () {
      final c = ScheduleClass.fromMap({
        'id': 1,
        'section_id': 2,
        'day': 3,
        'start': '08:00',
        'end': '09:00',
        'code': 'MATH101',
        'title': 'Algebra',
        'room': 'A1',
        'instructor': 'Prof X',
        'units': 3,
        'enabled': true,
      });
      expect(c.id, 1);
      expect(c.sectionId, 2);
      expect(c.day, 3);
      expect(c.start, '08:00');
      expect(c.end, '09:00');
      expect(c.code, 'MATH101');
      expect(c.title, 'Algebra');
      expect(c.room, 'A1');
      expect(c.instructor, 'Prof X');
      expect(c.units, 3);
      expect(c.enabled, true);
    });

    test('fromMap falls back title to subject and start_time/end_time', () {
      final c = ScheduleClass.fromMap({
        'id': 5,
        'section_id': 9,
        'day': 2,
        'start_time': '13:00',
        'end_time': '14:00',
        'subject': 'Physics',
        'room': '',
        'instructor': '',
      });
      expect(c.title, 'Physics');
      expect(c.start, '13:00');
      expect(c.end, '14:00');
    });

    test('fromMap enabled mapping from 0/1 number', () {
      final c1 = ScheduleClass.fromMap({
        'id': 1,
        'section_id': 2,
        'day': 1,
        'start': '08:00',
        'end': '09:00',
        'enabled': 1,
      });
      final c0 = ScheduleClass.fromMap({
        'id': 1,
        'section_id': 2,
        'day': 1,
        'start': '08:00',
        'end': '09:00',
        'enabled': 0,
      });
      expect(c1.enabled, true);
      expect(c0.enabled, false);
    });
  });
}
