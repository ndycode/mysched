// lib/widgets/schedule_list.dart
import 'package:flutter/material.dart';
import '../ui/kit/status_chip.dart';
import '../ui/theme/tokens.dart';
import '../services/schedule_api.dart';

/// Reusable schedule list widget (grouped by day, toggle, delete, refresh, optional edit for custom)
class ScheduleList extends StatelessWidget {
  final List<ClassItem> items;
  final Future<void> Function(ClassItem, bool) onToggle;
  final Future<void> Function(ClassItem) onDelete;
  final Future<void> Function() onRefresh;
  final Future<void> Function(ClassItem)?
      onEdit; // optional, used for custom entries
  final String title;

  const ScheduleList({
    super.key,
    required this.items,
    required this.onToggle,
    required this.onDelete,
    required this.onRefresh,
    this.onEdit,
    this.title = 'Class Schedules',
  });

  String _dayLabel(int d) => const [
        '',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ][d];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final byDay = <int, List<ClassItem>>{for (var d = 1; d <= 7; d++) d: []};
    for (final c in items) {
      byDay[c.day]!.add(c);
    }
    for (final d in byDay.keys) {
      byDay[d]!.sort((a, b) => a.start.compareTo(b.start));
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int? activeClassId;

    // Find the single active class (current or next) for today
    final todaysClasses = byDay[now.weekday];
    if (todaysClasses != null) {
      for (final c in todaysClasses) {
        final endTime = _parseTime(c.end);
        var end = DateTime(
          today.year,
          today.month,
          today.day,
          endTime.hour,
          endTime.minute,
        );
        // Handle overnight classes if necessary (simple heuristic)
        final startTime = _parseTime(c.start);
        final start = DateTime(
          today.year,
          today.month,
          today.day,
          startTime.hour,
          startTime.minute,
        );
        if (end.isBefore(start)) {
          end = end.add(const Duration(days: 1));
        }

        if (end.isAfter(now)) {
          activeClassId = c.id;
          break; // Found the first one that hasn't finished yet
        }
      }
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: colors.primary,
      backgroundColor: Colors.transparent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: AppTokens.spacing.md),
          for (var d = 1; d <= 7; d++)
            if (byDay[d]!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text(
                  _dayLabel(d),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (int i = 0; i < byDay[d]!.length; i++)
                      _Row(
                        c: byDay[d]![i],
                        showDivider: i != byDay[d]!.length - 1,
                        isActive: byDay[d]![i].id == activeClassId,
                        onToggle: (v) => onToggle(byDay[d]![i], v),
                        onDelete: () => onDelete(byDay[d]![i]),
                        onEdit: onEdit,
                      ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final ClassItem c;
  final bool showDivider;
  final bool isActive;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final Future<void> Function(ClassItem)? onEdit;

  const _Row({
    required this.c,
    required this.showDivider,
    this.isActive = false,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  String _range(String a, String b) => '$a-$b';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final muted = colors.onSurfaceVariant.withValues(alpha: 0.7);
    final title = (c.title ?? '').trim();
    final code = (c.code ?? '').trim();
    final room = (c.room ?? '').trim();
    final titleOrCode = title.isNotEmpty ? title : code;
    final hasRoom = room.isNotEmpty;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = c.day == now.weekday;

    final startTime = _parseTime(c.start);
    final endTime = _parseTime(c.end);

    final start = DateTime(
      today.year,
      today.month,
      today.day,
      startTime.hour,
      startTime.minute,
    );

    var end = DateTime(
      today.year,
      today.month,
      today.day,
      endTime.hour,
      endTime.minute,
    );
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    final isOngoing = isToday && !start.isAfter(now) && end.isAfter(now);
    final isPast = isToday && end.isBefore(now);

    String? statusLabel;
    IconData? statusIcon;
    Color statusForeground = colors.onSurfaceVariant;
    Color statusBackground = colors.surfaceContainerHigh;

    if (isPast) {
      statusLabel = 'Done';
      statusIcon = Icons.check_rounded;
      statusForeground = colors.tertiary;
      statusBackground = colors.tertiary.withValues(alpha: 0.16);
    } else if (isOngoing) {
      statusLabel = 'In progress';
      statusIcon = Icons.play_arrow_rounded;
      statusForeground = colors.primary;
      statusBackground = colors.primary.withValues(alpha: 0.16);
    } else if (isActive && !isPast) {
      // If it's the active class but not ongoing (so it must be next), show "Next"
      // Wait, the requirement is just "blue thing" (highlight).
      // The dashboard shows "Next" chip for highlighted future classes.
      // Let's match that.
      statusLabel = 'Next';
      statusIcon = Icons.arrow_forward_rounded;
      statusForeground = colors.primary;
      statusBackground = colors.primary.withValues(alpha: 0.12);
    }

    final background = isActive
        ? colors.primary.withValues(alpha: 0.08)
        : Colors.transparent;
    final border = isActive
        ? colors.primary.withValues(alpha: 0.24)
        : Colors.transparent;

    return Dismissible(
      key: ValueKey(
          '${c.isCustom == true ? 'C' : 'B'}-${c.day}-${c.start}-${c.end}-$titleOrCode-$room'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: colors.error,
        child: Icon(Icons.delete, color: colors.onError),
      ),
      confirmDismiss: (_) async {
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete class?'),
            content: Text(
              c.isCustom == true
                  ? 'This custom class will be removed.'
                  : 'This class will be removed from your view.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        return ok ?? false;
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppTokens.radius.md,
          border: Border.all(color: border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (c.isCustom == true)
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Switch.adaptive(
                                value: c.enabled,
                                onChanged: onToggle,
                                thumbColor: WidgetStateProperty.resolveWith(
                                  (states) => colors.primary,
                                ),
                                trackColor: WidgetStateProperty.resolveWith(
                                  (states) => colors.primary.withValues(
                                      alpha:
                                          states.contains(WidgetState.selected)
                                              ? 0.35
                                              : 0.18),
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              titleOrCode.isEmpty ? 'Class' : titleOrCode,
                              style: textTheme.titleMedium?.copyWith(
                                fontSize: AppTokens.typography.body.fontSize,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          if (statusLabel != null) ...[
                            SizedBox(width: AppTokens.spacing.sm),
                            StatusChip(
                              icon: statusIcon!,
                              label: statusLabel,
                              background: statusBackground,
                              foreground: statusForeground,
                              compact: true,
                            ),
                          ],
                          if (c.isCustom == true && onEdit != null)
                              IconButton(
                                icon: Icon(
                                  Icons.edit_outlined,
                                  size: AppTokens.iconSize.sm,
                                  color: colors.primary,
                                ),
                                onPressed: () => onEdit!(c),
                              ),
                        ],
                      ),
                      SizedBox(height: AppTokens.spacing.xs),
                      Text(
                        _range(c.start, c.end),
                        style: textTheme.bodySmall?.copyWith(color: muted),
                      ),
                      if (hasRoom)
                        Text(
                          room,
                          style: textTheme.bodySmall?.copyWith(color: muted),
                        ),
                    ],
                  ),
                ),
                if (c.isCustom != true)
                  Switch.adaptive(
                    value: c.enabled,
                    onChanged: onToggle,
                    thumbColor: WidgetStateProperty.resolveWith(
                      (states) => colors.primary,
                    ),
                    trackColor: WidgetStateProperty.resolveWith(
                      (states) => colors.primary.withValues(
                          alpha: states.contains(WidgetState.selected)
                              ? 0.35
                              : 0.18),
                    ),
                  ),
              ],
            ),
            if (showDivider)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  color: colors.outline.withValues(alpha: 0.25),
                ),
              ),
          ],
        ),
      ),
    );
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
