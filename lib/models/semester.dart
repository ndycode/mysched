/// Model representing an academic semester/term.
class Semester {
  const Semester({
    required this.id,
    required this.code,
    required this.name,
    this.academicYear,
    this.term,
    this.startDate,
    this.endDate,
    this.isActive = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier (BIGINT in database).
  final int id;

  /// Unique code, e.g., "2025-2026-1" or "SY2526-1".
  final String code;

  /// Display name, e.g., "1st Semester 2025-2026".
  final String name;

  /// Academic year, e.g., "2025-2026".
  final String? academicYear;

  /// Term number: 1 = 1st sem, 2 = 2nd sem, 3 = summer.
  final int? term;

  /// Start date of the semester.
  final DateTime? startDate;

  /// End date of the semester.
  final DateTime? endDate;

  /// Whether this semester is currently active.
  final bool isActive;

  /// When this semester was created.
  final DateTime? createdAt;

  /// When this semester was last updated.
  final DateTime? updatedAt;

  /// Creates a Semester from a Supabase row.
  factory Semester.fromMap(Map<String, dynamic> map) {
    return Semester(
      id: (map['id'] as num).toInt(),
      code: map['code'] as String,
      name: map['name'] as String,
      academicYear: map['academic_year'] as String?,
      term: map['term'] != null ? (map['term'] as num).toInt() : null,
      startDate: _parseDate(map['start_date']),
      endDate: _parseDate(map['end_date']),
      isActive: map['is_active'] as bool? ?? false,
      createdAt: _parseTimestamp(map['created_at']),
      updatedAt: _parseTimestamp(map['updated_at']),
    );
  }

  /// Converts to a map for serialization.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'academic_year': academicYear,
      'term': term,
      'start_date': startDate?.toIso8601String().split('T').first,
      'end_date': endDate?.toIso8601String().split('T').first,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  @override
  String toString() => 'Semester($code: $name, active: $isActive)';
}
