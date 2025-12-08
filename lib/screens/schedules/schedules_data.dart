import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../services/schedule_repository.dart' as sched;
import 'package:flutter/material.dart' show Color;

import '../../ui/theme/tokens.dart';
import '../../utils/schedule_overlap.dart' as schedule_overlap;

enum ScheduleAction { reset, pdf, csv }

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
  List<DayGroup> groups,
  {
  DateTime? now,
}
) {
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
  List<sched.ClassItem> items,
  {
  DateTime? now,
}
) {
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

/// Returns true when two class sessions overlap in time on the calendar.
///
/// Adjacent sessions that touch at boundaries (end == start) are not treated
/// as overlapping. Overnight classes (end before start) span into the next day.
bool classesOverlap(sched.ClassItem a, sched.ClassItem b) =>
    schedule_overlap.classesOverlap(a, b);

Future<Uint8List> buildSchedulePdf(
  List<DayGroup> groups,
  {
  DateTime? now,
}
) async {
  final timestamp = now ?? DateTime.now();
  final stamp = DateFormat('MMMM d, yyyy - h:mm a').format(timestamp);

  // Map design tokens into PDF text styles to keep exports aligned.
  // We only use sizes/weights/colors that exist in AppTokens.
  final pdfTypography = _PdfTypography.fromTokens(AppTokens.typography);
  final pdfColors = _PdfColors.fromPalette(AppTokens.lightColors);

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
              style: pdfTypography.headline.copyWith(color: pdfColors.onSurface),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Generated at $stamp',
              style: pdfTypography.body.copyWith(color: pdfColors.muted),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              'No classes scheduled.',
              style: pdfTypography.body.copyWith(color: pdfColors.onSurface),
            ),
          ];
        }

        return [
          pw.Text(
            'MySched timetable',
            style: pdfTypography.headline.copyWith(color: pdfColors.onSurface),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated at $stamp',
            style: pdfTypography.body.copyWith(color: pdfColors.muted),
          ),
          pw.SizedBox(height: 24),
          for (final group in groups) ...[
            pw.Text(
              group.label,
              style: pdfTypography.title.copyWith(
                color: pdfColors.accent,
              ),
            ),
            pw.SizedBox(height: 8),
            for (final item in group.items) ...[
              pw.Text(
                item.title ?? item.code ?? 'Untitled class',
                style: pdfTypography.subtitle.copyWith(
                  color: pdfColors.onSurface,
                ),
              ),
              pw.Text(
                '${_formatTime(item.start)} - ${_formatTime(item.end)}',
                style: pdfTypography.body.copyWith(color: pdfColors.muted),
              ),
              if (item.room != null && item.room!.trim().isNotEmpty)
                pw.Text(
                  'Room: ${item.room}',
                  style: pdfTypography.body.copyWith(color: pdfColors.muted),
                ),
              if (item.instructor != null && item.instructor!.trim().isNotEmpty)
                pw.Text(
                  'Instructor: ${item.instructor}',
                  style: pdfTypography.body.copyWith(color: pdfColors.muted),
                ),
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

/// Lightweight mapping of Flutter text tokens into pdf.TextStyle.
class _PdfTypography {
  const _PdfTypography({
    required this.headline,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.caption,
  });

  final pw.TextStyle headline;
  final pw.TextStyle title;
  final pw.TextStyle subtitle;
  final pw.TextStyle body;
  final pw.TextStyle caption;

  factory _PdfTypography.fromTokens(AppTypography tokens) {
    return _PdfTypography(
      headline: pw.TextStyle(
        fontSize: tokens.headline.fontSize,
        fontWeight: pw.FontWeight.bold,
      ),
      title: pw.TextStyle(
        fontSize: tokens.title.fontSize,
        fontWeight: pw.FontWeight.bold,
      ),
      subtitle: pw.TextStyle(
        fontSize: tokens.subtitle.fontSize,
        fontWeight: pw.FontWeight.bold,
      ),
      body: pw.TextStyle(
        fontSize: tokens.body.fontSize,
        fontWeight: pw.FontWeight.normal,
      ),
      caption: pw.TextStyle(
        fontSize: tokens.caption.fontSize,
        fontWeight: pw.FontWeight.normal,
      ),
    );
  }
}

class _PdfColors {
  const _PdfColors({
    required this.onSurface,
    required this.muted,
    required this.accent,
  });

  final PdfColor onSurface;
  final PdfColor muted;
  final PdfColor accent;

  factory _PdfColors.fromPalette(ColorPalette palette) {
    PdfColor toPdf(Color c) => PdfColor.fromInt(c.toARGB32());
    return _PdfColors(
      onSurface: toPdf(palette.onSurface),
      muted: toPdf(palette.onSurfaceVariant),
      accent: toPdf(palette.primary),
    );
  }
}

class ScheduleSummary {
  const ScheduleSummary({
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
  final ScheduleHighlight? highlight;

  static ScheduleSummary resolve(List<sched.ClassItem> items, DateTime now) {
    if (items.isEmpty) {
      return const ScheduleSummary(
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
    return ScheduleSummary(
      total: total,
      active: active,
      disabled: disabled,
      custom: custom,
      highlight: highlight,
    );
  }

  static ScheduleHighlight? _computeNextHighlight(
    List<sched.ClassItem> items,
    DateTime now,
  ) {
    final enabledItems = items.where((item) => item.enabled).toList();
    if (enabledItems.isEmpty) return null;
    ScheduleHighlight? closest;
    for (final item in enabledItems) {
      final highlight = ScheduleHighlight.resolve(item, now);
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

class ScheduleHighlight {
  const ScheduleHighlight({
    required this.item,
    required this.start,
    required this.end,
    required this.status,
  });

  final sched.ClassItem item;
  final DateTime start;
  final DateTime end;
  final ScheduleHighlightStatus status;

  static ScheduleHighlight resolve(sched.ClassItem item, DateTime now) {
    final start = _nextOccurrence(item, now);
    final end = _endFor(item, start);
    final status = now.isAfter(start) && now.isBefore(end)
        ? ScheduleHighlightStatus.ongoing
        : ScheduleHighlightStatus.upcoming;
    return ScheduleHighlight(
      item: item,
      start: start,
      end: end,
      status: status,
    );
  }
}

enum ScheduleHighlightStatus { upcoming, ongoing }

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
