/// Represents a section code candidate extracted from OCR text
/// with a confidence score indicating the likelihood of correctness.
class SectionCandidate {
  const SectionCandidate({
    required this.code,
    required this.confidence,
    this.normalizationCount = 0,
    this.rawMatch = '',
    this.isMultiWord = false,
  });

  /// The normalized section code (e.g., "BSCS 3-1", "BS CS 4-2A")
  final String code;

  /// Confidence score from 0.0 (low) to 1.0 (high)
  /// 
  /// Scoring factors:
  /// - 1.0: Perfect match, no normalization needed
  /// - 0.8-0.9: Minor OCR corrections applied
  /// - 0.5-0.7: Moderate corrections, but pattern is valid
  /// - <0.5: Heavy corrections or weak pattern match
  final double confidence;

  /// Number of characters that were normalized (OCR correction applied)
  final int normalizationCount;

  /// The original matched text from OCR before normalization
  final String rawMatch;

  /// Whether this is a multi-word course code (e.g., "BS CS")
  final bool isMultiWord;

  @override
  String toString() =>
      'SectionCandidate(code: $code, confidence: ${confidence.toStringAsFixed(2)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectionCandidate &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  /// Creates a copy with the given fields replaced
  SectionCandidate copyWith({
    String? code,
    double? confidence,
    int? normalizationCount,
    String? rawMatch,
    bool? isMultiWord,
  }) {
    return SectionCandidate(
      code: code ?? this.code,
      confidence: confidence ?? this.confidence,
      normalizationCount: normalizationCount ?? this.normalizationCount,
      rawMatch: rawMatch ?? this.rawMatch,
      isMultiWord: isMultiWord ?? this.isMultiWord,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'confidence': confidence,
      'normalizationCount': normalizationCount,
      'rawMatch': rawMatch,
      'isMultiWord': isMultiWord,
    };
  }

  factory SectionCandidate.fromMap(Map<String, dynamic> map) {
    return SectionCandidate(
      code: map['code'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      normalizationCount: map['normalizationCount'] as int? ?? 0,
      rawMatch: map['rawMatch'] as String? ?? '',
      isMultiWord: map['isMultiWord'] as bool? ?? false,
    );
  }
}
