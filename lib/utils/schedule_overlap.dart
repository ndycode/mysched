import '../services/schedule_api.dart';

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
