// lib/utils/errors.dart

String friendlyError(String raw) {
  final stripped = raw.trim().replaceFirst(
        RegExp(r'^(?:\w+\.)*\w*Exception:\s*'),
        '',
      );
  final r = stripped.toLowerCase();
  if (r.contains('sign in') || r.contains('auth')) {
    return 'Please sign in to continue.';
  }
  if (r.contains('timeout') || r.contains('network')) {
    return 'Network error. Check your connection.';
  }
  if (r.contains('could not read your section code')) {
    return 'We couldn\'t read your section code. Please retake the photo.';
  }
  if (r.contains('no section found') || r.contains('no matching section')) {
    return stripped;
  }
  if (r.contains('permission denied')) {
    return 'Permission denied while fetching schedules. Check Supabase RLS policies for sections/classes.';
  }
  final columnMatch =
      RegExp(r'column\s+"?([\w\.]+)"?\s+does not exist').firstMatch(r);
  if (columnMatch != null) {
    final missing = columnMatch.group(1)!;
    return 'Supabase column "$missing" is missing. Update the app query or restore the column.';
  }
  final relationMatch =
      RegExp(r'relation\s+"?([\w\.]+)"?\s+does not exist').firstMatch(r);
  if (relationMatch != null) {
    final missing = relationMatch.group(1)!;
    return 'Supabase table or view "$missing" is missing. Ensure migrations are in sync.';
  }
  return 'Something went wrong. Please try again.';
}
