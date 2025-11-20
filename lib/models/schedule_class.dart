// lib/models/schedule_class.dart

import '../utils/instructor_utils.dart';

class ScheduleClass {
  final int id;
  final int sectionId;
  final int day; // 1..7
  final String start;
  final String end;
  final String code;
  final String title;
  final String room;
  final String instructor;
  final String? instructorAvatar;
  final int? units;
  final bool enabled;

  const ScheduleClass({
    required this.id,
    required this.sectionId,
    required this.day,
    required this.start,
    required this.end,
    required this.code,
    required this.title,
    required this.room,
    required this.instructor,
    this.instructorAvatar,
    this.units,
    this.enabled = true,
  });

  factory ScheduleClass.fromMap(Map<String, dynamic> m) {
    String? readAvatar(Map<String, dynamic> map) {
      final direct = map['instructor_avatar'] ?? map['avatar_url'];
      if (direct is String && direct.trim().isNotEmpty) return direct.trim();
      final nested = map['instructors'];
      if (nested is Map<String, dynamic>) {
        final nestedAvatar = nested['avatar_url'];
        if (nestedAvatar is String && nestedAvatar.trim().isNotEmpty) {
          return nestedAvatar.trim();
        }
      }
      return null;
    }

    return ScheduleClass(
      id: (m['id'] as num).toInt(),
      sectionId: (m['section_id'] as num).toInt(),
      day: m['day'] is num ? (m['day'] as num).toInt() : _parseDay(m['day']),
      start: (m['start'] ?? m['start_time']).toString(),
      end: (m['end'] ?? m['end_time']).toString(),
      code: (m['code'] ?? '').toString(),
      title: (m['title'] ?? m['subject'] ?? '').toString(),
      room: (m['room'] ?? '').toString(),
      instructor: resolveInstructorName(m),
      instructorAvatar: readAvatar(m),
      units: (m['units'] == null) ? null : (m['units'] as num).toInt(),
      enabled: m['enabled'] is bool
          ? m['enabled'] as bool
          : ((m['enabled'] ?? 1) == 1),
    );
  }

  // Helper to parse day string to int (e.g., 'Mon' -> 1, 'Tue' -> 2, ...)
  static int _parseDay(dynamic day) {
    if (day is num) return day.toInt();
    if (day is String) {
      switch (day.substring(0, 3).toLowerCase()) {
        case 'mon':
          return 1;
        case 'tue':
          return 2;
        case 'wed':
          return 3;
        case 'thu':
          return 4;
        case 'fri':
          return 5;
        case 'sat':
          return 6;
        case 'sun':
          return 7;
      }
    }
    return 0;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'section_id': sectionId,
        'day': day,
        'start': start,
        'end': end,
        'code': code,
        'title': title,
        'room': room,
        'instructor': instructor,
        'instructor_avatar': instructorAvatar,
        'units': units,
        'enabled': enabled,
      };
}
