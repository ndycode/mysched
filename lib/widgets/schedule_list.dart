// lib/widgets/schedule_list.dart
import 'package:flutter/material.dart';
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
          const SizedBox(height: 12),
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
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final Future<void> Function(ClassItem)? onEdit;

  const _Row({
    required this.c,
    required this.showDivider,
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

    return Dismissible(
      key: ValueKey(
          '${c.isCustom == true ? 'C' : 'B'}-${c.day}-${c.start}-${c.end}-$titleOrCode-$room'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: colors.error,
        child: const Icon(Icons.delete, color: Colors.white),
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
      child: Padding(
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
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          if (c.isCustom == true && onEdit != null)
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: colors.primary,
                              ),
                              tooltip: 'Edit class',
                              onPressed: () => onEdit!(c),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
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
