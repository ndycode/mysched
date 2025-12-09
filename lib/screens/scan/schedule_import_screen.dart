import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/scan_service.dart';
import '../../ui/kit/kit.dart';
import '../../ui/semester_badge.dart';
import '../../ui/theme/card_styles.dart';
import '../../ui/theme/tokens.dart';

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
    final borderWidth = elevatedCardBorderWidth(theme);
    final isDark = theme.brightness == Brightness.dark;
    final maxHeight = media.size.height * AppLayout.sheetMaxHeightRatio;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: spacing.xl,
          right: spacing.xl,
          bottom: media.viewInsets.bottom + spacing.xl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppLayout.sheetMaxWidth,
              maxHeight: maxHeight,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: AppTokens.radius.xl,
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        AppTokens.shadow.modal(
                          colors.shadow.withValues(alpha: AppOpacity.border),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: AppTokens.radius.xl,
                child: Material(
                  type: MaterialType.transparency,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: spacing.edgeInsetsOnly(
                          left: spacing.xl,
                          right: spacing.xl,
                          top: spacing.xl,
                          bottom: spacing.md,
                        ),
                        child: SheetHeaderRow(
                          title: 'Import schedule',
                          subtitle:
                              'Toggle classes you want to keep before adding them to MySched.',
                          icon: Icons.download_rounded,
                          onClose: () => Navigator.of(context).pop(),
                        ),
                      ),
                      // Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: spacing.edgeInsetsOnly(
                            left: spacing.xl,
                            right: spacing.xl,
                            bottom: spacing.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Section and Semester context badges
                              const SemesterBadge(compact: true),
                              SizedBox(height: spacing.md),
                              if (_error != null) ...[
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
                                SizedBox(height: spacing.lg),
                              ],
                              // Class list
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
                      // Action buttons
                      Container(
                        padding: spacing.edgeInsetsOnly(
                          left: spacing.xl,
                          right: spacing.xl,
                          top: spacing.md,
                          bottom: spacing.xl,
                        ),
                        decoration: BoxDecoration(
                          color: cardBackground,
                          border: Border(
                            top: BorderSide(
                              color: isDark
                                  ? colors.outline
                                      .withValues(alpha: AppOpacity.overlay)
                                  : colors.outlineVariant
                                      .withValues(alpha: AppOpacity.ghost),
                              width: AppTokens.componentSize.dividerThin,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                label: _saving
                                    ? 'Importing...'
                                    : 'Import schedule',
                                onPressed: _saving ? null : _proceed,
                                leading: _saving
                                    ? SizedBox(
                                        width: AppTokens.componentSize.badgeMd,
                                        height: AppTokens.componentSize.badgeMd,
                                        child: CircularProgressIndicator(
                                          strokeWidth: AppTokens
                                              .componentSize.progressStroke,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
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
                                label: 'Retake',
                                onPressed: _saving
                                    ? null
                                    : () => Navigator.of(context).pop(
                                        const ScheduleImportOutcome.retake()),
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
        ),
      ),
    );
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
                    horizontal: spacing.sm + AppTokens.spacing.micro,
                    vertical: spacing.xs + AppTokens.spacing.microHalf),
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
          if (i != entries.length - 1)
            SizedBox(height: spacing.sm + AppTokens.spacing.micro),
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
    final disabled = !enabled;
    final bool isNext = highlight && !disabled;

    final timeLabel = _formatRange(entry.startLabel, entry.endLabel);
    final location = entry.room.trim();
    final instructor = entry.instructor.trim();
    final instructorAvatar = entry.instructorAvatar?.trim() ?? '';
    final subject = entry.title.isEmpty ? 'Untitled class' : entry.title;

    // Build metadata items - same as ScheduleRow
    final metadata = <MetadataItem>[
      MetadataItem(icon: Icons.access_time_rounded, label: timeLabel ?? '--'),
      if (location.isNotEmpty)
        MetadataItem(
          icon: Icons.location_on_outlined,
          label: location,
          expanded: true,
        ),
    ];

    // Build status badge - same as ScheduleRow
    StatusBadge? badge;
    if (isNext) {
      badge = StatusBadge(
        label: StatusBadgeVariant.next.label,
        variant: StatusBadgeVariant.next,
      );
    }

    // Build trailing toggle - same as ScheduleRow
    final trailing = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {}, // Absorb tap to prevent row tap
      child: AppSwitch(
        value: !disabled,
        onChanged: saving ? null : onToggle,
        showDangerWhenOff: true,
      ),
    );

    // Use EntityTile - same as ScheduleRow
    return EntityTile(
      title: subject,
      isActive: !disabled,
      isStrikethrough: disabled,
      isHighlighted: isNext,
      tags: const [], // No custom tag for imports
      metadata: metadata,
      badge: badge,
      trailing: trailing,
      bottomContent: instructor.isNotEmpty
          ? InstructorRow(
              name: instructor,
              avatarUrl: instructorAvatar.isNotEmpty ? instructorAvatar : null,
            )
          : null,
    );
  }
}
