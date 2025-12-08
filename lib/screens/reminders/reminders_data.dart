import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../services/reminders_repository.dart';

String friendlyError(Object error) {
  final text = error.toString();
  if (text.contains('Not authenticated')) {
    return 'Please sign in again to manage reminders.';
  }
  return 'Something went wrong. Please try again.';
}

class ReminderSummary {
  const ReminderSummary({
    required this.total,
    required this.pending,
    required this.overdue,
    required this.snoozed,
    required this.completed,
    this.highlight,
  });

  factory ReminderSummary.resolve(List<ReminderEntry> entries, DateTime now) {
    final total = entries.length;
    final pendingEntries = <ReminderEntry>[];
    var snoozed = 0;
    for (final entry in entries) {
      final isCompleted = entry.isCompleted;
      final isSnoozed = !isCompleted &&
          entry.snoozeUntil != null &&
          entry.snoozeUntil!.isAfter(now);
      if (!isCompleted) {
        pendingEntries.add(entry);
      }
      if (isSnoozed) {
        snoozed++;
      }
    }
    pendingEntries.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    final overdueEntries = pendingEntries
        .where((entry) => entry.dueAt.isBefore(now))
        .toList(growable: false);
    final overdue = overdueEntries.length;
    final completed = total - pendingEntries.length;

    ReminderHighlight? highlight;
    if (pendingEntries.isNotEmpty) {
      if (overdueEntries.isNotEmpty) {
        final entry = overdueEntries.first;
        highlight = ReminderHighlight(
          entry: entry,
          status: ReminderHighlightStatus.overdue,
          targetTime: entry.dueAt.toLocal(),
        );
      } else {
        final entry = pendingEntries.first;
        final isSnoozed = entry.snoozeUntil != null &&
            entry.snoozeUntil!.toLocal().isAfter(now);
        final target =
            isSnoozed ? entry.snoozeUntil!.toLocal() : entry.dueAt.toLocal();
        highlight = ReminderHighlight(
          entry: entry,
          status: isSnoozed
              ? ReminderHighlightStatus.snoozed
              : ReminderHighlightStatus.upcoming,
          targetTime: target,
        );
      }
    }

    return ReminderSummary(
      total: total,
      pending: pendingEntries.length,
      overdue: overdue,
      snoozed: snoozed,
      completed: completed,
      highlight: highlight,
    );
  }

  final int total;
  final int pending;
  final int overdue;
  final int snoozed;
  final int completed;
  final ReminderHighlight? highlight;
}

enum ReminderHighlightStatus { overdue, snoozed, upcoming }

class ReminderHighlight {
  const ReminderHighlight({
    required this.entry,
    required this.status,
    required this.targetTime,
  });

  final ReminderEntry entry;
  final ReminderHighlightStatus status;
  final DateTime targetTime;
}

class ReminderGroup {
  const ReminderGroup({required this.label, required this.items});

  final String label;
  final List<ReminderEntry> items;
}

/// Build CSV export content for reminders.
String buildRemindersCsv(List<ReminderEntry> entries, {DateTime? now}) {
  final timestamp = now ?? DateTime.now();
  final stamp = DateFormat('MMMM d, yyyy - h:mm a').format(timestamp);
  final buffer = StringBuffer();
  buffer.writeln('MySched Reminders');
  buffer.writeln('Generated at $stamp');
  buffer.writeln('');
  buffer.writeln('Title,Due Date,Due Time,Status,Details,Created');

  for (final entry in entries) {
    final local = entry.dueAt.toLocal();
    final date = DateFormat('yyyy-MM-dd').format(local);
    final time = DateFormat('HH:mm').format(local);
    final status = entry.isCompleted ? 'Completed' : 'Pending';
    final details = (entry.details ?? '').replaceAll('"', '""');
    final created = DateFormat('yyyy-MM-dd').format(entry.createdAt.toLocal());
    final title = entry.title.replaceAll('"', '""');
    buffer.writeln('"$title","$date","$time","$status","$details","$created"');
  }

  return buffer.toString();
}

/// Build plain text export content for reminders.
String buildRemindersPlainText(List<ReminderEntry> entries, {DateTime? now}) {
  final timestamp = now ?? DateTime.now();
  final stamp = DateFormat('MMMM d, yyyy - h:mm a').format(timestamp);
  final buffer = StringBuffer();
  buffer.writeln('MySched Reminders');
  buffer.writeln('Generated at $stamp');
  buffer.writeln('');

  if (entries.isEmpty) {
    buffer.writeln('No reminders.');
    return buffer.toString();
  }

  for (final entry in entries) {
    final local = entry.dueAt.toLocal();
    final dueLabel = DateFormat('MMM d, yyyy - h:mm a').format(local);
    final status = entry.isCompleted ? '[Done]' : '[Pending]';
    buffer.writeln('$status ${entry.title}');
    buffer.writeln('  Due: $dueLabel');
    if (entry.details != null && entry.details!.trim().isNotEmpty) {
      buffer.writeln('  Notes: ${entry.details}');
    }
    buffer.writeln('');
  }

  return buffer.toString();
}

/// Build PDF export content for reminders.
Future<Uint8List> buildRemindersPdf(
  List<ReminderEntry> entries, {
  DateTime? now,
}) async {
  final timestamp = now ?? DateTime.now();
  final stamp = DateFormat('MMMM d, yyyy - h:mm a').format(timestamp);

  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Text(
            'MySched Reminders',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Text(
          'Generated at $stamp',
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 20),
        if (entries.isEmpty)
          pw.Text('No reminders.')
        else
          ...entries.map((entry) {
            final local = entry.dueAt.toLocal();
            final dueLabel = DateFormat('MMM d, yyyy - h:mm a').format(local);
            final status = entry.isCompleted ? 'Completed' : 'Pending';
            final statusColor =
                entry.isCompleted ? PdfColors.green700 : PdfColors.orange700;

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          entry.title,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: pw.BoxDecoration(
                          color: statusColor,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          status,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Due: $dueLabel',
                    style: const pw.TextStyle(
                      fontSize: 11,
                      color: PdfColors.grey700,
                    ),
                  ),
                  if (entry.details != null &&
                      entry.details!.trim().isNotEmpty) ...[
                    pw.SizedBox(height: 6),
                    pw.Text(
                      entry.details!,
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
      ],
    ),
  );

  return pdf.save();
}
