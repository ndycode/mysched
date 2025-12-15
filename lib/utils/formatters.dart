import 'package:flutter/services.dart';

import '../models/section_candidate.dart';

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
/// Matches like "BSCS 3-1", "ACT 2-1", "BSIT 3-2", "BS CS 3-1".
/// 
/// Enhanced for OCR accuracy:
/// - Supports multi-word course codes (BS CS, BS IT, BS ME)
/// - Handles common OCR character misreadings
/// - Preserves suffix letters (A, B, C, etc.)
/// - Better filtering of student IDs and other patterns
String? extractSection(String text) {
  if (text.isEmpty) return null;

  final normalized = _normalizeOcrText(text);

  // Try multi-word course codes first (e.g., "BS CS 3-1")
  // The suffix must be followed by non-letter or end to avoid capturing first letter of next word
  // Use [0-9OIL] for section numbers - excludes B/S/G/Z which are more likely suffix letters
  final multiWordRe = RegExp(
    r'((?:BS|BA|AB)\s+[A-Z]{2,4})\s*([0-9OIL]+)\s*-\s*([0-9OIL]+)([A-Z]?)(?=[^A-Z]|$)',
    caseSensitive: false,
  );
  for (final match in multiWordRe.allMatches(normalized)) {
    final candidate = _normalizeMultiWordCandidate(
      match.group(1)!,
      match.group(2)!,
      match.group(3)!,
      match.group(4) ?? '',
    );
    if (candidate != null && !_looksLikeStudentId(candidate)) {
      return candidate;
    }
  }

  // Standard single-word patterns (e.g., "BSCS 3-1", "ACT3-1")
  // The suffix must be followed by non-letter or end to avoid capturing first letter of next word
  // Use [0-9OIL] for section numbers - excludes B/S/G/Z which are more likely suffix letters
  final singleWordRe = RegExp(
    r'([A-Z@$€&0-9]{2,})\s*([0-9OIL]+)\s*-\s*([0-9OIL]+)([A-Z]?)(?=[^A-Z]|$)',
  );
  for (final match in singleWordRe.allMatches(normalized)) {
    final candidate = match.group(0)!;
    if (_looksLikeStudentId(candidate)) continue;
    
    final cleaned = _normalizeSectionCandidate(candidate);
    if (cleaned != null) return cleaned;
  }

  return null;
}

/// Extracts all possible section code candidates from OCR text with confidence scores.
/// 
/// Unlike [extractSection], this returns ALL valid candidates sorted by confidence,
/// allowing the caller to show alternatives or choose based on context.
/// 
/// Returns an empty list if no valid candidates are found.
List<SectionCandidate> extractSectionCandidates(String text) {
  if (text.isEmpty) return [];

  final normalized = _normalizeOcrText(text);
  final candidates = <SectionCandidate>[];
  final seenCodes = <String>{};

  // Try multi-word course codes first (e.g., "BS CS 3-1") - higher confidence
  final multiWordRe = RegExp(
    r'((?:BS|BA|AB)\s+[A-Z]{2,4})\s*([0-9OIL]+)\s*-\s*([0-9OIL]+)([A-Z]?)(?=[^A-Z]|$)',
    caseSensitive: false,
  );
  for (final match in multiWordRe.allMatches(normalized)) {
    final rawMatch = match.group(0)!;
    final result = _normalizeMultiWordCandidateWithStats(
      match.group(1)!,
      match.group(2)!,
      match.group(3)!,
      match.group(4) ?? '',
    );
    if (result != null && !_looksLikeStudentId(result.code)) {
      if (!seenCodes.contains(result.code)) {
        seenCodes.add(result.code);
        candidates.add(result.copyWith(
          rawMatch: rawMatch,
          isMultiWord: true,
        ));
      }
    }
  }

  // Standard single-word patterns (e.g., "BSCS 3-1", "ACT3-1")
  final singleWordRe = RegExp(
    r'([A-Z@$€&0-9]{2,})\s*([0-9OIL]+)\s*-\s*([0-9OIL]+)([A-Z]?)(?=[^A-Z]|$)',
  );
  for (final match in singleWordRe.allMatches(normalized)) {
    final rawMatch = match.group(0)!;
    if (_looksLikeStudentId(rawMatch)) continue;
    
    final result = _normalizeSectionCandidateWithStats(rawMatch);
    if (result != null && !seenCodes.contains(result.code)) {
      seenCodes.add(result.code);
      candidates.add(result.copyWith(rawMatch: rawMatch));
    }
  }

  // Sort by confidence (highest first)
  candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
  
  return candidates;
}

