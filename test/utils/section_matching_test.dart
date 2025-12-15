import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/utils/section_matching.dart';

void main() {
  group('levenshteinDistance', () {
    test('returns 0 for identical strings', () {
      expect(levenshteinDistance('BSCS 3-1', 'BSCS 3-1'), 0);
    });

    test('handles empty strings', () {
      expect(levenshteinDistance('', 'BSCS'), 4);
      expect(levenshteinDistance('BSCS', ''), 4);
      expect(levenshteinDistance('', ''), 0);
    });

    test('calculates correct distance for substitutions', () {
      expect(levenshteinDistance('BSCS', 'BSIT'), 2);
    });

    test('calculates correct distance for insertions', () {
      expect(levenshteinDistance('BSC', 'BSCS'), 1);
    });

    test('calculates correct distance for deletions', () {
      expect(levenshteinDistance('BSCS', 'BSC'), 1);
    });

    test('handles complex differences', () {
      expect(levenshteinDistance('BSCS 3-1', 'BSIT 4-2'), 4);
    });
  });

  group('calculateSimilarity', () {
    test('returns 1.0 for identical strings', () {
      expect(calculateSimilarity('BSCS 3-1', 'BSCS 3-1'), 1.0);
    });

    test('handles empty strings', () {
      // One string empty - cannot calculate meaningful similarity
      expect(calculateSimilarity('', 'BSCS'), 0.0);
      expect(calculateSimilarity('BSCS', ''), 0.0);
      // Both empty - identical, so 1.0 (edge case)
      expect(calculateSimilarity('', ''), 1.0);
    });

    test('returns high similarity for minor differences', () {
      final similarity = calculateSimilarity('BSCS 3-1', 'BSCS 3-2');
      expect(similarity, greaterThan(0.8));
    });

    test('returns low similarity for major differences', () {
      final similarity = calculateSimilarity('BSCS 3-1', 'ACT 4-2');
      expect(similarity, lessThan(0.5));
    });

    test('is case-insensitive', () {
      expect(calculateSimilarity('BSCS', 'bscs'), 1.0);
    });
  });

  group('compareSectionCodes', () {
    test('returns 1.0 for exact match', () {
      expect(compareSectionCodes('BSCS 3-1', 'BSCS 3-1'), 1.0);
    });

    test('returns 0.98 for match ignoring spaces', () {
      expect(compareSectionCodes('BSCS3-1', 'BSCS 3-1'), 0.98);
    });

    test('boosts score when letters match', () {
      final scoreWithMatchingLetters = compareSectionCodes('BSCS 3-1', 'BSCS 3-2');
      final scoreWithDifferentLetters = compareSectionCodes('BSCS 3-1', 'BSIT 3-1');
      expect(scoreWithMatchingLetters, greaterThan(scoreWithDifferentLetters));
    });

    test('handles case insensitivity', () {
      expect(compareSectionCodes('bscs 3-1', 'BSCS 3-1'), 1.0);
    });
  });

  group('rankSectionMatches', () {
    test('sorts by similarity', () {
      final rows = [
        {'id': 1, 'code': 'BSIT 3-1'},
        {'id': 2, 'code': 'BSCS 3-1'},
        {'id': 3, 'code': 'ACT 4-2'},
      ];

      final matches = rankSectionMatches('BSCS 3-1', rows);
      
      expect(matches.first.code, 'BSCS 3-1');
      expect(matches.first.similarity, 1.0);
      expect(matches.first.isExactMatch, true);
    });

    test('filters out low similarity matches', () {
      final rows = [
        {'id': 1, 'code': 'BSCS 3-1'},
        {'id': 2, 'code': 'XYZ 99-99'}, // Very different
      ];

      final matches = rankSectionMatches('BSCS 3-1', rows);
      
      expect(matches.length, 1);
      expect(matches.first.code, 'BSCS 3-1');
    });

    test('handles empty input', () {
      expect(rankSectionMatches('BSCS 3-1', []), isEmpty);
    });
  });

  group('SectionMatch', () {
    test('creates correct instance', () {
      const match = SectionMatch(
        id: 123,
        code: 'BSCS 3-1',
        similarity: 0.95,
        isExactMatch: false,
      );

      expect(match.id, 123);
      expect(match.code, 'BSCS 3-1');
      expect(match.similarity, 0.95);
      expect(match.isExactMatch, false);
    });

    test('converts to map', () {
      const match = SectionMatch(
        id: 123,
        code: 'BSCS 3-1',
        similarity: 1.0,
        isExactMatch: true,
      );

      final map = match.toMap();
      expect(map['id'], 123);
      expect(map['code'], 'BSCS 3-1');
      expect(map['similarity'], 1.0);
      expect(map['isExactMatch'], true);
    });
  });
}
