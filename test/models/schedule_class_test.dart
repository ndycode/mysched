import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/models/schedule_class.dart';

void main() {
  group('ScheduleClass', () {
    group('fromMap', () {
      test('parses complete map correctly', () {
        final map = {
          'id': 1,
          'section_id': 10,
          'day': 2,
          'start': '08:00',
          'end': '09:30',
          'code': 'CS101',
          'title': 'Intro to Programming',
          'room': 'Room 301',
          'instructor': 'Dr. Smith',
          'instructor_avatar': 'https://example.com/avatar.jpg',
          'units': 3,
          'enabled': true,
        };

        final scheduleClass = ScheduleClass.fromMap(map);

        expect(scheduleClass.id, 1);
        expect(scheduleClass.sectionId, 10);
        expect(scheduleClass.day, 2);
        expect(scheduleClass.start, '08:00');
        expect(scheduleClass.end, '09:30');
        expect(scheduleClass.code, 'CS101');
        expect(scheduleClass.title, 'Intro to Programming');
        expect(scheduleClass.room, 'Room 301');
        expect(scheduleClass.instructor, 'Dr. Smith');
        expect(scheduleClass.instructorAvatar, 'https://example.com/avatar.jpg');
        expect(scheduleClass.units, 3);
        expect(scheduleClass.enabled, true);
      });

      test('handles alternative field names', () {
        final map = {
          'id': 1,
          'section_id': 10,
          'day': 1,
          'start_time': '10:00',
          'end_time': '11:30',
          'code': 'MATH201',
          'subject': 'Calculus II',
          'room': 'Math Building',
          'instructor': 'Prof. Johnson',
        };

        final scheduleClass = ScheduleClass.fromMap(map);

        expect(scheduleClass.start, '10:00');
        expect(scheduleClass.end, '11:30');
        expect(scheduleClass.title, 'Calculus II');
      });

      test('parses day string to integer', () {
        final testCases = [
          {'day': 'Mon', 'expected': 1},
          {'day': 'Tue', 'expected': 2},
          {'day': 'Wed', 'expected': 3},
          {'day': 'Thu', 'expected': 4},
          {'day': 'Fri', 'expected': 5},
          {'day': 'Sat', 'expected': 6},
          {'day': 'Sun', 'expected': 7},
          {'day': 'Monday', 'expected': 1},
          {'day': 'tuesday', 'expected': 2},
          {'day': 'WEDNESDAY', 'expected': 3},
        ];

        for (final testCase in testCases) {
          final map = {
            'id': 1,
            'section_id': 1,
            'day': testCase['day'],
            'start': '08:00',
            'end': '09:00',
            'code': 'TEST',
            'title': 'Test',
            'room': 'Test',
            'instructor': 'Test',
          };

          final scheduleClass = ScheduleClass.fromMap(map);
          expect(scheduleClass.day, testCase['expected'],
              reason: 'Failed for day: ${testCase['day']}');
        }
      });

      test('handles enabled as integer', () {
        final enabledMap = {
          'id': 1,
          'section_id': 1,
          'day': 1,
          'start': '08:00',
          'end': '09:00',
          'code': 'TEST',
          'title': 'Test',
          'room': 'Test',
          'instructor': 'Test',
          'enabled': 1,
        };

        final disabledMap = {
          'id': 2,
          'section_id': 1,
          'day': 1,
          'start': '08:00',
          'end': '09:00',
          'code': 'TEST',
          'title': 'Test',
          'room': 'Test',
          'instructor': 'Test',
          'enabled': 0,
        };

        expect(ScheduleClass.fromMap(enabledMap).enabled, true);
        expect(ScheduleClass.fromMap(disabledMap).enabled, false);
      });

      test('reads avatar from nested instructors object', () {
        final map = {
          'id': 1,
          'section_id': 1,
          'day': 1,
          'start': '08:00',
          'end': '09:00',
          'code': 'TEST',
          'title': 'Test',
          'room': 'Test',
          'instructor': 'Test',
          'instructors': {
            'avatar_url': 'https://example.com/nested-avatar.jpg',
          },
        };

        final scheduleClass = ScheduleClass.fromMap(map);
        expect(scheduleClass.instructorAvatar, 'https://example.com/nested-avatar.jpg');
      });

      test('handles missing optional fields', () {
        final map = {
          'id': 1,
          'section_id': 1,
          'day': 1,
          'start': '08:00',
          'end': '09:00',
          'code': 'TEST',
          'title': 'Test',
          'room': 'Test',
          'instructor': 'Test',
        };

        final scheduleClass = ScheduleClass.fromMap(map);

        expect(scheduleClass.instructorAvatar, isNull);
        expect(scheduleClass.units, isNull);
        expect(scheduleClass.enabled, true); // defaults to true
      });

      test('handles invalid day string gracefully', () {
        final map = {
          'id': 1,
          'section_id': 1,
          'day': 'InvalidDay',
          'start': '08:00',
          'end': '09:00',
          'code': 'TEST',
          'title': 'Test',
          'room': 'Test',
          'instructor': 'Test',
        };

        final scheduleClass = ScheduleClass.fromMap(map);
        expect(scheduleClass.day, 0);
      });
    });

    group('toMap', () {
      test('converts to map correctly', () {
        const scheduleClass = ScheduleClass(
          id: 1,
          sectionId: 10,
          day: 2,
          start: '08:00',
          end: '09:30',
          code: 'CS101',
          title: 'Intro to Programming',
          room: 'Room 301',
          instructor: 'Dr. Smith',
          instructorAvatar: 'https://example.com/avatar.jpg',
          units: 3,
          enabled: true,
        );

        final map = scheduleClass.toMap();

        expect(map['id'], 1);
        expect(map['section_id'], 10);
        expect(map['day'], 2);
        expect(map['start'], '08:00');
        expect(map['end'], '09:30');
        expect(map['code'], 'CS101');
        expect(map['title'], 'Intro to Programming');
        expect(map['room'], 'Room 301');
        expect(map['instructor'], 'Dr. Smith');
        expect(map['instructor_avatar'], 'https://example.com/avatar.jpg');
        expect(map['units'], 3);
        expect(map['enabled'], true);
      });

      test('round-trips through fromMap and toMap', () {
        const original = ScheduleClass(
          id: 42,
          sectionId: 5,
          day: 3,
          start: '14:00',
          end: '15:30',
          code: 'PHYS301',
          title: 'Quantum Mechanics',
          room: 'Science Hall',
          instructor: 'Dr. Feynman',
          units: 4,
          enabled: false,
        );

        final map = original.toMap();
        final restored = ScheduleClass.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.sectionId, original.sectionId);
        expect(restored.day, original.day);
        expect(restored.start, original.start);
        expect(restored.end, original.end);
        expect(restored.code, original.code);
        expect(restored.title, original.title);
        expect(restored.room, original.room);
        expect(restored.instructor, original.instructor);
        expect(restored.units, original.units);
        expect(restored.enabled, original.enabled);
      });
    });
  });
}
