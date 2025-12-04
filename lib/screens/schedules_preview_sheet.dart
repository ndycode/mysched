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
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final media = MediaQuery.of(context);
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
            maxHeight: media.size.height * 0.78,
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: spacing.xl),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.surfaceContainerHigh
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? theme.colorScheme.outline.withValues(alpha: 0.12)
                    : const Color(0xFFE5E5E5),
                width: theme.brightness == Brightness.dark ? 1 : 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        spacing.xl,
                        spacing.xl,
                        spacing.xl,
                        spacing.lg,
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
                            StateDisplay(
                              variant: StateVariant.error,
                              title: 'Import failed',
                              message: _error!,
                              primaryActionLabel: 'Retry import',
                              onPrimaryAction: _saving ? null : _proceed,
                              secondaryActionLabel: 'Retake',
                              onSecondaryAction: _saving
                                  ? null
                                  : () => Navigator.of(context)
                                      .pop(const ScheduleImportOutcome.retake()),
                              compact: true,
                            ),
                          ],
                          SizedBox(height: spacing.lg),
                          Container(
                            padding: spacing.edgeInsetsAll(spacing.xl),
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? colors.surfaceContainerHighest.withValues(alpha: 0.3)
                                  : colors.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: AppTokens.radius.xl,
                              border: Border.all(
                                color: colors.outlineVariant.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                for (var i = 0; i < dayKeys.length; i++) ...[
                                  _DayToggleCard(
                                    dayLabel: _dayName(dayKeys[i]),
                                    entries: importGroups[dayKeys[i]] ?? const [],
                                    enabledMap: _enabled,
                                    saving: _saving,
                                    highlightClassId: highlightClassId,
                                    onToggle: (classId, value) {
                                      setState(() => _enabled[classId] = value);
                                    },
                                  ),
                                  if (i != dayKeys.length - 1) SizedBox(height: spacing.quad),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Sticky buttons at bottom
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      spacing.xl,
                      spacing.md,
                      spacing.xl,
                      spacing.xl,
                    ),
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.only(
                        bottomLeft: AppTokens.radius.xl.bottomLeft,
                        bottomRight: AppTokens.radius.xl.bottomRight,
                      ),
                      border: Border(
                        top: BorderSide(
                          color: borderColor.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            onPressed: _saving ? null : _proceed,
                            label: _saving ? 'Saving...' : 'Import schedule',
                            leading: _saving
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colors.onPrimary,
                                      ),
                                    ),
                                  )
                                : null,
                            minHeight: 48,
                          ),
                        ),
                        SizedBox(width: spacing.md),
                        Expanded(
                          child: SecondaryButton(
                            onPressed: _saving
                                ? null
                                : () => Navigator.of(context)
                                    .pop(const ScheduleImportOutcome.retake()),
                            label: 'Retake',
                            minHeight: 48,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
            PressableScale(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: AppTokens.radius.xl,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: colors.primary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Import schedule',
                textAlign: TextAlign.center,
                style: AppTokens.typography.title.copyWith(
                  color: colors.onSurface,
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
        alpha: theme.brightness == Brightness.dark ? 0.3 : 0.5,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header matching schedules page
        Text(
          dayLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: colors.primary,
          ),
        ),
        SizedBox(height: spacing.xs + 2),
        Container(
          height: 1,
          decoration: BoxDecoration(
            color: colors.outlineVariant.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.24 : 0.12,
            ),
            borderRadius: AppTokens.radius.pill,
          ),
        ),
        SizedBox(height: spacing.md),
        // Class tiles
        for (final entry in entries)
          Padding(
            padding: EdgeInsets.only(
              bottom: entry == entries.last ? 0 : spacing.md,
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
    final spacing = AppTokens.spacing;
    final now = DateTime.now();
    final disabled = !enabled;
    final bool isNext = highlight && !disabled;
    final nextDate = _nextDateForDay(entry.day, now);
    
    final dayLabel = nextDate == null
        ? _weekdayAbbrev(entry.day)
        : DateFormat('EEE').format(nextDate).toUpperCase();
    final dateLabel =
        nextDate == null ? '--' : DateFormat('MMM d').format(nextDate);
        
    final timeLabel = _formatRange(entry.startLabel, entry.endLabel);
    final location = entry.room.trim();
    final instructor = entry.instructor.trim();
    final instructorAvatar = entry.instructorAvatar?.trim() ?? '';

    // Match schedules page design
    final tileBackground = isNext
        ? colors.primary.withValues(alpha: 0.08)
        : colors.surfaceContainerHigh;
    final tileBorder = isNext
        ? colors.primary.withValues(alpha: 0.24)
        : colors.outline.withValues(alpha: 0.12);
    final radius = AppTokens.radius.lg;

    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.lg + 2,
        vertical: spacing.lg,
      ),
      decoration: BoxDecoration(
        color: tileBackground,
        borderRadius: radius,
        border: Border.all(color: tileBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day/date column - matches schedules page
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: disabled ? colors.error : colors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with next badge and toggle
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        entry.title.isEmpty ? 'Untitled class' : entry.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          decoration: disabled ? TextDecoration.lineThrough : null,
                          color: disabled ? colors.onSurface.withValues(alpha: 0.5) : null,
                        ),
                      ),
                    ),
                    if (isNext) ...[
                      SizedBox(width: spacing.xs),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.sm,
                          vertical: spacing.xs - 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: AppTokens.radius.pill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 13,
                              color: colors.primary,
                            ),
                            SizedBox(width: spacing.xs - 2),
                            Text(
                              'Next',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: colors.primary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(width: spacing.sm),
                    Transform.scale(
                      scale: 0.82,
                      alignment: Alignment.centerRight,
                      child: Switch.adaptive(
                        value: !disabled,
                        onChanged: saving ? null : onToggle,
                        activeTrackColor: colors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                if (timeLabel != null) ...[
                  SizedBox(height: spacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 15,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.82),
                      ),
                      SizedBox(width: spacing.xs),
                      Text(
                        timeLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                ],
                if (location.isNotEmpty) ...[
                  SizedBox(height: spacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 15,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.82),
                      ),
                      SizedBox(width: spacing.xs),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: colors.onSurfaceVariant.withValues(alpha: 0.92),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (instructor.isNotEmpty) ...[
                  SizedBox(height: spacing.sm),
                  _ImportInstructorRow(
                    name: instructor,
                    tint: colors.primary,
                    avatarUrl: instructorAvatar.isEmpty ? null : instructorAvatar,
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
