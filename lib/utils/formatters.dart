import 'package:flutter/services.dart';

/// Forces input to match Immaculate Conception student ID format.
/// Example: 2021-0001-IC
class StudentIdInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Uppercase and keep only digits, I, C, and dashes
    final s = newValue.text.toUpperCase().replaceAll(RegExp(r'[^0-9IC-]'), '');

    final buf = StringBuffer();
    int digits = 0;
    String suffix = '';

    for (int i = 0; i < s.length; i++) {
      final ch = s[i];

      if (ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57) {
        // digit 0-9
        if (digits == 4 || digits == 8) buf.write('-');
        if (digits < 8) {
          buf.write(ch);
          digits++;
        }
      } else if (digits >= 8) {
        // After 8 digits, accept only 'I' then 'C' as suffix
        if (suffix.isEmpty && ch == 'I') {
          suffix = 'I';
        } else if (suffix == 'I' && ch == 'C') {
          suffix = 'IC';
        }
      }
      // ignore everything else
    }

    if (digits >= 8 && suffix.isNotEmpty) {
      buf.write('-');
      buf.write(suffix);
    }

    final out = buf.toString();
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}

/// Extracts a section code from OCR text.
/// Matches like "BSCS 3-1", "ACT 2-1", "BSIT 3-2".
String? extractSection(String text) {
  if (text.isEmpty) return null;

  final normalized = text
      .toUpperCase()
      .replaceAll(RegExp(r'[\u2010\u2011\u2012\u2013\u2014\u2212]'),
          '-') // dash variations
      .replaceAll(RegExp(r'[^\w\s/-]'), ' ') // strip punctuation noise
      .replaceAll(RegExp(r'\s+'), ' '); // collapse whitespace runs

  final re = RegExp(
      r'([A-Z0-9]{2,}\s*[0-9OILSBGZ]+\s*-\s*[0-9OILSBGZ]+[A-Z]?)'); // allow OCR slips
  final matches = re.allMatches(normalized);

  for (final match in matches) {
    final candidate = match.group(1)!;
    if (candidate.contains('STUDENT') ||
        RegExp(r'\d{4}\s*-\s*\d+').hasMatch(candidate)) {
      continue;
    }
    final cleaned = _normalizeSectionCandidate(candidate);
    if (cleaned != null) return cleaned;
  }

  return null;
}

String? _normalizeSectionCandidate(String raw) {
  final trimmed = raw.replaceAll(RegExp(r'\s+'), ' ').trim();

  final match = RegExp(
    r'^([A-Z0-9]+(?:\s+[A-Z0-9]+)*)\s*([0-9OILSBGZ]+)\s*-\s*([0-9OILSBGZ]+)\s*([A-Z0-9]?)$',
  ).firstMatch(trimmed);
  if (match == null) return null;

  String normalizeLetters(String input) {
    final collapsed = input.replaceAll(RegExp(r'\s+'), '');
    if (collapsed.isEmpty) return collapsed;
    final buffer = StringBuffer();
    for (final ch in collapsed.split('')) {
      switch (ch) {
        case '0':
          buffer.write('O');
          break;
        case '1':
          buffer.write('I');
          break;
        case '2':
          buffer.write('Z');
          break;
        case '5':
          buffer.write('S');
          break;
        case '6':
          buffer.write('G');
          break;
        case '8':
          buffer.write('B');
          break;
        default:
          buffer.write(ch);
      }
    }
    return buffer.toString();
  }

  String? normalizeDigits(String input) {
    final buffer = StringBuffer();
    for (final ch in input.split('')) {
      if (RegExp(r'\d').hasMatch(ch)) {
        buffer.write(ch);
        continue;
      }
      switch (ch) {
        case 'O':
        case 'Q':
          buffer.write('0');
          continue;
        case 'I':
        case 'L':
        case '|':
          buffer.write('1');
          continue;
        case 'S':
          buffer.write('5');
          continue;
        case 'B':
          buffer.write('8');
          continue;
        case 'G':
          buffer.write('6');
          continue;
        case 'Z':
          buffer.write('2');
          continue;
        default:
          return null;
      }
    }
    return buffer.isEmpty ? null : buffer.toString();
  }

  String normalizeSuffix(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return cleaned.isEmpty ? '' : cleaned[0];
  }

  final letters = normalizeLetters(match.group(1)!);
  final first = normalizeDigits(match.group(2)!);
  final second = normalizeDigits(match.group(3)!);
  if (letters.isEmpty || first == null || second == null) return null;

  final suffix = normalizeSuffix(match.group(4) ?? '');

  return '$letters $first-$second$suffix';
}
