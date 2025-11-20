part of 'reminders_screen.dart';

String _friendlyError(Object error) {
  final text = error.toString();
  if (text.contains('Not authenticated')) {
    return 'Please sign in again to manage reminders.';
  }
  return 'Something went wrong. Please try again.';
}

class _ReminderSummary {
  const _ReminderSummary({
    required this.total,
    required this.pending,
    required this.overdue,
    required this.snoozed,
    required this.completed,
    this.highlight,
  });

  factory _ReminderSummary.resolve(List<ReminderEntry> entries, DateTime now) {
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

    _ReminderHighlight? highlight;
    if (pendingEntries.isNotEmpty) {
      if (overdueEntries.isNotEmpty) {
        final entry = overdueEntries.first;
        highlight = _ReminderHighlight(
          entry: entry,
          status: _ReminderHighlightStatus.overdue,
          targetTime: entry.dueAt.toLocal(),
        );
      } else {
        final entry = pendingEntries.first;
        final isSnoozed = entry.snoozeUntil != null &&
            entry.snoozeUntil!.toLocal().isAfter(now);
        final target =
            isSnoozed ? entry.snoozeUntil!.toLocal() : entry.dueAt.toLocal();
        highlight = _ReminderHighlight(
          entry: entry,
          status: isSnoozed
              ? _ReminderHighlightStatus.snoozed
              : _ReminderHighlightStatus.upcoming,
          targetTime: target,
        );
      }
    }

    return _ReminderSummary(
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
  final _ReminderHighlight? highlight;
}

enum _ReminderHighlightStatus { overdue, snoozed, upcoming }

class _ReminderHighlight {
  const _ReminderHighlight({
    required this.entry,
    required this.status,
    required this.targetTime,
  });

  final ReminderEntry entry;
  final _ReminderHighlightStatus status;
  final DateTime targetTime;
}

class _ReminderGroup {
  const _ReminderGroup({required this.label, required this.items});

  final String label;
  final List<ReminderEntry> items;
}
