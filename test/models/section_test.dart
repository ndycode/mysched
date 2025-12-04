import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/models/section.dart';

void main() {
  group('Section', () {
    group('fromMap', () {
      test('parses complete map correctly', () {
        final map = {
          'id': 1,
          'code': 'BSCS-2A',
        };

        final section = Section.fromMap(map);

        expect(section.id, 1);
        expect(section.code, 'BSCS-2A');
      });

      test('handles numeric id as double', () {
        final map = {
          'id': 1.0,
          'code': 'BSIT-3B',
        };

        final section = Section.fromMap(map);
        expect(section.id, 1);
      });

      test('handles null code gracefully', () {
        final map = {
          'id': 1,
          'code': null,
        };

        final section = Section.fromMap(map);
        expect(section.code, '');
      });

      test('handles missing code gracefully', () {
        final map = {
          'id': 1,
        };

        final section = Section.fromMap(map);
        expect(section.code, '');
      });
    });

    group('toMap', () {
      test('converts to map correctly', () {
        const section = Section(id: 42, code: 'BSEE-4A');

        final map = section.toMap();

        expect(map['id'], 42);
        expect(map['code'], 'BSEE-4A');
      });

      test('round-trips through fromMap and toMap', () {
        const original = Section(id: 10, code: 'BSCS-1A');

        final map = original.toMap();
        final restored = Section.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.code, original.code);
      });
    });
  });
}
