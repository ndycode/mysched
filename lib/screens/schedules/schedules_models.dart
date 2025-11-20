part of 'schedules_screen.dart';

enum _ScheduleAction { reset, pdf, csv }

class DayGroup {
  const DayGroup({
    required this.day,
    required this.label,
    required this.items,
  });

  final int day;
  final String label;
  final List<sched.ClassItem> items;
}

List<DayGroup> groupClassesByDay(List<sched.ClassItem> items) {
  if (items.isEmpty) return const <DayGroup>[];
  final map = <int, List<sched.ClassItem>>{};
  for (final item in items) {
    map.putIfAbsent(item.day, () => <sched.ClassItem>[]).add(item);
  }
  final days = map.keys.toList()..sort();
  final groups = <DayGroup>[];
  for (final day in days) {
    final list = map[day]!;
    list.sort(
      (a, b) => _minutesFromText(a.start).compareTo(_minutesFromText(b.start)),
    );
    groups.add(
      DayGroup(
        day: day,
        label: _weekdayName(day),
        items: list,
      ),
    );
  }
  return groups;
}

String buildSchedulePlainText(
  List<DayGroup> groups, {
  DateTime? now,
}) {
  final buffer = StringBuffer();
  final timestamp = now ?? DateTime.now();
  final stamp = DateFormat('MMMM d, yyyy - h:mm a').format(timestamp);
  buffer.writeln('MySched timetable');
  buffer.writeln('Generated at $stamp');
  buffer.writeln('');

  if (groups.isEmpty) {
    buffer.writeln('No classes scheduled.');
    return buffer.toString();
  }

  for (final group in groups) {
    buffer.writeln(group.label);
    for (final item in group.items) {
      final title = item.title ?? item.code ?? 'Untitled class';
      final range = '${_formatTime(item.start)} - ${_formatTime(item.end)}';
      buffer.writeln('- $title');
      buffer.writeln('  $range');
      if (item.room != null && item.room!.trim().isNotEmpty) {
        buffer.writeln('  Room: ${item.room}');
      }
      if (item.instructor != null && item.instructor!.trim().isNotEmpty) {
        buffer.writeln('  Instructor: ${item.instructor}');
      }
      buffer.writeln('');
    }
  }

  return buffer.toString();
}

String buildScheduleCsv(
  List<sched.ClassItem> items, {
  DateTime? now,
}) {
  final timestamp = now ?? DateTime.now();
  final stamp = DateFormat('MMMM d, yyyy - h:mm a').format(timestamp);
  final buffer = StringBuffer();
  buffer.writeln('MySched timetable');
  buffer.writeln('Generated at $stamp');
  buffer.writeln(
    'Day,Start,End,Title,Code,Room,Instructor,Enabled,Source',
  );
  for (final item in items) {
    final day = _weekdayName(item.day);
    final start = _format24Hour(item.start);
    final end = _format24Hour(item.end);
    final title = _escapeCsv(item.title ?? item.code ?? 'Untitled class');
    final code = _escapeCsv(item.code ?? '');
    final room = _escapeCsv(item.room ?? '');
    final instructor = _escapeCsv(item.instructor ?? '');
    final enabled = item.enabled ? 'Yes' : 'No';
    final source = item.isCustom ? 'Custom' : 'Linked';
    buffer.writeln(
      '$day,$start,$end,$title,$code,$room,$instructor,$enabled,$source',
    );
  }
  return buffer.toString();
}

Future<Uint8List> buildSchedulePdf(
  List<DayGroup> groups, {
  DateTime? now,
}) async {
  final timestamp = now ?? DateTime.now();
  final stamp = DateFormat('MMMM d, yyyy - h:mm a').format(timestamp);
  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageTheme: const pw.PageTheme(
        margin: pw.EdgeInsets.all(40),
        textDirection: pw.TextDirection.ltr,
      ),
      build: (context) {
        if (groups.isEmpty) {
          return [
            pw.Text(
              'MySched timetable',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Generated at $stamp'),
            pw.SizedBox(height: 24),
            pw.Text('No classes scheduled.'),
          ];
        }

        return [
          pw.Text(
            'MySched timetable',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Generated at $stamp'),
          pw.SizedBox(height: 24),
          for (final group in groups) ...[
            pw.Text(
              group.label,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 8),
            for (final item in group.items) ...[
              pw.Text(
                item.title ?? item.code ?? 'Untitled class',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '${_formatTime(item.start)} - ${_formatTime(item.end)}',
              ),
              if (item.room != null && item.room!.trim().isNotEmpty)
                pw.Text('Room: ${item.room}'),
              if (item.instructor != null && item.instructor!.trim().isNotEmpty)
                pw.Text('Instructor: ${item.instructor}'),
              pw.SizedBox(height: 12),
            ],
            pw.SizedBox(height: 12),
          ],
        ];
      },
    ),
  );
  return Uint8List.fromList(await doc.save());
}

