import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/scan_service.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/card_styles.dart';
import '../ui/theme/tokens.dart';
import '../widgets/instructor_avatar.dart';

class ScheduleImportOutcome {
  const ScheduleImportOutcome({this.imported = false, this.retake = false});

  const ScheduleImportOutcome.imported()
      : imported = true,
        retake = false;

  const ScheduleImportOutcome.retake()
      : imported = false,
        retake = true;

  final bool imported;
  final bool retake;
}

class SchedulesPreviewSheet extends StatefulWidget {
  const SchedulesPreviewSheet({
    super.key,
    required this.imagePath,
    required this.section,
    required this.classes,
  });

  final String imagePath;
  final Map<String, dynamic> section;
  final List<Map<String, dynamic>> classes;

  @override
  State<SchedulesPreviewSheet> createState() => _SchedulesPreviewSheetState();
}

class _SchedulesPreviewSheetState extends State<SchedulesPreviewSheet> {
  final ScanService _service = ScanService();
  late final Map<int, bool> _enabled;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _enabled = {
      for (final item in widget.classes)
        (item['id'] as num).toInt():
            (item['enabled'] is bool) ? item['enabled'] as bool : true,
    };
  }

  Future<void> _proceed() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final sectionId = (widget.section['id'] as num?)?.toInt();
      if (sectionId != null) {
        await _service.importSectionSchedule(
          sectionId: sectionId,
          enabledMap: _enabled,
        );
      } else {
        await _service.importAsCustomSchedule(
          rows: widget.classes,
          enabledMap: _enabled,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(const ScheduleImportOutcome.imported());
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = AppTokens.spacing;
    final media = MediaQuery.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final code = (widget.section['code'] ?? '').toString();

    final grouped = _groupByDay(widget.classes);
    final dayKeys = grouped.keys.toList()..sort();
    final importGroups = <int, List<_ImportClass>>{};
    for (final day in dayKeys) {
      final rows = List<Map<String, dynamic>>.from(grouped[day]!);
      rows.sort((a, b) {
        final aStart = _minutesFromText((a['start'] ?? '').toString()) ?? 0;
        final bStart = _minutesFromText((b['start'] ?? '').toString()) ?? 0;
        return aStart.compareTo(bStart);
      });
      importGroups[day] = [
        for (final cls in rows)
          _ImportClass(
            id: (cls['id'] as num).toInt(),
            title: (cls['title'] ?? cls['code'] ?? 'Class').toString().trim(),
            startLabel: (cls['start'] ?? '').toString(),
            endLabel: (cls['end'] ?? '').toString(),
            room: (cls['room'] ?? '').toString(),
            instructor: (cls['instructor'] ?? '').toString(),
            day: (cls['day'] as num?)?.toInt() ?? 1,
            instructorAvatar:
                (cls['instructor_avatar'] ?? cls['avatar_url'] ?? '')
                    .toString(),
          ),
      ];
    }
    final highlightClassId = _findNextHighlightedImport(
      importGroups.values.expand((list) => list),
      _enabled,
      DateTime.now(),
    );

    final cardBackground = elevatedCardBackground(theme, solid: true);
    final borderColor = elevatedCardBorder(theme, solid: true);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: media.size.height * 0.86,
          ),
          child: Container(
            margin: EdgeInsets.fromLTRB(
              spacing.xl,
              media.padding.top + spacing.xl,
              spacing.xl,
              media.padding.bottom + viewInsets.bottom + spacing.xl,
            ),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: AppTokens.radius.xl,
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.35 : 0.18,
                  ),
                  blurRadius: 28,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  spacing.xl,
                  spacing.xl,
                  spacing.xl,
                  spacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ImportHeader(
                      helper:
                          'Toggle classes you want to keep before adding them to MySched.',
                      onClose: () => Navigator.of(context).pop(),
                    ),
                    SizedBox(height: spacing.lg),
                    _SectionCard(
                      title: 'Section $code',
                      subtitle: _sectionDetails(),
                      icon: Icons.event_note_rounded,
                    ),
                    if (_error != null) ...[
                      SizedBox(height: spacing.lg),
                      ErrorState(
                        title: 'Import failed',
                        message: _error!,
                      ),
                    ],
                    SizedBox(height: spacing.lg),
                    for (final day in dayKeys) ...[
                      _DayToggleCard(
                        dayLabel: _dayName(day),
                        entries: importGroups[day] ?? const [],
                        enabledMap: _enabled,
                        saving: _saving,
                        highlightClassId: highlightClassId,
                        onToggle: (classId, value) {
                          setState(() => _enabled[classId] = value);
                        },
                      ),
                      SizedBox(height: spacing.lg),
                    ],
                    FilledButton(
                      onPressed: _saving ? null : _proceed,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTokens.radius.xl,
                        ),
                      ),
                      child: Text(_saving ? 'Saving...' : 'Import schedule'),
                    ),
                    SizedBox(height: spacing.md),
                    OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context)
                              .pop(const ScheduleImportOutcome.retake()),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTokens.radius.xl,
                        ),
                      ),
                      child: const Text('Retake'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _sectionDetails() {
    final parts = [
      widget.section['department'],
      widget.section['campus'],
    ]
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    return parts.join(' / ');
  }

  Map<int, List<Map<String, dynamic>>> _groupByDay(
      List<Map<String, dynamic>> rows) {
    final grouped = <int, List<Map<String, dynamic>>>{};
    for (final row in rows) {
      final day = (row['day'] as num?)?.toInt() ?? 1;
      (grouped[day] ??= []).add(row);
    }
    return grouped;
  }

  String _dayName(int day) {
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
    return 'Unknown';
  }
}

