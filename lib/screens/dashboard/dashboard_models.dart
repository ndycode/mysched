part of 'dashboard_screen.dart';

class _DashboardSummaryData {
  const _DashboardSummaryData({
    required this.hoursDone,
    required this.hoursPlanned,
    required this.classesPlanned,
    required this.classesRemaining,
    required this.openTasks,
    required this.scopePhrase,
  });

  factory _DashboardSummaryData.resolve({
    required List<ClassOccurrence> occurrences,
    required DateTime now,
    required List<ReminderEntry> reminders,
    required String scopeLabel,
  }) {
    final pendingCount = reminders.where((entry) => !entry.isCompleted).length;
    final completed = occurrences
        .where((occurrence) => occurrence.end.isBefore(now))
        .toList();
    final inProgress =
        occurrences.where((occurrence) => occurrence.isOngoingAt(now)).toList();

    final totalMinutes = occurrences.fold<int>(
      0,
      (acc, occ) => acc + occ.item.duration.inMinutes,
    );
    final completedMinutes = completed.fold<int>(
      0,
      (acc, occ) => acc + occ.item.duration.inMinutes,
    );
    final inProgressMinutes = inProgress.fold<double>(
      0,
      (acc, occ) {
        final elapsed = now.difference(occ.start).inMinutes;
        final clamped = elapsed.clamp(0, occ.item.duration.inMinutes);
        return acc + clamped;
      },
    );

    final hoursPlanned = totalMinutes / 60.0;
    final hoursDone = (completedMinutes + inProgressMinutes) / 60.0;
    final remaining = occurrences.where((occ) => occ.end.isAfter(now)).length;
    final scopePhrase = scopeLabel == 'Today'
        ? 'today'
        : scopeLabel == 'This week'
            ? 'this week'
            : scopeLabel.toLowerCase();

    return _DashboardSummaryData(
      hoursDone: hoursDone,
      hoursPlanned: hoursPlanned,
      classesPlanned: occurrences.length,
      classesRemaining: remaining,
      openTasks: pendingCount,
      scopePhrase: scopePhrase,
    );
  }

  final double hoursDone;
  final double hoursPlanned;
  final int classesPlanned;
  final int classesRemaining;
  final int openTasks;
  final String scopePhrase;

  String get hoursDoneLabel => _formatHours(hoursDone);

  String get hoursCaption => hoursPlanned == 0
      ? 'Free $scopePhrase'
      : 'of ${_formatHours(hoursPlanned)} planned $scopePhrase';

  String get classesRemainingLabel => classesRemaining.toString();

  String get classesCaption => classesPlanned == 0
      ? 'No classes $scopePhrase'
      : '$classesPlanned $scopePhrase';

  String get tasksLabel => openTasks.toString();

  String get tasksCaption => openTasks == 0
      ? 'All clear'
      : openTasks == 1
          ? 'Due soon'
          : '$openTasks due';

  String _formatHours(double value) {
    final totalMinutes = (value * 60).round();
    if (totalMinutes == 0) return '0m';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    // When hours >= 1, only show hours (no minutes)
    if (hours > 0) {
      return '${hours}h';
    }
    // Only show minutes when no full hours
    return '${minutes}m';
  }
}

class _DashboardUpcoming {
  const _DashboardUpcoming({
    required this.occurrences,
    required this.isActive,
    required this.focusDay,
  });

  const _DashboardUpcoming.empty({required this.isActive})
      : occurrences = const [],
        focusDay = null;

  final List<ClassOccurrence> occurrences;
  final bool isActive;
  final DateTime? focusDay;

  bool get hasUpcoming => occurrences.isNotEmpty;

  ClassOccurrence? get primary =>
      occurrences.isEmpty ? null : occurrences.first;
}

class _ReminderAlert {
  const _ReminderAlert({
    required this.icon,
    required this.title,
    required this.message,
    required this.tint,
    this.actionLabel = 'Review',
  });

  final IconData icon;
  final String title;
  final String message;
  final Color tint;
  final String actionLabel;
}

class _TickSnapshot {
  const _TickSnapshot({
    required this.now,
    required this.current,
    required this.next,
    required this.todays,
  });

  final DateTime now;
  final ClassOccurrence? current;
  final ClassOccurrence? next;
  final List<ClassOccurrence> todays;

  static _TickSnapshot resolve(DateTime now, List<ClassItem> classes) {
    final todays = <ClassOccurrence>[];
    final day = DateTime(now.year, now.month, now.day);

    for (final item in classes) {
      final occ = item.occurrenceOn(day);
      if (occ != null) todays.add(occ);
    }

    todays.sort((a, b) => a.start.compareTo(b.start));

    ClassOccurrence? current;
    for (final occ in todays) {
      if (occ.isOngoingAt(now)) {
        current = occ;
        break;
      }
    }

    ClassOccurrence? next;
    for (final occ in todays) {
      if (occ.start.isAfter(now)) {
        next = occ;
        break;
      }
    }

    if (next == null) {
      ClassOccurrence? best;
      for (final item in classes) {
        final upcomingStart = item.nextStartAfter(now);
        final occ = item.occurrenceAt(upcomingStart);
        if (occ != null && occ.end.isAfter(now)) {
          if (best == null || occ.start.isBefore(best.start)) {
            best = occ;
          }
        }
      }
      next = best;
    }

    return _TickSnapshot(
      now: now,
      current: current,
      next: next,
      todays: todays,
    );
  }
}