/// Normalizes a multi-word course code and returns a SectionCandidate with stats.
SectionCandidate? _normalizeMultiWordCandidateWithStats(
  String courseCode,
  String yearPart,
  String sectionPart,
  String suffix,
) {
  final cleanCode = courseCode.replaceAll(RegExp(r'\s+'), ' ').trim().toUpperCase();
  
  int normCount = 0;
  final yearResult = _normalizeDigitsWithCount(yearPart);
  final sectionResult = _normalizeDigitsWithCount(sectionPart);
  
  if (yearResult == null || sectionResult == null) return null;
  
  final year = yearResult.value;
  final section = sectionResult.value;
  normCount += yearResult.count + sectionResult.count;
  
  // Validate ranges
  final yearNum = int.tryParse(year);
  final sectionNum = int.tryParse(section);
  if (yearNum == null || sectionNum == null) return null;
  if (yearNum < 1 || yearNum > 9) return null;
  if (sectionNum < 1 || sectionNum > 20) return null;
  
  final cleanSuffix = _normalizeSuffixLetter(suffix);
  final code = '$cleanCode $year-$section$cleanSuffix';
  
  // Calculate confidence: start at 1.0, reduce for each normalization
  // Multi-word codes get a slight boost as they're more specific
  double confidence = 1.0 - (normCount * 0.08);
  confidence = confidence.clamp(0.3, 1.0);
  
  return SectionCandidate(
    code: code,
    confidence: confidence,
    normalizationCount: normCount,
    isMultiWord: true,
  );
}

/// Normalizes a section candidate and returns a SectionCandidate with stats.
SectionCandidate? _normalizeSectionCandidateWithStats(String raw) {
  final trimmed = raw.replaceAll(RegExp(r'\s+'), ' ').trim();

  final match = RegExp(
    r'^([A-Z0-9]+(?:\s+[A-Z0-9]+)*)\s*([0-9OIL]+)\s*-\s*([0-9OIL]+)([A-Z]?)$',
  ).firstMatch(trimmed);
  if (match == null) return null;

  int normCount = 0;
  final letterResult = _normalizeLettersWithCount(match.group(1)!);
  normCount += letterResult.count;
  
  final yearResult = _normalizeDigitsWithCount(match.group(2)!);
  final sectionResult = _normalizeDigitsWithCount(match.group(3)!);
  
  if (yearResult == null || sectionResult == null) return null;
  normCount += yearResult.count + sectionResult.count;
  
  // Validate ranges
  final yearNum = int.tryParse(yearResult.value);
  final sectionNum = int.tryParse(sectionResult.value);
  if (yearNum == null || sectionNum == null) return null;
  if (yearNum < 1 || yearNum > 9) return null;
  if (sectionNum < 1 || sectionNum > 20) return null;

  final suffix = _normalizeSuffixLetter(match.group(4) ?? '');
  final code = '${letterResult.value} ${yearResult.value}-${sectionResult.value}$suffix';
  
  // Calculate confidence
  double confidence = 1.0 - (normCount * 0.1);
  confidence = confidence.clamp(0.2, 1.0);
  
  return SectionCandidate(
    code: code,
    confidence: confidence,
    normalizationCount: normCount,
  );
}

