// lib/services/instructor_service.dart
import 'package:flutter/foundation.dart';

import '../env.dart';
import '../models/instructor.dart';
import '../services/schedule_repository.dart';
import 'semester_service.dart';
import 'telemetry_service.dart';

/// Service for detecting and managing instructor role.
/// 
/// When a user logs in, this service checks if their user_id exists
/// in the instructors table. If yes, they're treated as an instructor
/// with access to their teaching schedule.
class InstructorService {
  InstructorService._();
  static final InstructorService instance = InstructorService._();

  /// For testing: override the instructor loader
  static Future<Instructor?> Function()? _testInstructorLoader;
  
  @visibleForTesting
  static void overrideInstructorLoader(Future<Instructor?> Function() loader) {
    _testInstructorLoader = loader;
  }

  @visibleForTesting 
  static void resetTestOverrides() {
    _testInstructorLoader = null;
    instance._cachedInstructor = null;
    instance._hasChecked = false;
  }

  Instructor? _cachedInstructor;
  bool _hasChecked = false;

  /// Whether the current user is an instructor.
  /// Returns false until [checkInstructorStatus] has been called.
  bool get isInstructor => _cachedInstructor != null;

  /// The current instructor record, if the user is an instructor.
  Instructor? get currentInstructor => _cachedInstructor;

  /// Check if the current authenticated user is an instructor.
  /// This should be called after login to determine the user's role.
  /// 
  /// Returns the Instructor record if found, null otherwise.
  Future<Instructor?> checkInstructorStatus() async {
    // Use test override if available
    if (_testInstructorLoader != null) {
      _cachedInstructor = await _testInstructorLoader!();
      _hasChecked = true;
      return _cachedInstructor;
    }

    final userId = Env.supa.auth.currentUser?.id;
    if (userId == null) {
      _cachedInstructor = null;
      _hasChecked = true;
      return null;
    }

    try {
      final rows = await Env.supa
          .from('instructors')
          .select()
          .eq('user_id', userId)
          .limit(1);

      final list = (rows as List).cast<Map<String, dynamic>>();
      if (list.isNotEmpty) {
        _cachedInstructor = Instructor.fromJson(list.first);
        TelemetryService.instance.recordEvent(
          'instructor_role_detected',
          data: {'instructor_id': _cachedInstructor!.id},
        );
      } else {
        _cachedInstructor = null;
      }
      _hasChecked = true;
      return _cachedInstructor;
    } catch (e) {
      TelemetryService.instance.recordEvent(
        'instructor_check_failed',
        data: {'error': e.toString()},
      );
      _cachedInstructor = null;
      _hasChecked = true;
      return null;
    }
  }

  /// Clear cached instructor status (call on logout).
  void clear() {
    _cachedInstructor = null;
    _hasChecked = false;
  }

  /// Get classes assigned to the current instructor.
  /// Returns empty list if user is not an instructor.
  Future<List<ClassItem>> getInstructorClasses() async {
    final instructor = _cachedInstructor;
    if (instructor == null) {
      return [];
    }

    try {
      // Get active semester
      final semester = await SemesterService.instance.getActiveSemester();
      if (semester == null) {
        return [];
      }

      // Query classes where instructor_id matches and semester is active
      final rows = await Env.supa
          .from('classes')
          .select('''
            id,
            code,
            title,
            units,
            room,
            day,
            start,
            end,
            section_id,
            sections!inner(
              id,
              code,
              section_number,
              semester_id
            ),
            instructors(
              id,
              full_name,
              avatar_url
            )
          ''')
          .eq('instructor_id', instructor.id)
          .eq('sections.semester_id', semester.id)
          .isFilter('archived_at', null);

      final list = (rows as List).cast<Map<String, dynamic>>();
      
      return list.map((json) {
        final instructorData = json['instructors'] as Map<String, dynamic>?;
        return ClassItem(
          id: json['id'] as int,
          code: json['code'] as String? ?? '',
          title: json['title'] as String? ?? '',
          units: json['units'] as int? ?? 0,
          room: json['room'] as String? ?? '',
          instructor: instructorData?['full_name'] as String? ?? '',
          instructorAvatar: instructorData?['avatar_url'] as String?,
          day: _parseDay(json['day']),
          start: json['start'] as String? ?? '00:00',
          end: json['end'] as String? ?? '00:00',
          enabled: true,
          isCustom: false,
        );
      }).toList();
    } catch (e) {
      TelemetryService.instance.recordEvent(
        'instructor_classes_fetch_failed',
        data: {'error': e.toString()},
      );
      return [];
    }
  }

  int _parseDay(dynamic day) {
    if (day is int) return day;
    if (day is String) {
      const dayMap = {
        'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4,
        'Fri': 5, 'Sat': 6, 'Sun': 7,
      };
      return dayMap[day] ?? 1;
    }
    return 1;
  }
}
