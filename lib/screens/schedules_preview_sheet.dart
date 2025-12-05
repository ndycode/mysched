import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/scan_service.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/card_styles.dart';
import '../ui/theme/tokens.dart';

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
            maxWidth: AppLayout.sheetMaxWidth,
            maxHeight: media.size.height * AppLayout.sheetMaxHeightRatio,
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: spacing.xl),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.surfaceContainerHigh
                  : theme.colorScheme.surface,
              borderRadius: AppTokens.radius.xxl,
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? theme.colorScheme.outline.withValues(alpha: AppOpacity.overlay)
                    : theme.colorScheme.outline,
                width: theme.brightness == Brightness.dark ? 1 : 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: AppOpacity.medium),
                  blurRadius: AppTokens.shadow.xxl,
                  offset: AppShadowOffset.modal,
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
                                  : () => Navigator.of(context).pop(
                                      const ScheduleImportOutcome.retake()),
                              compact: true,
                            ),
                          ],
                          SizedBox(height: spacing.xl),
                          // Class list - no extra container, matches schedules page
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
                            if (i != dayKeys.length - 1)
                              SizedBox(height: spacing.xl),
                          ],
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
                          color: borderColor.withValues(alpha: AppOpacity.subtle),
                          width: AppTokens.componentSize.divider,
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
                                    width: AppTokens.componentSize.badgeMd,
                                    height: AppTokens.componentSize.badgeMd,
                                    child: CircularProgressIndicator(
                                      strokeWidth: AppTokens.componentSize.progressStroke,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colors.onPrimary,
                                      ),
                                    ),
                                  )
                                : null,
                            minHeight: AppTokens.componentSize.buttonMd,
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
                            minHeight: AppTokens.componentSize.buttonMd,
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
                padding: spacing.edgeInsetsAll(spacing.sm),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: AppOpacity.highlight),
                  borderRadius: AppTokens.radius.xl,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: AppTokens.iconSize.sm,
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
            SizedBox(width: AppTokens.spacing.quad),
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
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.xl,
        vertical: spacing.lg + spacing.xs / 2,
      ),
      backgroundColor: colors.surfaceContainerHighest.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.3 : 0.5,
      ),
      child: Row(
        children: [
          Container(
            width: AppTokens.componentSize.avatarXxl,
            height: AppTokens.componentSize.avatarXxl,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: AppOpacity.medium),
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
                    fontWeight: AppTokens.fontWeight.bold,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: spacing.xs),
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
        // Day Header - Premium redesign matching schedules page
        Container(
          padding: spacing.edgeInsetsAll(spacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary.withValues(alpha: AppOpacity.dim),
                colors.primary.withValues(alpha: AppOpacity.veryFaint),
              ],
            ),
            borderRadius: AppTokens.radius.md,
            border: Border.all(
              color: colors.primary.withValues(alpha: AppOpacity.accent),
              width: AppTokens.componentSize.divider,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: spacing.edgeInsetsAll(spacing.sm),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: AppOpacity.medium),
                  borderRadius: AppTokens.radius.sm,
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: AppTokens.iconSize.sm,
                  color: colors.primary,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Text(
                  dayLabel,
                  style: AppTokens.typography.subtitle.copyWith(
                    fontWeight: AppTokens.fontWeight.extraBold,
                    letterSpacing: AppLetterSpacing.snug,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Container(
                padding: spacing.edgeInsetsSymmetric(
                    horizontal: spacing.sm + 2, vertical: spacing.xs + 1),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: AppOpacity.overlay),
                  borderRadius: AppTokens.radius.sm,
                ),
                child: Text(
                  '${entries.length} ${entries.length == 1 ? 'class' : 'classes'}',
                  style: AppTokens.typography.caption.copyWith(
                    fontWeight: AppTokens.fontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.md),
        // Class tiles
        for (var i = 0; i < entries.length; i++) ...[
          _ImportClassTile(
            entry: entries[i],
            enabled: enabledMap[entries[i].id] ?? true,
            saving: saving,
            highlight: highlightClassId == entries[i].id,
            onToggle: (value) => onToggle(entries[i].id, value),
          ),
          if (i != entries.length - 1) SizedBox(height: spacing.sm + 2),
        ],
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
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;
    final disabled = !enabled;
    final bool isNext = highlight && !disabled;

    final timeLabel = _formatRange(entry.startLabel, entry.endLabel);
    final location = entry.room.trim();
    final instructor = entry.instructor.trim();
    final instructorAvatar = entry.instructorAvatar?.trim() ?? '';
    final subject = entry.title.isEmpty ? 'Untitled class' : entry.title;

    // Match ScheduleRow design exactly
    return Container(
      padding: spacing.edgeInsetsAll(spacing.lg),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.md,
        border: Border.all(
          color: isNext
              ? colors.primary.withValues(alpha: AppOpacity.ghost)
              : colors.outline.withValues(alpha: isDark ? AppOpacity.overlay : AppOpacity.subtle),
          width: isNext ? 1.5 : 0.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: isNext ? 0.08 : 0.04),
                  blurRadius: isNext ? 12 : 6,
                  offset: AppShadowOffset.xs,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Title and Toggle
          Row(
            children: [
              Expanded(
                child: Text(
                  subject,
                  style: AppTokens.typography.subtitle.copyWith(
                    fontWeight: AppTokens.fontWeight.bold,
                    letterSpacing: AppLetterSpacing.compact,
                    color:
                        disabled ? colors.onSurfaceVariant : colors.onSurface,
                    decoration: disabled ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: spacing.md),
              // Status badge or toggle
              if (isNext)
                Container(
                  padding: spacing.edgeInsetsSymmetric(
                      horizontal: spacing.sm + 2, vertical: spacing.xs),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: AppOpacity.highlight),
                    borderRadius: AppTokens.radius.sm,
                  ),
                  child: Text(
                    'Next',
                    style: AppTokens.typography.caption.copyWith(
                      fontWeight: AppTokens.fontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                )
              else
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: !disabled,
                    onChanged: saving ? null : onToggle,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.md),
          // Bottom row: Time, Location
          Row(
            children: [
              // Time
              Icon(
                Icons.access_time_rounded,
                size: AppTokens.iconSize.sm,
                color: colors.onSurfaceVariant,
              ),
              SizedBox(width: spacing.xs + 2),
              Text(
                timeLabel ?? '--',
                style: AppTokens.typography.bodySecondary.copyWith(
                  fontWeight: AppTokens.fontWeight.medium,
                  color: colors.onSurfaceVariant,
                ),
              ),
              if (location.isNotEmpty) ...[
                SizedBox(width: spacing.lg),
                Icon(
                  Icons.location_on_outlined,
                  size: AppTokens.iconSize.sm,
                  color: colors.onSurfaceVariant,
                ),
                SizedBox(width: spacing.xs + 2),
                Expanded(
                  child: Text(
                    location,
                    style: AppTokens.typography.bodySecondary.copyWith(
                      fontWeight: AppTokens.fontWeight.medium,
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          if (instructor.isNotEmpty) ...[
            SizedBox(height: spacing.sm + 2),
            Row(
              children: [
                if (instructorAvatar.isNotEmpty)
                  Container(
                    width: AppTokens.componentSize.badgeLg,
                    height: AppTokens.componentSize.badgeLg,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(instructorAvatar),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    width: AppTokens.componentSize.badgeLg,
                    height: AppTokens.componentSize.badgeLg,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: AppOpacity.medium),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        instructor[0].toUpperCase(),
                        style: AppTokens.typography.caption.copyWith(
                          fontWeight: AppTokens.fontWeight.semiBold,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    instructor,
                    style: AppTokens.typography.caption.copyWith(
                      fontWeight: AppTokens.fontWeight.medium,
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
