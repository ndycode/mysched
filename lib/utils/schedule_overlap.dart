import '../services/schedule_repository.dart';

/// Returns true when two class sessions overlap in time on the calendar.
///
/// Adjacent sessions that touch at boundaries (end == start) are not treated
/// as overlapping. Overnight classes (end before start) span into the next day.
bool classesOverlap(ClassItem a, ClassItem b) {
  int startMinutes(ClassItem item) {
    final parts = item.start.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return hour.clamp(0, 23) * 60 + minute.clamp(0, 59);
  }

  int endMinutes(ClassItem item) {
    final parts = item.end.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return hour.clamp(0, 23) * 60 + minute.clamp(0, 59);
  }

  int startAbs(ClassItem item) {
    return (item.day - 1) * 24 * 60 + startMinutes(item);
  }

  int endAbs(ClassItem item) {
    final start = startMinutes(item);
    var end = endMinutes(item);
    final base = (item.day - 1) * 24 * 60;
    // Treat end before or equal start as overnight into the next day
    if (end <= start) {
      end += 24 * 60;
    }
    return base + end;
  }

  final aStart = startAbs(a);
  final aEnd = endAbs(a);
  final bStart = startAbs(b);
  final bEnd = endAbs(b);

  return aStart < bEnd && bStart < aEnd;
}

/// Represents a time conflict between a proposed class and an existing class.
class ClassConflict {
  const ClassConflict({
    required this.existingClass,
    required this.overlapMinutes,
  });

  /// The existing class that conflicts with the proposed class.
  final ClassItem existingClass;

  /// Approximate overlap duration in minutes.
  final int overlapMinutes;
}

/// Finds all schedule conflicts for a proposed class against existing classes.
///
/// [proposedDay] - Day of week (1-7, Monday-Sunday)
/// [proposedStart] - Start time as "HH:MM" string
/// [proposedEnd] - End time as "HH:MM" string
/// [existingClasses] - List of existing classes to check against
/// [excludeId] - Optional class ID to exclude (for editing existing class)
///
/// Returns list of [ClassConflict] for each overlapping class.
List<ClassConflict> findScheduleConflicts({
  required int proposedDay,
  required String proposedStart,
  required String proposedEnd,
  required List<ClassItem> existingClasses,
  int? excludeId,
}) {
  // Create a temporary ClassItem to use with classesOverlap
  final proposed = ClassItem(
    id: -1, // Temporary ID
    code: null,
    title: 'Proposed',
    units: null,
    room: null,
    instructor: null,
    instructorAvatar: null,
    day: proposedDay,
    start: proposedStart,
    end: proposedEnd,
    enabled: true,
    isCustom: true,
  );

  final conflicts = <ClassConflict>[];

  for (final existing in existingClasses) {
    // Skip the same class (when editing)
    if (excludeId != null && existing.id == excludeId) continue;

    // Only check enabled classes
    if (!existing.enabled) continue;

    if (classesOverlap(proposed, existing)) {
      // Calculate overlap duration
      final overlap = _calculateOverlap(proposed, existing);
      conflicts.add(ClassConflict(
        existingClass: existing,
        overlapMinutes: overlap,
      ));
    }
  }

  return conflicts;
}

/// Calculates the approximate overlap duration in minutes between two classes.
int _calculateOverlap(ClassItem a, ClassItem b) {
  int toMinutes(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return hour * 60 + minute;
  }

  // Only calculate if on the same day (simplified)
  if (a.day != b.day) return 0;

  final aStart = toMinutes(a.start);
  var aEnd = toMinutes(a.end);
  if (aEnd <= aStart) aEnd += 24 * 60;

  final bStart = toMinutes(b.start);
  var bEnd = toMinutes(b.end);
  if (bEnd <= bStart) bEnd += 24 * 60;

  final overlapStart = aStart > bStart ? aStart : bStart;
  final overlapEnd = aEnd < bEnd ? aEnd : bEnd;

  final overlap = overlapEnd - overlapStart;
  return overlap > 0 ? overlap : 0;
}