class _ImportHeader extends StatelessWidget {
  const _ImportHeader({
    required this.helper,
    required this.onClose,
  });

  final String helper;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: onClose,
            ),
            Expanded(
              child: Text(
                'Import schedule',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        SizedBox(height: spacing.xs),
        Text(
          helper,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    return CardX(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      backgroundColor: colors.surfaceContainerHighest.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.6 : 0.95,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.15),
              borderRadius: AppTokens.radius.lg,
            ),
            child: Icon(icon, color: colors.primary),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportClass {
  const _ImportClass({
    required this.id,
    required this.title,
    required this.startLabel,
    required this.endLabel,
    required this.room,
    required this.instructor,
    required this.day,
    this.instructorAvatar,
  });

  final int id;
  final String title;
  final String startLabel;
  final String endLabel;
  final String room;
  final String instructor;
  final int day;
  final String? instructorAvatar;
}

class _ImportDatePill extends StatelessWidget {
  const _ImportDatePill({
    required this.dayLabel,
    required this.dateLabel,
    required this.accent,
    this.labelColor,
  });

  final String? dayLabel;
  final String? dateLabel;
  final Color accent;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = accent.withValues(alpha: 0.2);
    final dayTextColor =
        labelColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            (dayLabel ?? '').isEmpty ? 'DAY' : dayLabel!,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: dayTextColor,
              letterSpacing: 0.8,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            (dateLabel ?? '').isEmpty ? '--' : dateLabel!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportLeadBadge extends StatelessWidget {
  const _ImportLeadBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = color.withValues(alpha: isDark ? 0.28 : 0.16);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }
}

class _ImportInstructorRow extends StatelessWidget {
  const _ImportInstructorRow({
    required this.name,
    required this.tint,
    this.avatarUrl,
  });

  final String name;
  final Color tint;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        InstructorAvatar(
          name: name,
          tint: tint,
          avatarUrl: avatarUrl,
          size: 26,
          borderWidth: 1,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

int? _findNextHighlightedImport(
  Iterable<_ImportClass> entries,
  Map<int, bool> enabledMap,
  DateTime now,
) {
  DateTime? bestStart;
  int? bestId;
  for (final entry in entries) {
    if (!(enabledMap[entry.id] ?? true)) continue;
    final nextStart = _nextInstanceForImport(entry, now);
    if (nextStart == null) continue;
    if (bestStart == null || nextStart.isBefore(bestStart)) {
      bestStart = nextStart;
      bestId = entry.id;
    }
  }
  return bestId;
}

DateTime? _nextInstanceForImport(_ImportClass entry, DateTime now) {
  final baseDate = _nextDateForDay(entry.day, now);
  final minutes = _minutesFromText(entry.startLabel);
  if (baseDate == null || minutes == null) return null;
  var nextStart = DateTime(
    baseDate.year,
    baseDate.month,
    baseDate.day,
  ).add(Duration(minutes: minutes));
  if (!nextStart.isAfter(now)) {
    nextStart = nextStart.add(const Duration(days: 7));
  }
  return nextStart;
}

DateTime? _nextDateForDay(int day, DateTime now) {
  if (day < 1 || day > 7) return null;
  final today = DateTime(now.year, now.month, now.day);
  var diff = day - today.weekday;
  if (diff < 0) diff += 7;
  return today.add(Duration(days: diff));
}

String _weekdayAbbrev(int day) {
  const names = ['', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  if (day >= 1 && day <= 7) return names[day];
  return 'DAY';
}

String? _formatRange(String start, String end) {
  final startLabel = _formatTimeLabel(start);
  final endLabel = _formatTimeLabel(end);
  if (startLabel != null && endLabel != null) {
    return '$startLabel - $endLabel';
  }
  return startLabel ?? endLabel;
}

String? _formatTimeLabel(String raw) {
  final minutes = _minutesFromText(raw);
  if (minutes == null) return null;
  final date = _timeFromMinutes(minutes);
  return DateFormat('h:mm a').format(date).replaceAll('\u202f', ' ');
}

int? _minutesFromText(String raw) {
  final value = raw.trim().toLowerCase().replaceAll('.', '');
  if (value.isEmpty) return null;

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

DateTime _timeFromMinutes(int minutes) {
  final hour = minutes ~/ 60;
  final minute = minutes % 60;
  return DateTime(2020, 1, 1, hour, minute);
}

class _DayToggleCard extends StatelessWidget {
  const _DayToggleCard({
    required this.dayLabel,
    required this.entries,
    required this.enabledMap,
    required this.saving,
    required this.highlightClassId,
    required this.onToggle,
  });

  final String dayLabel;
  final List<_ImportClass> entries;
  final Map<int, bool> enabledMap;
  final bool saving;
  final int? highlightClassId;
  final void Function(int classId, bool value) onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    return CardX(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      backgroundColor: colors.surfaceContainerHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: spacing.md),
          for (final entry in entries)
            Padding(
              padding: EdgeInsets.only(
                bottom: entry == entries.last ? 0 : spacing.sm,
              ),
              child: _ImportClassTile(
                entry: entry,
                enabled: enabledMap[entry.id] ?? true,
                saving: saving,
                highlight: highlightClassId == entry.id,
                onToggle: (value) => onToggle(entry.id, value),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImportClassTile extends StatelessWidget {
  const _ImportClassTile({
    required this.entry,
    required this.enabled,
    required this.saving,
    this.highlight = false,
    required this.onToggle,
  });

  final _ImportClass entry;
  final bool enabled;
  final bool saving;
  final bool highlight;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final now = DateTime.now();
    final disabled = !enabled;
    final bool isHighlighted = highlight && !disabled;
    final nextDate = _nextDateForDay(entry.day, now);
    final dayLabel = nextDate == null
        ? _weekdayAbbrev(entry.day)
        : DateFormat('EEE').format(nextDate).toUpperCase();
    final dateLabel =
        nextDate == null ? null : DateFormat('MMM d').format(nextDate);
    final timeLabel = _formatRange(entry.startLabel, entry.endLabel);
    final location = entry.room.trim();
    final instructor = entry.instructor.trim();

    final containerColor = disabled
        ? colors.error.withValues(alpha: 0.08)
        : isHighlighted
            ? colors.primary.withValues(alpha: 0.08)
            : colors.surfaceContainerHigh;
    final borderColor = disabled
        ? colors.error.withValues(alpha: 0.3)
        : isHighlighted
            ? colors.primary.withValues(alpha: 0.24)
            : colors.outline.withValues(alpha: 0.12);
    final titleColor = disabled
        ? colors.onSurfaceVariant.withValues(alpha: 0.7)
        : colors.onSurface;
    final capsuleColor = disabled
        ? colors.error.withValues(alpha: 0.12)
        : colors.primary.withValues(alpha: 0.14);
    final capsuleTextColor = disabled ? colors.error : colors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: AppTokens.radius.lg,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isHighlighted) ...[
                _ImportLeadBadge(
                  label: 'Next',
                  color: colors.primary,
                ),
                const SizedBox(height: 6),
              ],
              _ImportDatePill(
                dayLabel: dayLabel,
                dateLabel: dateLabel,
                accent: capsuleColor,
                labelColor: capsuleTextColor,
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title.isEmpty ? 'Untitled class' : entry.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (timeLabel != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    timeLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                ],
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                if (instructor.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _ImportInstructorRow(
                    name: instructor,
                    tint: colors.primary,
                    avatarUrl: entry.instructorAvatar,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: enabled,
            onChanged: saving ? null : onToggle,
          ),
        ],
      ),
    );
  }
}
