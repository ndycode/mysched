import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/semester.dart';
import '../utils/app_log.dart';
import 'telemetry_service.dart';

const _scope = 'SemesterService';

/// Service for managing academic semesters.
/// Caches the active semester to avoid repeated queries.
class SemesterService {
  SemesterService._();

  static final SemesterService instance = SemesterService._();

  static const Duration _cacheTtl = Duration(minutes: 5);

  Semester? _cachedActiveSemester;
  DateTime? _cachedAt;

  SupabaseClient get _s => Supabase.instance.client;

  /// Clears the cached active semester.
  void clearCache() {
    _cachedActiveSemester = null;
    _cachedAt = null;
    AppLog.debug(_scope, 'Semester cache cleared');
  }

  /// Returns the currently active semester, or null if none is active.
  /// Uses cached value if available and not expired.
  Future<Semester?> getActiveSemester({bool forceRefresh = false}) async {
    final now = DateTime.now();

    // Return cached if valid
    if (!forceRefresh &&
        _cachedActiveSemester != null &&
        _cachedAt != null &&
        now.difference(_cachedAt!) < _cacheTtl) {
      return _cachedActiveSemester;
    }

    try {
      final res = await _s
          .from('semesters')
          .select()
          .eq('is_active', true)
          .maybeSingle();

      if (res == null) {
        AppLog.warn(_scope, 'No active semester found');
        _cachedActiveSemester = null;
        _cachedAt = now;
        return null;
      }

      _cachedActiveSemester = Semester.fromMap(
        Map<String, dynamic>.from(res as Map),
      );
      _cachedAt = now;

      AppLog.info(
        _scope,
        'Active semester: ${_cachedActiveSemester!.name}',
      );

      return _cachedActiveSemester;
    } catch (e, stack) {
      TelemetryService.instance.logError(
        'semester_fetch_active',
        error: e,
        stack: stack,
      );
      AppLog.error(_scope, 'Error fetching active semester', error: e);
      return null;
    }
  }

  /// Returns just the active semester ID, or null if none is active.
  /// More efficient for filtering queries.
  Future<int?> getActiveSemesterId({bool forceRefresh = false}) async {
    final semester = await getActiveSemester(forceRefresh: forceRefresh);
    return semester?.id;
  }

  /// Returns the active semester name for display (e.g., "1st Semester 2025-2026").
  Future<String?> getActiveSemesterName({bool forceRefresh = false}) async {
    final semester = await getActiveSemester(forceRefresh: forceRefresh);
    return semester?.name;
  }

  /// Checks if there is an active semester.
  Future<bool> hasActiveSemester({bool forceRefresh = false}) async {
    final semester = await getActiveSemester(forceRefresh: forceRefresh);
    return semester != null;
  }

  /// Fetches all available semesters (for admin/settings screens).
  Future<List<Semester>> getAllSemesters() async {
    try {
      final res = await _s
          .from('semesters')
          .select()
          .order('start_date', ascending: false);

      return (res as List)
          .cast<Map<String, dynamic>>()
          .map(Semester.fromMap)
          .toList();
    } catch (e, stack) {
      TelemetryService.instance.logError(
        'semester_fetch_all',
        error: e,
        stack: stack,
      );
      AppLog.error(_scope, 'Error fetching all semesters', error: e);
      return [];
    }
  }
}