class _ScheduleSummary {
  const _ScheduleSummary({
    required this.total,
    required this.active,
    required this.disabled,
    required this.custom,
    required this.highlight,
  });

  final int total;
  final int active;
  final int disabled;
  final int custom;
  final _ScheduleHighlight? highlight;

  static _ScheduleSummary resolve(List<sched.ClassItem> items, DateTime now) {
    if (items.isEmpty) {
      return const _ScheduleSummary(
        total: 0,
        active: 0,
        disabled: 0,
        custom: 0,
        highlight: null,
      );
    }
    final total = items.length;
    final active = items.where((item) => item.enabled).length;
    final custom = items.where((item) => item.isCustom).length;
    final disabled = total - active;
    final highlight = _computeNextHighlight(items, now);
    return _ScheduleSummary(
      total: total,
      active: active,
      disabled: disabled,
      custom: custom,
      highlight: highlight,
    );
  }

  static _ScheduleHighlight? _computeNextHighlight(
    List<sched.ClassItem> items,
    DateTime now,
  ) {
    final enabledItems = items.where((item) => item.enabled).toList();
    if (enabledItems.isEmpty) return null;
    _ScheduleHighlight? closest;
    for (final item in enabledItems) {
      final highlight = _ScheduleHighlight.resolve(item, now);
      if (closest == null) {
        closest = highlight;
        continue;
      }
      final currentDiff = highlight.start.difference(now).abs();
      final bestDiff = closest.start.difference(now).abs();
      if (currentDiff < bestDiff) {
        closest = highlight;
      }
    }
    return closest;
  }
}

class _ScheduleHighlight {
  const _ScheduleHighlight({
    required this.item,
    required this.start,
    required this.end,
    required this.status,
  });

  final sched.ClassItem item;
  final DateTime start;
  final DateTime end;
  final _ScheduleHighlightStatus status;

  static _ScheduleHighlight resolve(sched.ClassItem item, DateTime now) {
    final start = _nextOccurrence(item, now);
    final end = _endFor(item, start);
    final status = now.isAfter(start) && now.isBefore(end)
        ? _ScheduleHighlightStatus.ongoing
        : _ScheduleHighlightStatus.upcoming;
    return _ScheduleHighlight(
      item: item,
      start: start,
      end: end,
      status: status,
    );
  }
}

enum _ScheduleHighlightStatus { upcoming, ongoing }

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
    final parts = text.split(':').map((part) => part.trim()).toList();
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

String _formatTime(String raw) {
  final minutes = _minutesFromText(raw);
  final dt = _timeFromMinutes(minutes);
  return DateFormat('h:mm a').format(dt);
}

String _format24Hour(String raw) {
  final minutes = _minutesFromText(raw);
  final hour = (minutes ~/ 60).toString().padLeft(2, '0');
  final minute = (minutes % 60).toString().padLeft(2, '0');
  return '$hour:$minute';
}

DateTime _nextOccurrence(sched.ClassItem item, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final minutes = _minutesFromText(item.start);
  final hour = minutes ~/ 60;
  final minute = minutes % 60;
  final dayDiff = (item.day - now.weekday + 7) % 7;
  var start = DateTime(
    today.year,
    today.month,
    today.day,
    hour,
    minute,
  ).add(Duration(days: dayDiff));

  final end = _endFor(item, start);
  if (dayDiff == 0 && end.isBefore(now)) {
    start = start.add(const Duration(days: 7));
  }
  return start;
}

DateTime _endFor(sched.ClassItem item, DateTime start) {
  final endMinutes = _minutesFromText(item.end);
  final endHour = endMinutes ~/ 60;
  final endMinute = endMinutes % 60;
  var end = DateTime(
    start.year,
    start.month,
    start.day,
    endHour,
    endMinute,
  );
  if (!end.isAfter(start)) {
    end = end.add(const Duration(days: 1));
  }
  return end;
}

DateTime _timeFromMinutes(int minutes) {
  final hour = minutes ~/ 60;
  final minute = minutes % 60;
  return DateTime(2020, 1, 1, hour, minute);
}

String _weekdayName(int day) {
  const names = [
    '',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  if (day >= 1 && day <= 7) return names[day];
  return 'Day $day';
}

String _escapeCsv(String value) {
  if (value.contains(',') || value.contains('\n') || value.contains('"')) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
  return value;
}
