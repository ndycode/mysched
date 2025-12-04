import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/utils/instructor_utils.dart';

void main() {
  group('resolveInstructorName', () {
    test('returns direct instructor field when present', () {
      final map = {'instructor': 'Dr. John Smith'};
      expect(resolveInstructorName(map), 'Dr. John Smith');
    });

    test('trims whitespace from direct instructor', () {
      final map = {'instructor': '  Dr. Jane Doe  '};
      expect(resolveInstructorName(map), 'Dr. Jane Doe');
    });

    test('reads from nested instructors map with full_name', () {
      final map = {
        'instructors': {'full_name': 'Professor Anderson'},
      };
      expect(resolveInstructorName(map), 'Professor Anderson');
    });

    test('reads from nested instructors map with name', () {
      final map = {
        'instructors': {'name': 'Dr. Williams'},
      };
      expect(resolveInstructorName(map), 'Dr. Williams');
    });

    test('prefers full_name over name in nested map', () {
      final map = {
        'instructors': {
          'full_name': 'Dr. Full Name',
          'name': 'Dr. Short Name',
        },
      };
      expect(resolveInstructorName(map), 'Dr. Full Name');
    });

    test('reads from instructors list', () {
      final map = {
        'instructors': [
          {'full_name': 'Dr. First Instructor'},
          {'full_name': 'Dr. Second Instructor'},
        ],
      };
      expect(resolveInstructorName(map), 'Dr. First Instructor');
    });

    test('falls back to instructor_name', () {
      final map = {'instructor_name': 'Prof. Backup'};
      expect(resolveInstructorName(map), 'Prof. Backup');
    });

    test('falls back to teacher', () {
      final map = {'teacher': 'Mr. Teacher'};
      expect(resolveInstructorName(map), 'Mr. Teacher');
    });

    test('falls back to professor', () {
      final map = {'professor': 'Prof. Expert'};
      expect(resolveInstructorName(map), 'Prof. Expert');
    });

    test('returns empty string when no instructor found', () {
      final map = <String, dynamic>{};
      expect(resolveInstructorName(map), '');
    });

    test('returns empty string when instructor is empty', () {
      final map = {'instructor': ''};
      expect(resolveInstructorName(map), '');
    });

    test('returns empty string when instructor is whitespace only', () {
      final map = {'instructor': '   '};
      expect(resolveInstructorName(map), '');
    });

    test('prefers direct instructor over nested values', () {
      final map = {
        'instructor': 'Direct Instructor',
        'instructors': {'full_name': 'Nested Instructor'},
        'teacher': 'Teacher Fallback',
      };
      expect(resolveInstructorName(map), 'Direct Instructor');
    });
  });

  group('instructorInitials', () {
    test('generates single initial for single name', () {
      expect(instructorInitials('John'), 'J');
    });

    test('generates two initials for two names', () {
      expect(instructorInitials('John Smith'), 'JS');
    });

    test('generates two initials for multiple names', () {
      expect(instructorInitials('John William Smith Jr'), 'JW');
    });

    test('handles extra whitespace', () {
      expect(instructorInitials('  John   Smith  '), 'JS');
    });

    test('returns ? for empty string', () {
      expect(instructorInitials(''), '?');
    });

    test('returns ? for whitespace only', () {
      expect(instructorInitials('   '), '?');
    });

    test('converts to uppercase', () {
      expect(instructorInitials('john smith'), 'JS');
    });

    test('handles single character name', () {
      expect(instructorInitials('J'), 'J');
    });

    test('handles names with special characters', () {
      expect(instructorInitials("O'Brien"), 'O');
    });

    test('handles unicode names', () {
      expect(instructorInitials('José García'), 'JG');
    });
  });
}
