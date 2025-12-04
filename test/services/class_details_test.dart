import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/schedule_api.dart';

void main() {
  group('ClassDetails', () {
    ClassDetails createSampleDetails({
      int id = 1,
      bool isCustom = false,
      String title = 'Test Class',
      int day = 1,
      String start = '08:00',
      String end = '09:00',
      bool enabled = true,
    }) {
      return ClassDetails(
        id: id,
        isCustom: isCustom,
        title: title,
        day: day,
        start: start,
        end: end,
        enabled: enabled,
      );
    }

    group('copyWith', () {
      test('copies with new values', () {
        final original = createSampleDetails(
          title: 'Original Title',
          day: 1,
          enabled: true,
        );

        final updated = original.copyWith(
          title: 'Updated Title',
          day: 3,
          enabled: false,
        );

        expect(updated.title, 'Updated Title');
        expect(updated.day, 3);
        expect(updated.enabled, isFalse);
        expect(updated.id, original.id);
        expect(updated.isCustom, original.isCustom);
        expect(updated.start, original.start);
        expect(updated.end, original.end);
      });

      test('original remains unchanged', () {
        final original = createSampleDetails(title: 'Original');
        original.copyWith(title: 'Changed');
        expect(original.title, 'Original');
      });

      test('copies optional fields', () {
        final original = ClassDetails(
          id: 1,
          isCustom: false,
          title: 'Test',
          day: 2,
          start: '09:00',
          end: '10:00',
          enabled: true,
          code: 'CS101',
          room: 'Room A',
          instructorName: 'Dr. Smith',
          instructorEmail: 'smith@univ.edu',
        );

        final updated = original.copyWith(
          room: 'Room B',
          instructorEmail: 'new@univ.edu',
        );

        expect(updated.room, 'Room B');
        expect(updated.instructorEmail, 'new@univ.edu');
        expect(updated.code, 'CS101');
        expect(updated.instructorName, 'Dr. Smith');
      });
    });

    group('toSnapshot', () {
      test('includes all non-null fields', () {
        final details = ClassDetails(
          id: 42,
          isCustom: true,
          title: 'Custom Class',
          day: 5,
          start: '14:00',
          end: '15:30',
          enabled: false,
          code: 'CUST01',
          room: 'Lab 101',
          units: 3,
          sectionId: 100,
          sectionCode: 'SEC-A',
          sectionName: 'Section A',
          sectionNumber: '001',
          sectionStatus: 'active',
          instructorName: 'Prof. Brown',
          instructorEmail: 'brown@edu.com',
          instructorTitle: 'Professor',
          instructorDepartment: 'Computer Science',
          instructorAvatar: 'https://example.com/avatar.png',
          createdAt: DateTime(2024, 1, 15, 10, 30),
          updatedAt: DateTime(2024, 1, 16, 11, 45),
        );

        final snapshot = details.toSnapshot();

        expect(snapshot['id'], 42);
        expect(snapshot['is_custom'], isTrue);
        expect(snapshot['title'], 'Custom Class');
        expect(snapshot['day'], 5);
        expect(snapshot['start'], '14:00');
        expect(snapshot['end'], '15:30');
        expect(snapshot['enabled'], isFalse);
        expect(snapshot['code'], 'CUST01');
        expect(snapshot['room'], 'Lab 101');
        expect(snapshot['units'], 3);
        expect(snapshot['section_id'], 100);
        expect(snapshot['section_code'], 'SEC-A');
        expect(snapshot['section_name'], 'Section A');
        expect(snapshot['section_number'], '001');
        expect(snapshot['section_status'], 'active');
        expect(snapshot['instructor_name'], 'Prof. Brown');
        expect(snapshot['instructor_email'], 'brown@edu.com');
        expect(snapshot['instructor_title'], 'Professor');
        expect(snapshot['instructor_department'], 'Computer Science');
        expect(snapshot['instructor_avatar'], 'https://example.com/avatar.png');
        expect(snapshot['created_at'], isNotNull);
        expect(snapshot['updated_at'], isNotNull);
      });

      test('excludes null fields', () {
        final details = createSampleDetails();
        final snapshot = details.toSnapshot();

        expect(snapshot.containsKey('code'), isFalse);
        expect(snapshot.containsKey('room'), isFalse);
        expect(snapshot.containsKey('units'), isFalse);
        expect(snapshot.containsKey('section_id'), isFalse);
        expect(snapshot.containsKey('instructor_name'), isFalse);
      });
    });

    group('fromCustomRow', () {
      test('parses custom class row', () {
        final row = {
          'id': 10,
          'title': 'My Custom Class',
          'day': 'Wed',
          'start_time': '10:00',
          'end_time': '11:30',
          'instructor': 'Custom Teacher',
          'room': 'Custom Room',
          'enabled': true,
          'created_at': '2024-01-15T10:30:00Z',
        };

        final details = ClassDetails.fromCustomRow(row);

        expect(details.id, 10);
        expect(details.isCustom, isTrue);
        expect(details.title, 'My Custom Class');
        expect(details.day, 3); // Wednesday
        expect(details.start, '10:00');
        expect(details.end, '11:30');
        expect(details.instructorName, 'Custom Teacher');
        expect(details.room, 'Custom Room');
        expect(details.enabled, isTrue);
        expect(details.createdAt, isNotNull);
      });

      test('uses start/end fallbacks when start_time/end_time missing', () {
        final row = {
          'id': 11,
          'title': 'Fallback Test',
          'day': 2,
          'start': '13:00',
          'end': '14:00',
        };

        final details = ClassDetails.fromCustomRow(row);

        expect(details.start, '13:00');
        expect(details.end, '14:00');
      });

      test('defaults title when missing', () {
        final row = {
          'id': 12,
          'day': 1,
        };

        final details = ClassDetails.fromCustomRow(row);

        expect(details.title, 'Custom class');
      });

      test('defaults day to 1 when invalid', () {
        final row = {
          'id': 13,
          'title': 'No Day',
          'day': 'invalid',
        };

        final details = ClassDetails.fromCustomRow(row);

        expect(details.day, 1);
      });

      test('sets section fields to null for custom classes', () {
        final row = {
          'id': 14,
          'title': 'Custom',
          'day': 1,
        };

        final details = ClassDetails.fromCustomRow(row);

        expect(details.sectionId, isNull);
        expect(details.sectionCode, isNull);
        expect(details.sectionName, isNull);
        expect(details.sectionNumber, isNull);
        expect(details.sectionStatus, isNull);
        expect(details.code, isNull);
        expect(details.units, isNull);
      });
    });

    group('fromClassRow', () {
      ClassItem createFallback({
        int id = 1,
        int day = 1,
        String start = '08:00',
        String end = '09:00',
      }) {
        return ClassItem(
          id: id,
          day: day,
          start: start,
          end: end,
        );
      }

      test('parses class row with fallback', () {
        final row = {
          'id': 100,
          'title': 'Database Systems',
          'code': 'CS301',
          'day': 4,
          'start': '15:00',
          'end': '16:30',
          'room': 'Science 201',
          'units': 3,
          'section_id': 50,
        };

        final fallback = createFallback(id: 100);
        final details = ClassDetails.fromClassRow(row, fallback: fallback);

        expect(details.id, 100);
        expect(details.isCustom, isFalse);
        expect(details.title, 'Database Systems');
        expect(details.code, 'CS301');
        expect(details.day, 4);
        expect(details.start, '15:00');
        expect(details.end, '16:30');
        expect(details.room, 'Science 201');
        expect(details.units, 3);
        expect(details.sectionId, 50);
      });

      test('uses fallback values when row fields missing', () {
        final row = <String, dynamic>{};
        final fallback = ClassItem(
          id: 99,
          day: 5,
          start: '11:00',
          end: '12:00',
          title: 'Fallback Title',
          room: 'Fallback Room',
          instructor: 'Fallback Instructor',
        );

        final details = ClassDetails.fromClassRow(row, fallback: fallback);

        expect(details.id, 99);
        expect(details.day, 5);
        expect(details.start, '11:00');
        expect(details.end, '12:00');
        expect(details.title, 'Fallback Title');
        expect(details.room, 'Fallback Room');
        expect(details.instructorName, 'Fallback Instructor');
      });

      test('parses nested instructor object', () {
        final row = {
          'id': 101,
          'title': 'With Instructor',
          'day': 2,
          'start': '09:00',
          'end': '10:00',
          'instructors': {
            'full_name': 'Dr. Johnson',
            'email': 'johnson@edu.com',
            'title': 'Associate Professor',
            'department': 'Mathematics',
            'avatar_url': 'https://example.com/j.png',
          },
        };

        final fallback = createFallback(id: 101);
        final details = ClassDetails.fromClassRow(row, fallback: fallback);

        expect(details.instructorName, 'Dr. Johnson');
        expect(details.instructorEmail, 'johnson@edu.com');
        expect(details.instructorTitle, 'Associate Professor');
        expect(details.instructorDepartment, 'Mathematics');
        expect(details.instructorAvatar, 'https://example.com/j.png');
      });

      test('parses nested sections object', () {
        final row = {
          'id': 102,
          'title': 'With Section',
          'day': 3,
          'start': '13:00',
          'end': '14:00',
          'sections': {
            'id': 200,
            'code': 'SEC-B',
            'class_name': 'Advanced Topics',
            'section_number': '002',
            'status': 'open',
            'room': 'Section Room',
          },
        };

        final fallback = createFallback(id: 102);
        final details = ClassDetails.fromClassRow(row, fallback: fallback);

        expect(details.sectionId, 200);
        expect(details.sectionCode, 'SEC-B');
        expect(details.sectionName, 'Advanced Topics');
        expect(details.sectionNumber, '002');
        expect(details.sectionStatus, 'open');
        expect(details.room, 'Section Room');
      });

      test('prefers row room over section room', () {
        final row = {
          'id': 103,
          'title': 'Room Priority',
          'day': 1,
          'start': '08:00',
          'end': '09:00',
          'room': 'Primary Room',
          'sections': {
            'room': 'Section Room',
          },
        };

        final fallback = createFallback(id: 103);
        final details = ClassDetails.fromClassRow(row, fallback: fallback);

        expect(details.room, 'Primary Room');
      });
    });

    group('fromViewRow', () {
      test('parses view row with fallback', () {
        final row = {
          'title': 'View Title',
          'code': 'VIEW101',
          'day': 2,
          'start': '10:00',
          'end': '11:00',
          'room': 'View Room',
          'units': 4,
          'section_id': 300,
          'section_code': 'SEC-V',
          'section_name': 'View Section',
          'section_number': '003',
          'section_status': 'closed',
          'instructor': 'View Instructor',
          'instructor_email': 'view@edu.com',
          'instructor_title': 'Lecturer',
          'instructor_department': 'Physics',
          'instructor_avatar': 'https://example.com/v.png',
        };

        final fallback = ClassItem(
          id: 200,
          day: 1,
          start: '08:00',
          end: '09:00',
          enabled: true,
        );

        final details = ClassDetails.fromViewRow(row, fallback: fallback);

        expect(details.id, 200); // Uses fallback id
        expect(details.isCustom, isFalse);
        expect(details.title, 'View Title');
        expect(details.code, 'VIEW101');
        expect(details.day, 2);
        expect(details.start, '10:00');
        expect(details.end, '11:00');
        expect(details.room, 'View Room');
        expect(details.units, 4);
        expect(details.enabled, isTrue); // From fallback
        expect(details.sectionId, 300);
        expect(details.sectionCode, 'SEC-V');
        expect(details.sectionName, 'View Section');
        expect(details.sectionNumber, '003');
        expect(details.sectionStatus, 'closed');
        expect(details.instructorName, 'View Instructor');
        expect(details.instructorEmail, 'view@edu.com');
        expect(details.instructorTitle, 'Lecturer');
        expect(details.instructorDepartment, 'Physics');
        expect(details.instructorAvatar, 'https://example.com/v.png');
      });

      test('uses fallback values when row missing', () {
        final row = <String, dynamic>{};
        final fallback = ClassItem(
          id: 201,
          day: 3,
          start: '14:00',
          end: '15:00',
          title: 'Fallback View Title',
          room: 'Fallback View Room',
          instructor: 'Fallback View Instructor',
          instructorAvatar: 'https://fallback.com/avatar.png',
          enabled: false,
        );

        final details = ClassDetails.fromViewRow(row, fallback: fallback);

        expect(details.id, 201);
        expect(details.day, 3);
        expect(details.start, '14:00');
        expect(details.end, '15:00');
        expect(details.title, 'Fallback View Title');
        expect(details.room, 'Fallback View Room');
        expect(details.instructorName, 'Fallback View Instructor');
        expect(details.instructorAvatar, 'https://fallback.com/avatar.png');
        expect(details.enabled, isFalse);
      });
    });
  });
}
