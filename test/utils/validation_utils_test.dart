import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/utils/validation_utils.dart';

void main() {
  group('ValidationUtils.isValidStudentId', () {
    test('accepts valid student ID format', () {
      expect(ValidationUtils.isValidStudentId('2023-1234-IC'), true);
      expect(ValidationUtils.isValidStudentId('2024-0001-IC'), true);
      expect(ValidationUtils.isValidStudentId('1999-9999-IC'), true);
    });

    test('accepts lowercase input and normalizes', () {
      expect(ValidationUtils.isValidStudentId('2023-1234-ic'), true);
      expect(ValidationUtils.isValidStudentId('2023-1234-Ic'), true);
    });

    test('handles whitespace by trimming', () {
      expect(ValidationUtils.isValidStudentId('  2023-1234-IC  '), true);
      expect(ValidationUtils.isValidStudentId('2023-1234-IC '), true);
    });

    test('rejects empty string', () {
      expect(ValidationUtils.isValidStudentId(''), false);
    });

    test('rejects whitespace only', () {
      expect(ValidationUtils.isValidStudentId('   '), false);
    });

    test('rejects invalid formats', () {
      // Wrong number of digits
      expect(ValidationUtils.isValidStudentId('202-1234-IC'), false);
      expect(ValidationUtils.isValidStudentId('2023-123-IC'), false);
      expect(ValidationUtils.isValidStudentId('20233-1234-IC'), false);
      
      // Wrong suffix
      expect(ValidationUtils.isValidStudentId('2023-1234-AB'), false);
      expect(ValidationUtils.isValidStudentId('2023-1234'), false);
      
      // Wrong separators
      expect(ValidationUtils.isValidStudentId('2023/1234/IC'), false);
      expect(ValidationUtils.isValidStudentId('20231234IC'), false);
      
      // Letters where numbers expected
      expect(ValidationUtils.isValidStudentId('ABCD-1234-IC'), false);
      expect(ValidationUtils.isValidStudentId('2023-ABCD-IC'), false);
    });

    test('rejects with extra characters', () {
      expect(ValidationUtils.isValidStudentId('2023-1234-ICX'), false);
      expect(ValidationUtils.isValidStudentId('X2023-1234-IC'), false);
      expect(ValidationUtils.isValidStudentId('2023-1234-IC-extra'), false);
    });
  });
}
