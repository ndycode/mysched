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

  group('ValidationUtils.isValidEmail', () {
    test('accepts common emails', () {
      expect(ValidationUtils.isValidEmail('user@example.com'), isTrue);
      expect(ValidationUtils.isValidEmail('first.last+tag@sub.domain.co'), isTrue);
    });

    test('rejects invalid emails', () {
      expect(ValidationUtils.isValidEmail('no-at-symbol'), isFalse);
      expect(ValidationUtils.isValidEmail('user@'), isFalse);
      expect(ValidationUtils.isValidEmail('user@example'), isFalse);
      expect(ValidationUtils.isValidEmail(null), isFalse);
    });
  });

  group('ValidationUtils.looksLikeEmail', () {
    test('is lenient check for presence of @', () {
      expect(ValidationUtils.looksLikeEmail('user@example.com'), isTrue);
      expect(ValidationUtils.looksLikeEmail('user@sub'), isTrue);
    });

    test('rejects null or empty', () {
      expect(ValidationUtils.looksLikeEmail(null), isFalse);
      expect(ValidationUtils.looksLikeEmail(''), isFalse);
    });
  });
}
