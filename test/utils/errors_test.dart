import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/utils/errors.dart';

void main() {
  test('friendlyError maps auth messages', () {
    expect(friendlyError('sign in please'), 'Please sign in to continue.');
    expect(friendlyError('AUTH ERROR'), 'Please sign in to continue.');
  });

  test('friendlyError maps timeout/network', () {
    expect(friendlyError('timeout occured'),
        'Network error. Check your connection.');
    expect(friendlyError('NETWORK unreachable'),
        'Network error. Check your connection.');
  });

  test('friendlyError passes through "no matching section"', () {
    expect(
      friendlyError('SupabaseException: No matching section found.'),
      'No matching section found.',
    );
  });

  test('friendlyError surfaces "no section found" without prefix', () {
    expect(
      friendlyError('Exception: No section found for "BSCS 3-1".'),
      'No section found for "BSCS 3-1".',
    );
  });

  test('friendlyError handles unreadable section code message', () {
    expect(
      friendlyError('Exception: Could not read your section code.'),
      'We couldn\'t read your section code. Please retake the photo.',
    );
  });

  test('friendlyError maps permission denied', () {
    expect(
      friendlyError('PostgrestException: permission denied for table classes'),
      'Permission denied while fetching schedules. Check Supabase RLS policies for sections/classes.',
    );
  });

  test('friendlyError mentions missing column', () {
    expect(
      friendlyError(
          'PostgrestException: column "classes.instructor" does not exist'),
      'Supabase column "classes.instructor" is missing. Update the app query or restore the column.',
    );
  });

  test('friendlyError mentions missing relation', () {
    expect(
      friendlyError(
          'PostgrestException: relation "public.classes" does not exist'),
      'Supabase table or view "public.classes" is missing. Ensure migrations are in sync.',
    );
  });

  test('friendlyError default', () {
    expect(friendlyError('random error'),
        'Something went wrong. Please try again.');
  });
}