/// Result of normalization with count of changes made.
class _NormResult {
  const _NormResult(this.value, this.count);
  final String value;
  final int count;
}

/// Normalizes letters and counts changes made.
_NormResult _normalizeLettersWithCount(String input) {
  final collapsed = input.replaceAll(RegExp(r'\s+'), '');
  if (collapsed.isEmpty) return const _NormResult('', 0);
  
  final buffer = StringBuffer();
  int count = 0;
  
  for (final ch in collapsed.split('')) {
    switch (ch) {
      case '0':
        buffer.write('O');
        count++;
        break;
      case '1':
        buffer.write('I');
        count++;
        break;
      case '2':
        buffer.write('Z');
        count++;
        break;
      case '5':
        buffer.write('S');
        count++;
        break;
      case '6':
        buffer.write('G');
        count++;
        break;
      case '8':
        buffer.write('B');
        count++;
        break;
      case '@':
        buffer.write('A');
        count++;
        break;
      case '\$':
        buffer.write('S');
        count++;
        break;
      case '€':
        buffer.write('E');
        count++;
        break;
      case '&':
        buffer.write('B');
        count++;
        break;
      default:
        buffer.write(ch);
    }
  }
  return _NormResult(buffer.toString(), count);
}

/// Normalizes digits and counts changes made.
_NormResult? _normalizeDigitsWithCount(String input) {
  final buffer = StringBuffer();
  int count = 0;
  
  for (final ch in input.split('')) {
    if (RegExp(r'\d').hasMatch(ch)) {
      buffer.write(ch);
      continue;
    }
    switch (ch) {
      case 'O':
      case 'Q':
      case 'D':
        buffer.write('0');
        count++;
        continue;
      case 'I':
      case 'L':
      case '|':
      case 'l':
        buffer.write('1');
        count++;
        continue;
      case 'S':
        buffer.write('5');
        count++;
        continue;
      case 'B':
        buffer.write('8');
        count++;
        continue;
      case 'G':
        buffer.write('6');
        count++;
        continue;
      case 'Z':
        buffer.write('2');
        count++;
        continue;
      case 'T':
        buffer.write('7');
        count++;
        continue;
      case 'A':
        buffer.write('4');
        count++;
        continue;
      default:
        return null;
    }
  }
  return buffer.isEmpty ? null : _NormResult(buffer.toString(), count);
}

