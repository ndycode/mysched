import 'package:flutter_test/flutter_test.dart';

import 'package:mysched/utils/formatters.dart';

void main() {
  group('StudentIdInputFormatter', () {
    final fmt = StudentIdInputFormatter();

    TextEditingValue apply(String input) => fmt.formatEditUpdate(
          const TextEditingValue(text: ''),
          TextEditingValue(text: input),
        );

    test('formats digits into YYYY-XXXX-IC pattern', () {
      final out1 = apply('20210001IC');
      expect(out1.text, '2021-0001-IC');
    });

    test('allows lowercase i/c and extra dashes', () {
      final out = apply('2021-0001-ic');
      expect(out.text, '2021-0001-IC');
    });

    test('ignores extra characters', () {
      final out = apply('20ab21xx0001**IC??');
      expect(out.text, '2021-0001-IC');
    });

    test('partial input does not over-format', () {
      expect(apply('2').text, '2');
      expect(apply('2021').text, '2021');
      expect(apply('20210').text, '2021-0');
      expect(apply('20210001').text, '2021-0001');
      expect(apply('20210001I').text, '2021-0001-I');
      expect(apply('20210001IC').text, '2021-0001-IC');
    });
  });

  group('extractSection', () {
    test('extracts common patterns', () {
      expect(extractSection('hello BSCS 3-1 world'), 'BSCS 3-1');
      expect(extractSection('ACT 1-2 line'), 'ACT 1-2');
      expect(extractSection('BSIT3-2'), 'BSIT 3-2');
      expect(extractSection('section: BSCS 3 - 1'), 'BSCS 3-1');
    });

    test('ignores student numbers', () {
      expect(extractSection('ID: 2021-0001-IC'), isNull);
    });

    test('handles OCR quirks', () {
      expect(extractSection('bscs 3\u20131'), 'BSCS 3-1'); // en dash
      expect(extractSection('b5cs 3-1'), 'BSCS 3-1'); // 5 -> S in letters
      expect(extractSection('bsc0 3-1'), 'BSCO 3-1'); // 0 -> O in letters
      expect(extractSection('bsit 3-1o'), 'BSIT 3-10'); // O -> 0 in digits
      expect(extractSection('bscs I-2'), 'BSCS 1-2'); // I -> 1 in digits
      expect(extractSection('bsme 4-2a'), 'BSME 4-2A'); // suffix letter
    });
  });
}
