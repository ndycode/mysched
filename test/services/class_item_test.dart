import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/schedule_repository.dart';

void main() {
  group('ClassItem', () {
    group('fromMap', () {
      test('parses basic map correctly', () {
        final map = {
          'id': 1,
          'code': 'CS101',
          'title': 'Intro to Programming',
          'units': 3,
          'room': 'Room 101',
          'instructor': 'Dr. Smith',
          'day': 1,
          'start': '08:00',
          'end': '09:00',
          'enabled': true,
        };
        final item = ClassItem.fromMap(map);

        expect(item.id, 1);
        expect(item.code, 'CS101');
        expect(item.title, 'Intro to Programming');
        expect(item.units, 3);
        expect(item.room, 'Room 101');
        expect(item.instructor, 'Dr. Smith');
        expect(item.day, 1);
        expect(item.start, '08:00');
        expect(item.end, '09:00');
        expect(item.enabled, isTrue);
        expect(item.isCustom, isFalse);
      });

      test('parses class_id as id', () {
        final map = {
          'class_id': 42,
          'day': 2,
          'start': '10:00',
          'end': '11:00',
        };
        final item = ClassItem.fromMap(map);
        expect(item.id, 42);
      });

      test('parses string id correctly', () {
        final map = {
          'id': '123',
          'day': 1,
          'start': '08:00',
          'end': '09:00',
        };
        final item = ClassItem.fromMap(map);
        expect(item.id, 123);
      });

      test('parses day string to int', () {
        final testCases = {
          'Monday': 1,
          'Mon': 1,
          'Tuesday': 2,
          'Tue': 2,
          'Wednesday': 3,
          'Wed': 3,
          'Thursday': 4,
          'Thu': 4,
          'Friday': 5,
          'Fri': 5,
          'Saturday': 6,
          'Sat': 6,
          'Sunday': 7,
          'Sun': 7,
        };

        for (final entry in testCases.entries) {
          final map = {
            'id': 1,
            'day': entry.key,
            'start': '08:00',
            'end': '09:00',
          };
          final item = ClassItem.fromMap(map);
          expect(item.day, entry.value, reason: 'Day ${entry.key} should be ${entry.value}');
        }
      });

      test('parses subject field as title fallback', () {
        final map = {
          'id': 1,
          'subject': 'Mathematics',
          'day': 1,
          'start': '08:00',
          'end': '09:00',
        };
        final item = ClassItem.fromMap(map);
        expect(item.title, 'Mathematics');
      });

      test('prefers title over subject', () {
        final map = {
          'id': 1,
          'title': 'Calculus',
          'subject': 'Mathematics',
          'day': 1,
          'start': '08:00',
          'end': '09:00',
        };
        final item = ClassItem.fromMap(map);
        expect(item.title, 'Calculus');
      });

      test('parses start_time and end_time aliases', () {
        final map = {
          'id': 1,
          'day': 1,
          'start_time': '09:30',
          'end_time': '11:00',
        };
        final item = ClassItem.fromMap(map);
        expect(item.start, '09:30');
        expect(item.end, '11:00');
      });

      test('parses enabled as int 1/0', () {
        final enabledMap = {
          'id': 1,
          'day': 1,
          'start': '08:00',
          'end': '09:00',
          'enabled': 1,
        };
        expect(ClassItem.fromMap(enabledMap).enabled, isTrue);

        final disabledMap = {
          'id': 2,
          'day': 1,
          'start': '08:00',
          'end': '09:00',
          'enabled': 0,
        };
        expect(ClassItem.fromMap(disabledMap).enabled, isFalse);
      });

      test('defaults enabled to true when null', () {
        final map = {
          'id': 1,
          'day': 1,
          'start': '08:00',
          'end': '09:00',
          'enabled': null,
        };
        final item = ClassItem.fromMap(map);
        expect(item.enabled, isTrue);
      });

      test('sets isCustom flag from parameter', () {
        final map = {
          'id': 1,
          'day': 1,
          'start': '08:00',
          'end': '09:00',
        };
        final customItem = ClassItem.fromMap(map, isCustom: true);
        expect(customItem.isCustom, isTrue);

        final regularItem = ClassItem.fromMap(map, isCustom: false);
        expect(regularItem.isCustom, isFalse);
      });

      test('parses instructor_avatar', () {
        final map = {
          'id': 1,
          'day': 1,
          'start': '08:00',
          'end': '09:00',
          'instructor_avatar': 'https://example.com/avatar.png',
        };
        final item = ClassItem.fromMap(map);
        expect(item.instructorAvatar, 'https://example.com/avatar.png');
      });

      test('parses avatar_url as fallback', () {
        final map = {
          'id': 1,
          'day': 1,
          'start': '08:00',
          'end': '09:00',
          'avatar_url': 'https://example.com/avatar2.png',
        };
        final item = ClassItem.fromMap(map);
        expect(item.instructorAvatar, 'https://example.com/avatar2.png');
      });

      test('trims whitespace from avatar', () {
        final map = {
          'id': 1,
          'day': 1,
          'start': '08:00',
          'end': '09:00',
          'instructor_avatar': '  https://example.com/avatar.png  ',
        };
        final item = ClassItem.fromMap(map);
        expect(item.instructorAvatar, 'https://example.com/avatar.png');
      });

      test('returns null for empty avatar string', () {
        final map = {
          'id': 1,
          'day': 1,
          'start': '08:00',
          'end': '09:00',
          'instructor_avatar': '   ',
        };
        final item = ClassItem.fromMap(map);
        expect(item.instructorAvatar, isNull);
      });

      test('throws StateError for missing id', () {
        final map = {
          'day': 1,
          'start': '08:00',
          'end': '09:00',
        };
        expect(() => ClassItem.fromMap(map), throwsStateError);
      });
    });

    group('fromJson', () {
      test('parses json with isCustom flag', () {
        final json = {
          'id': 5,
          'day': 3,
          'start': '14:00',
          'end': '15:30',
          'title': 'Custom Class',
          'isCustom': true,
        };
        final item = ClassItem.fromJson(json);
        expect(item.isCustom, isTrue);
        expect(item.title, 'Custom Class');
      });

      test('defaults isCustom to false', () {
        final json = {
          'id': 5,
          'day': 3,
          'start': '14:00',
          'end': '15:30',
        };
        final item = ClassItem.fromJson(json);
        expect(item.isCustom, isFalse);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final item = ClassItem(
          id: 1,
          code: 'CS101',
          title: 'Programming',
          units: 3,
          room: 'Room A',
          instructor: 'Dr. Jones',
          instructorAvatar: 'https://example.com/avatar.png',
          day: 2,
          start: '09:00',
          end: '10:30',
          enabled: true,
          isCustom: true,
        );

        final json = item.toJson();

        expect(json['id'], 1);
        expect(json['code'], 'CS101');
        expect(json['title'], 'Programming');
        expect(json['units'], 3);
        expect(json['room'], 'Room A');
        expect(json['instructor'], 'Dr. Jones');
        expect(json['instructor_avatar'], 'https://example.com/avatar.png');
        expect(json['day'], 2);
        expect(json['start'], '09:00');
        expect(json['end'], '10:30');
        expect(json['enabled'], isTrue);
        expect(json['isCustom'], isTrue);
      });

      test('round-trips correctly', () {
        final original = ClassItem(
          id: 42,
          code: 'MATH200',
          title: 'Calculus II',
          units: 4,
          room: 'Science Hall 101',
          instructor: 'Prof. Adams',
          day: 5,
          start: '13:00',
          end: '14:30',
          enabled: false,
          isCustom: true,
        );

        final json = original.toJson();
        final restored = ClassItem.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.code, original.code);
        expect(restored.title, original.title);
        expect(restored.units, original.units);
        expect(restored.room, original.room);
        expect(restored.instructor, original.instructor);
        expect(restored.day, original.day);
        expect(restored.start, original.start);
        expect(restored.end, original.end);
        expect(restored.enabled, original.enabled);
        expect(restored.isCustom, original.isCustom);
      });
    });

    group('copyWith', () {
      test('copies with new values', () {
        final original = ClassItem(
          id: 1,
          day: 1,
          start: '08:00',
          end: '09:00',
          title: 'Original',
          enabled: true,
          isCustom: false,
        );

        final copied = original.copyWith(
          title: 'Updated',
          day: 3,
          enabled: false,
        );

        expect(copied.id, 1);
        expect(copied.title, 'Updated');
        expect(copied.day, 3);
        expect(copied.enabled, isFalse);
        expect(copied.start, '08:00');
        expect(copied.end, '09:00');
      });

      test('original remains unchanged', () {
        final original = ClassItem(
          id: 1,
          day: 1,
          start: '08:00',
          end: '09:00',
          title: 'Original',
        );

        original.copyWith(title: 'Changed');

        expect(original.title, 'Original');
      });
    });
  });

  group('ScheduleApi.dayIntToDbString', () {
    test('converts all valid days', () {
      expect(ScheduleApi.dayIntToDbString(1), 'Mon');
      expect(ScheduleApi.dayIntToDbString(2), 'Tue');
      expect(ScheduleApi.dayIntToDbString(3), 'Wed');
      expect(ScheduleApi.dayIntToDbString(4), 'Thu');
      expect(ScheduleApi.dayIntToDbString(5), 'Fri');
      expect(ScheduleApi.dayIntToDbString(6), 'Sat');
      expect(ScheduleApi.dayIntToDbString(7), 'Sun');
    });

    test('defaults to Mon for invalid day', () {
      expect(ScheduleApi.dayIntToDbString(0), 'Mon');
      expect(ScheduleApi.dayIntToDbString(-1), 'Mon');
      expect(ScheduleApi.dayIntToDbString(8), 'Mon');
      expect(ScheduleApi.dayIntToDbString(100), 'Mon');
    });
  });
}
