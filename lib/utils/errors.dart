// lib/utils/errors.dart

import 'app_exceptions.dart';

/// Converts raw error messages or exceptions to user-friendly strings.
String friendlyError(dynamic error) {
  // Handle typed exceptions first
  if (error is NotAuthenticatedException) {
    return 'Please sign in to continue.';
  }
  if (error is NetworkException) {
    return 'Network error. Check your connection.';
  }
  if (error is ValidationException) {
    return error.message;
  }
  if (error is NotFoundException) {
    return error.message;
  }
  if (error is RateLimitException) {
    return 'Too many requests. Please wait a moment.';
  }
  if (error is ConflictException) {
    return error.message;
  }

  // Fall back to string parsing for untyped errors
  final raw = error.toString();
  final stripped = raw.trim().replaceFirst(
        RegExp(r'^(?:\w+\.)*\w*Exception:\s*'),
        '',
      );
  final r = stripped.toLowerCase();

  // Authentication errors
  if (r.contains('not authenticated') ||
      r.contains('sign in') ||
      r.contains('auth')) {
    return 'Please sign in to continue.';
  }

  // Network errors
  if (r.contains('timeout') ||
      r.contains('network') ||
      r.contains('socket') ||
      r.contains('connection refused') ||
      r.contains('no internet')) {
    return 'Network error. Check your connection.';
  }

  // Rate limiting
  if (r.contains('rate limit') ||
      r.contains('too many requests') ||
      r.contains('throttle')) {
    return 'Too many requests. Please wait a moment.';
  }

  // Scan-specific errors
  if (r.contains('could not read your section code')) {
    return 'We couldn\'t read your section code. Please retake the photo.';
  }
  if (r.contains('no section found') || r.contains('no matching section')) {
    return stripped;
  }

  // Permission errors
  if (r.contains('permission denied') || r.contains('forbidden')) {
    return 'Permission denied while fetching schedules. Check Supabase RLS policies for sections/classes.';
  }

  // Validation errors
  if (r.contains('title is required')) {
    return 'Please enter a title.';
  }
  if (r.contains('title too long')) {
    return 'Title is too long. Please shorten it.';
  }

  // Database errors (for developers)
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

  // Conflict errors
  if (r.contains('already exists') ||
      r.contains('duplicate') ||
      r.contains('in use') ||
      r.contains('conflict')) {
    return 'This item already exists.';
  }

  return 'Something went wrong. Please try again.';
}

/// Determines if an error is retryable.
bool isRetryableError(dynamic error) {
  if (error is NetworkException) return true;
  if (error is NotAuthenticatedException) return false;
  if (error is ValidationException) return false;
  if (error is ConflictException) return false;

  final msg = error.toString().toLowerCase();
  return msg.contains('timeout') ||
      msg.contains('network') ||
      msg.contains('socket') ||
      msg.contains('connection');
}

/// Categorizes an error for telemetry.
String errorCategory(dynamic error) {
  if (error is NotAuthenticatedException) return 'auth';
  if (error is NetworkException) return 'network';
  if (error is ValidationException) return 'validation';
  if (error is NotFoundException) return 'not_found';
  if (error is RateLimitException) return 'rate_limit';
  if (error is ConflictException) return 'conflict';

  final msg = error.toString().toLowerCase();
  if (msg.contains('auth') || msg.contains('sign in')) return 'auth';
  if (msg.contains('network') || msg.contains('timeout')) return 'network';
  if (msg.contains('validation') || msg.contains('required')) return 'validation';
  return 'unknown';
}