class ClassOccurrence {
  const ClassOccurrence({
    required this.item,
    required this.start,
    required this.end,
  });

  final ClassItem item;
  final DateTime start;
  final DateTime end;

  bool isOngoingAt(DateTime now) => !start.isAfter(now) && end.isAfter(now);
}

class ClassItem {
  ClassItem({
    required this.id,
    required this.subject,
    required this.room,
    required this.instructor,
    required this.instructorAvatar,
    required this.weekday,
    required this.enabled,
    required this.startTime,
    required this.endTime,
  }) : duration = _computeDuration(startTime, endTime);

  factory ClassItem.fromApi(sched.ClassItem api) {
    final subject = (api.title ?? api.code ?? 'Untitled').trim();
    final room = (api.room ?? '').trim();
    final instructor = (api.instructor ?? '').trim();
    final instructorAvatar = (api.instructorAvatar ?? '').trim();
    final start = _parseTime(api.start);
    final end = _parseTime(api.end);
    return ClassItem(
      id: api.id,
      subject: subject.isEmpty ? 'Class ${api.id}' : subject,
      room: room,
      instructor: instructor,
      instructorAvatar: instructorAvatar.isEmpty ? null : instructorAvatar,
      weekday: api.day,
      enabled: api.enabled,
      startTime: start,
      endTime: end,
    );
  }

  final int id;
  final String subject;
  final String room;
  final String instructor;
  final String? instructorAvatar;
  final int weekday;
  final bool enabled;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Duration duration;

  ClassItem copyWith({
    String? subject,
    String? room,
    String? instructor,
    String? instructorAvatar,
    int? weekday,
    bool? enabled,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    final nextStart = startTime ?? this.startTime;
    final nextEnd = endTime ?? this.endTime;
    return ClassItem(
      id: id,
      subject: subject ?? this.subject,
      room: room ?? this.room,
      instructor: instructor ?? this.instructor,
      instructorAvatar: instructorAvatar ?? this.instructorAvatar,
      weekday: weekday ?? this.weekday,
      enabled: enabled ?? this.enabled,
      startTime: nextStart,
      endTime: nextEnd,
    );
  }

  static Duration _computeDuration(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    var diff = endMinutes - startMinutes;
    if (diff <= 0) diff += 24 * 60;
    return Duration(minutes: diff);
  }

  ClassOccurrence? occurrenceOn(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    final weekdayValue = normalized.weekday;
    if (weekdayValue != weekday) return null;
    final start = DateTime(
      normalized.year,
      normalized.month,
      normalized.day,
      startTime.hour,
      startTime.minute,
    );
    final end = endForStart(start);
    return ClassOccurrence(item: this, start: start, end: end);
  }

  ClassOccurrence? occurrenceOrNull(DateTime? dayOrNull) {
    if (dayOrNull == null) return null;
    return occurrenceOn(dayOrNull);
  }

  ClassOccurrence? occurrenceAt(DateTime start) {
    return occurrenceOn(start);
  }

  DateTime endForStart(DateTime start) => start.add(duration);

  DateTime nextStartAfter(DateTime from) {
    var day = DateTime(from.year, from.month, from.day);
    for (var i = 0; i < 14; i++) {
      final occ = occurrenceOn(day);
      if (occ != null && occ.end.isAfter(from)) {
        return occ.start;
      }
      day = day.add(const Duration(days: 1));
    }
    return occurrenceOn(day)?.start ?? from;
  }
}

TimeOfDay _parseTime(String raw) {
  final minutes = _minutesFromText(raw);
  final hour = (minutes ~/ 60).clamp(0, 23);
  final minute = minutes % 60;
  return TimeOfDay(hour: hour, minute: minute);
}

int _minutesFromText(String raw) {
  final value = raw.trim().toLowerCase().replaceAll('.', '');
  if (value.isEmpty) return 0;
  var text = value;
  var meridian = '';
  if (text.endsWith('am') || text.endsWith('pm')) {
    meridian = text.substring(text.length - 2);
    text = text.substring(0, text.length - 2).trim();
  }
  int hour;
  int minute;
  if (text.contains(':')) {
    final parts = text.split(':');
    hour = int.tryParse(parts[0]) ?? 0;
    minute = parts.length >= 2 ? int.tryParse(parts[1]) ?? 0 : 0;
  } else {
    hour = int.tryParse(text) ?? 0;
    minute = 0;
  }
  if (meridian == 'pm' && hour != 12) hour += 12;
  if (meridian == 'am' && hour == 12) hour = 0;
  hour = hour.clamp(0, 23);
  minute = minute.clamp(0, 59);
  return hour * 60 + minute;
}
