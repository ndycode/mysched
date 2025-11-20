/// Normalizes instructor info coming from Supabase joins.
String resolveInstructorName(Map<String, dynamic> map) {
  String? asStringValue(dynamic value) {
    if (value is String) return value.trim();
    return null;
  }

  final direct = asStringValue(map['instructor']);
  if (direct != null && direct.isNotEmpty) {
    return direct;
  }

  final nested = map['instructors'];
  if (nested is Map<String, dynamic>) {
    final nestedName = asStringValue(nested['full_name'] ?? nested['name']);
    if (nestedName != null && nestedName.isNotEmpty) {
      return nestedName;
    }
  } else if (nested is List) {
    for (final item in nested) {
      if (item is Map<String, dynamic>) {
        final nestedName = asStringValue(item['full_name'] ?? item['name']);
        if (nestedName != null && nestedName.isNotEmpty) {
          return nestedName;
        }
      }
    }
  }

  final fallback = asStringValue(
    map['instructor_name'] ?? map['teacher'] ?? map['professor'],
  );
  if (fallback != null && fallback.isNotEmpty) {
    return fallback;
  }

  return '';
}

/// Generates up to two-letter initials for displaying instructor avatars.
String instructorInitials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';

  final parts = trimmed
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) {
    final runes = part.runes;
    if (runes.isEmpty) return '';
    final firstRune = runes.first;
    return String.fromCharCode(firstRune).toUpperCase();
  });

  final result = parts.join();
  return result.isEmpty ? '?' : result;
}
