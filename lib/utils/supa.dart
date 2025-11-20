// lib/utils/supa.dart
// Small helpers to make Supabase dynamic responses easier to work with.

import 'package:supabase_flutter/supabase_flutter.dart';

List<Map<String, dynamic>> asMapList(dynamic rows) {
  return (rows as List).cast<Map<String, dynamic>>();
}

Map<String, dynamic>? firstOrNullMap(dynamic rows) {
  final list = (rows as List).cast<Map<String, dynamic>>();
  if (list.isEmpty) return null;
  return list.first;
}

extension PostgrestFilterBuilderCompat on PostgrestFilterBuilder {
  /// Backwards compatible wrapper for Supabase `in` filters. Supports both
  /// `inFilter` (SDK >= 2.0) and the legacy `in_` helper.
  PostgrestFilterBuilder filterIn(String column, List<dynamic> values) {
    final dynamic builder = this;
    if (values.isEmpty) {
      return builder.limit(0) as PostgrestFilterBuilder;
    }
    try {
      final dynamic result = builder.inFilter(column, values);
      return result as PostgrestFilterBuilder;
    } on NoSuchMethodError {
      final dynamic result = builder.in_(column, values);
      return result as PostgrestFilterBuilder;
    }
  }
}