String _normalizeOcrText(String text) {
  return text
      .toUpperCase()
      // Normalize dash variations (en-dash, em-dash, minus, etc.)
      .replaceAll(RegExp(r'[\u2010\u2011\u2012\u2013\u2014\u2212\u2015]'), '-')
      // Replace common OCR misreadings before stripping
      .replaceAll('@', 'A')
      .replaceAll('\$', 'S')
      .replaceAll('€', 'E')
      .replaceAll('&', 'B')
      .replaceAll('Ø', 'O')
      .replaceAll('ß', 'B')
      // Strip remaining punctuation noise but keep letters, digits, spaces, dashes
      .replaceAll(RegExp(r'[^\w\s/-]'), ' ')
      // Collapse multiple spaces/newlines
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Checks if a pattern looks like a student ID (e.g., 2021-0001-IC).
bool _looksLikeStudentId(String text) {
  // Student IDs: 4 digits, dash, 4+ digits, optional -IC suffix
  if (RegExp(r'\d{4}\s*-\s*\d{3,}').hasMatch(text)) return true;
  if (text.contains('STUDENT')) return true;
  if (text.contains('ID NO')) return true;
  return false;
}

/// Normalizes a multi-word course code candidate.
String? _normalizeMultiWordCandidate(
  String courseCode,
  String yearPart,
  String sectionPart,
  String suffix,
) {
  // Clean up course code (keep spaces between parts)
  final cleanCode = courseCode
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toUpperCase();
  
  final year = _normalizeDigits(yearPart);
  final section = _normalizeDigits(sectionPart);
  
  if (year == null || section == null) return null;
  
  // Validate reasonable year/section values
  final yearNum = int.tryParse(year);
  final sectionNum = int.tryParse(section);
  if (yearNum == null || sectionNum == null) return null;
  if (yearNum < 1 || yearNum > 9) return null;
  if (sectionNum < 1 || sectionNum > 20) return null;
  
  // Preserve suffix letter as-is (don't apply digit normalization)
  final cleanSuffix = _normalizeSuffixLetter(suffix);
  
  return '$cleanCode $year-$section$cleanSuffix';
}

String? _normalizeSectionCandidate(String raw) {
  final trimmed = raw.replaceAll(RegExp(r'\s+'), ' ').trim();

  // Use [0-9OIL] for section numbers - excludes B/S/G/Z which are more likely suffix letters
  final match = RegExp(
    r'^([A-Z0-9]+(?:\s+[A-Z0-9]+)*)\s*([0-9OIL]+)\s*-\s*([0-9OIL]+)([A-Z]?)$',
  ).firstMatch(trimmed);
  if (match == null) return null;

  final letters = _normalizeLetters(match.group(1)!);
  final first = _normalizeDigits(match.group(2)!);
  final second = _normalizeDigits(match.group(3)!);
  if (letters.isEmpty || first == null || second == null) return null;

  // Validate reasonable year/section values
  final yearNum = int.tryParse(first);
  final sectionNum = int.tryParse(second);
  if (yearNum == null || sectionNum == null) return null;
  if (yearNum < 1 || yearNum > 9) return null;
  if (sectionNum < 1 || sectionNum > 20) return null;

  // Use proper suffix normalization (preserve letters)
  final suffix = _normalizeSuffixLetter(match.group(4) ?? '');

  return '$letters $first-$second$suffix';
}

/// Normalizes characters that should be letters in a course code.
/// Converts common OCR digit misreadings to letters.
String _normalizeLetters(String input) {
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
      case '@':
        buffer.write('A');
        break;
      case '\$':
        buffer.write('S');
        break;
      case '€':
        buffer.write('E');
        break;
      case '&':
        buffer.write('B');
        break;
      default:
        buffer.write(ch);
    }
  }
  return buffer.toString();
}

/// Normalizes characters that should be digits in year/section numbers.
/// Converts common OCR letter misreadings to digits.
String? _normalizeDigits(String input) {
  final buffer = StringBuffer();
  for (final ch in input.split('')) {
    if (RegExp(r'\d').hasMatch(ch)) {
      buffer.write(ch);
      continue;
    }
    switch (ch) {
      case 'O':
      case 'Q':
      case 'D':
        buffer.write('0');
        continue;
      case 'I':
      case 'L':
      case '|':
      case 'l':
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
      case 'T':
        buffer.write('7');
        continue;
      case 'A':
        buffer.write('4');
        continue;
      default:
        // Unknown character - reject this candidate
        return null;
    }
  }
  return buffer.isEmpty ? null : buffer.toString();
}

/// Normalizes a suffix letter (A, B, C, etc.) - preserves letters, converts digits.
/// Unlike _normalizeDigits, this PRESERVES letters instead of converting them.
String _normalizeSuffixLetter(String input) {
  final cleaned = input.replaceAll(RegExp(r'[^A-Z0-9]'), '').trim();
  if (cleaned.isEmpty) return '';
  
  final ch = cleaned[0];
  // If it's already a letter, keep it as-is
  if (RegExp(r'[A-Z]').hasMatch(ch)) {
    return ch;
  }
  // If it's a digit that could be a misread letter, convert
  switch (ch) {
    case '0':
      return 'O';
    case '1':
      return 'I';
    case '8':
      return 'B';
    default:
      // Other digits are probably actual suffix numbers (rare but possible)
      return ch;
  }
}

