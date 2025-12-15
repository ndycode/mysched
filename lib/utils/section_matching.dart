import 'dart:math';

/// Represents a section match from the database with a similarity score.
class SectionMatch {
  const SectionMatch({
    required this.id,
    required this.code,
    required this.similarity,
    this.isExactMatch = false,
  });

  final int id;
  final String code;
  /// Similarity score from 0.0 (no match) to 1.0 (exact match)
  final double similarity;
  final bool isExactMatch;

  Map<String, dynamic> toMap() => {
    'id': id,
    'code': code,
    'similarity': similarity,
    'isExactMatch': isExactMatch,
  };

  @override
  String toString() =>
      'SectionMatch(id: $id, code: $code, similarity: ${similarity.toStringAsFixed(2)})';
}

/// Calculates the Levenshtein distance between two strings.
/// This is the minimum number of single-character edits needed to change
/// one string into the other.
int levenshteinDistance(String s1, String s2) {
  if (s1 == s2) return 0;
  if (s1.isEmpty) return s2.length;
  if (s2.isEmpty) return s1.length;

  final m = s1.length;
  final n = s2.length;

  // Use two rows for space optimization
  var prevRow = List<int>.generate(n + 1, (i) => i);
  var currRow = List<int>.filled(n + 1, 0);

  for (var i = 1; i <= m; i++) {
    currRow[0] = i;
    for (var j = 1; j <= n; j++) {
      final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
      currRow[j] = [
        prevRow[j] + 1,     // deletion
        currRow[j - 1] + 1, // insertion
        prevRow[j - 1] + cost, // substitution
      ].reduce(min);
    }
    // Swap rows
    final temp = prevRow;
    prevRow = currRow;
    currRow = temp;
  }

  return prevRow[n];
}

/// Calculates a similarity score between two strings using Levenshtein distance.
/// Returns a value from 0.0 (completely different) to 1.0 (identical).
double calculateSimilarity(String s1, String s2) {
  if (s1 == s2) return 1.0;
  if (s1.isEmpty || s2.isEmpty) return 0.0;

  final distance = levenshteinDistance(s1.toUpperCase(), s2.toUpperCase());
  final maxLen = max(s1.length, s2.length);
  
  return 1.0 - (distance / maxLen);
}

/// Normalizes a section code for comparison.
/// Removes extra whitespace and converts to uppercase.
String normalizeCode(String code) {
  return code.toUpperCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Compares two section codes with fuzzy matching.
/// Returns a similarity score from 0.0 to 1.0.
double compareSectionCodes(String input, String dbCode) {
  final normalizedInput = normalizeCode(input);
  final normalizedDb = normalizeCode(dbCode);
  
  // Exact match
  if (normalizedInput == normalizedDb) return 1.0;
  
  // Compact comparison (ignore spaces)
  final compactInput = normalizedInput.replaceAll(' ', '');
  final compactDb = normalizedDb.replaceAll(' ', '');
  if (compactInput == compactDb) return 0.98;
  
  // Levenshtein similarity on compact versions
  final similarity = calculateSimilarity(compactInput, compactDb);
  
  // Boost score if the letters match exactly (only numbers differ)
  final lettersInput = compactInput.replaceAll(RegExp(r'[0-9-]'), '');
  final lettersDb = compactDb.replaceAll(RegExp(r'[0-9-]'), '');
  if (lettersInput == lettersDb) {
    return min(1.0, similarity + 0.1); // Boost for matching course code
  }
  
  return similarity;
}

/// Ranks section matches by similarity score.
/// Returns matches sorted by similarity (highest first).
List<SectionMatch> rankSectionMatches(
  String searchCode,
  List<Map<String, dynamic>> dbRows,
) {
  final matches = <SectionMatch>[];
  
  for (final row in dbRows) {
    final id = (row['id'] as num?)?.toInt();
    final code = (row['code'] ?? '').toString();
    if (id == null || code.isEmpty) continue;
    
    final similarity = compareSectionCodes(searchCode, code);
    
    // Only include matches with reasonable similarity
    if (similarity >= 0.5) {
      matches.add(SectionMatch(
        id: id,
        code: code,
        similarity: similarity,
        isExactMatch: similarity >= 0.98,
      ));
    }
  }
  
  // Sort by similarity (highest first)
  matches.sort((a, b) => b.similarity.compareTo(a.similarity));
  
  return matches;
}
