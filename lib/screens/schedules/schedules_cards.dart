// ignore_for_file: unused_local_variable, unused_element
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../services/schedule_api.dart' as sched;
import '../../ui/kit/kit.dart';
import '../../ui/theme/card_styles.dart';
import '../../ui/theme/tokens.dart';
import '../../widgets/instructor_avatar.dart';
import 'schedules_data.dart';

/// Unified card container for the class list - matches dashboard style.
class ScheduleClassListCard extends StatelessWidget {
  const ScheduleClassListCard({
    super.key,
    required this.groups,
    required this.now,
    required this.highlightClassId,
    required this.onOpenDetails,
    required this.onToggleEnabled,
    required this.pendingToggleIds,
    this.onDelete,
    this.onRefresh,
    this.refreshing = false,
  });

  final List<DayGroup> groups;
  final DateTime now;
  final int? highlightClassId;
  final void Function(sched.ClassItem item) onOpenDetails;
  final void Function(sched.ClassItem item, bool enable) onToggleEnabled;
  final Set<int> pendingToggleIds;
  final Future<void> Function(int id)? onDelete;
  final Future<void> Function()? onRefresh;
  final bool refreshing;

  // Helper functions for time calculations
  static int _minutesFromText(String text) {
    final cleaned = text.trim().toLowerCase().replaceAll('.', '');
    var meridian = '';
    var payload = cleaned;
    if (payload.endsWith('am') || payload.endsWith('pm')) {
      meridian = payload.substring(payload.length - 2);
      payload = payload.substring(0, payload.length - 2).trim();
    }
    int hour;
    int minute;
    if (payload.contains(':')) {
      final parts = payload.split(':').map((part) => part.trim()).toList();
      hour = int.tryParse(parts[0]) ?? 0;
      minute = parts.length >= 2 ? int.tryParse(parts[1]) ?? 0 : 0;
    } else {
      hour = int.tryParse(payload) ?? 0;
      minute = 0;
    }
    if (meridian == 'pm' && hour != 12) hour += 12;
    if (meridian == 'am' && hour == 12) hour = 0;
    hour = hour.clamp(0, 23);
    minute = minute.clamp(0, 59);
    return hour * 60 + minute;
  }

  static DateTime _nextOccurrence(sched.ClassItem item, DateTime now) {
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

  static DateTime _endFor(sched.ClassItem item, DateTime start) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final dateLabel = DateFormat('EEEE, MMM d').format(now);

    final hasClasses = groups.isNotEmpty && groups.any((g) => g.items.isNotEmpty);

    return Container(
      padding: spacing.edgeInsetsAll(spacing.xl),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: isDark ? colors.outline.withValues(alpha: 0.12) : colors.outline,
          width: isDark ? 1 : 0.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Enhanced
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary.withValues(alpha: 0.15),
                      colors.primary.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: AppTokens.radius.md,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: colors.primary,
                  size: AppTokens.iconSize.xl,
                ),
              ),
              SizedBox(width: spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Schedule',
                      style: AppTokens.typography.title.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      dateLabel,
                      style: AppTokens.typography.bodySecondary.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onRefresh != null) ...[ 
                SizedBox(
                  height: 36,
                  width: 36,
                  child: IconButton(
                    onPressed: refreshing ? null : onRefresh,
                    icon: refreshing
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(colors.primary),
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            color: colors.onSurfaceVariant,
                            size: AppTokens.iconSize.md,
                          ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: spacing.sm),
          Text(
            'Tap a class to view details, enable alarms, or edit reminders.',
            style: AppTokens.typography.caption.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.xl),

          // Class list
          if (!hasClasses) ...[
            Container(
              padding: spacing.edgeInsetsAll(spacing.xxl),
              decoration: BoxDecoration(
                color: isDark ? colors.surfaceContainerHighest.withValues(alpha: 0.4) : colors.primary.withValues(alpha: 0.04),
                borderRadius: AppTokens.radius.lg,
                border: Border.all(
                  color: isDark ? colors.outline.withValues(alpha: 0.12) : colors.primary.withValues(alpha: 0.10),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: spacing.edgeInsetsAll(spacing.lg),
                    decoration: BoxDecoration(
                      color: isDark ? colors.primary.withValues(alpha: 0.15) : colors.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event_available_outlined,
                      size: AppTokens.iconSize.xxl,
                      color: colors.primary,
                    ),
                  ),
                  SizedBox(height: spacing.xl),
                  Text(
                    'No classes scheduled',
                    style: AppTokens.typography.subtitle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing.sm),
                  Text(
                    'Add a class or scan your student card to get started.',
                    style: AppTokens.typography.bodySecondary.copyWith(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            for (var g = 0; g < groups.length; g++) ...[
              if (groups[g].items.isNotEmpty) ...[
                // Day Header - Premium redesign
                Container(
                  padding: spacing.edgeInsetsAll(spacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primary.withValues(alpha: 0.10),
                        colors.primary.withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: AppTokens.radius.md,
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.20),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: spacing.edgeInsetsAll(spacing.sm),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.15),
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
                          groups[g].label,
                          style: AppTokens.typography.subtitle.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: spacing.edgeInsetsSymmetric(horizontal: spacing.sm + 2, vertical: spacing.xs + 1),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: AppTokens.radius.sm,
                        ),
                        child: Text(
                          '${groups[g].items.length} ${groups[g].items.length == 1 ? 'class' : 'classes'}',
                          style: AppTokens.typography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.md),

                // Classes for this day
                for (var i = 0; i < groups[g].items.length; i++) ...[
                  ScheduleRow(
                    item: groups[g].items[i],
                    isLast: i == groups[g].items.length - 1,
                    highlight: highlightClassId == groups[g].items[i].id,
                    onOpenDetails: () => onOpenDetails(groups[g].items[i]),
                    onToggleEnabled: (enable) =>
                        onToggleEnabled(groups[g].items[i], enable),
                    toggleBusy: pendingToggleIds.contains(groups[g].items[i].id),
                    onDelete: onDelete != null
                        ? () => onDelete!(groups[g].items[i].id)
                        : null,
                  ),
                  if (i != groups[g].items.length - 1) SizedBox(height: spacing.sm + 2),
                ],
                if (g != groups.length - 1) SizedBox(height: spacing.xl),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

class ScheduleGroupSliver extends StatelessWidget
    implements ScreenShellSliver {
  const ScheduleGroupSliver({
    super.key,
    required this.header,
    required this.group,
    required this.onOpenDetails,
    required this.onToggleEnabled,
    required this.pendingToggleIds,
    this.highlightClassId,
    this.onDelete,
    this.showHeader = true,
  });

  final Widget header;
  final DayGroup group;
  final void Function(sched.ClassItem item) onOpenDetails;
  final void Function(sched.ClassItem item, bool enable) onToggleEnabled;
  final Future<void> Function(int id)? onDelete;
  final Set<int> pendingToggleIds;
  final int? highlightClassId;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return ScreenStickyGroup(
      header: header,
      child: ScheduleGroupCard(
        group: group,
        onOpenDetails: onOpenDetails,
        onToggleEnabled: onToggleEnabled,
        pendingToggleIds: pendingToggleIds,
        highlightClassId: highlightClassId,
        onDelete: onDelete,
        showHeader: showHeader,
      ),
    );
  }

  @override
  List<Widget> buildSlivers(
    BuildContext context,
    double maxWidth,
    EdgeInsetsGeometry horizontalPadding,
  ) {
    final surface = Theme.of(context).colorScheme.surface;

    return [
      SliverPadding(
        padding: horizontalPadding,
        sliver: SliverPersistentHeader(
          pinned: false,
          delegate: _PinnedHeaderDelegate(
            height: 56,
            maxWidth: maxWidth,
            backgroundColor: surface,
            child: header,
          ),
        ),
      ),
      SliverPadding(
        padding: horizontalPadding,
        sliver: SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ScheduleGroupCard(
                group: group,
                onOpenDetails: onOpenDetails,
                onToggleEnabled: onToggleEnabled,
                pendingToggleIds: pendingToggleIds,
                highlightClassId: highlightClassId,
                onDelete: onDelete,
                showHeader: false,
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

class ScheduleGroupCard extends StatelessWidget {
  const ScheduleGroupCard({
    super.key,
    required this.group,
    required this.onOpenDetails,
    required this.onToggleEnabled,
    required this.pendingToggleIds,
    this.highlightClassId,
    this.onDelete,
    this.showHeader = true,
  });

  final DayGroup group;
  final void Function(sched.ClassItem item) onOpenDetails;
  final void Function(sched.ClassItem item, bool enable) onToggleEnabled;
  final Set<int> pendingToggleIds;
  final int? highlightClassId;
  final Future<void> Function(int id)? onDelete;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final background = elevatedCardBackground(theme, solid: true);
    final borderColor = elevatedCardBorder(theme, solid: true);
    final shadowColor = colors.outline.withValues(alpha: 0.08);
    final spacing = AppTokens.spacing;
    return Container(
      padding: spacing.edgeInsetsAll(spacing.xl),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: theme.brightness == Brightness.dark
            ? const []
            : [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 18,
                  offset: const Offset(0, 14),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Text(
              group.label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: spacing.md + 2),
          ],
          for (var i = 0; i < group.items.length; i++) ...[
            ScheduleRow(
              item: group.items[i],
              isLast: i == group.items.length - 1,
              highlight: highlightClassId == group.items[i].id,
              onOpenDetails: () => onOpenDetails(group.items[i]),
              onToggleEnabled: (enable) =>
                  onToggleEnabled(group.items[i], enable),
              toggleBusy: pendingToggleIds.contains(group.items[i].id),
              onDelete: onDelete != null
                  ? () => onDelete!(group.items[i].id)
                  : null,
            ),
            if (i != group.items.length - 1) SizedBox(height: spacing.sm + 2),
          ],
        ],
      ),
    );
  }
}

class ScheduleSummaryCard extends StatelessWidget {
  const ScheduleSummaryCard({
    super.key,
    required this.summary,
    required this.now,
    required this.onAddClass,
    required this.onScanCard,
    required this.menuButton,
  });

  final ScheduleSummary summary;
  final DateTime now;
  final VoidCallback onAddClass;
  final VoidCallback onScanCard;
  final Widget menuButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;
    final highlight = summary.highlight;

    final card = Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: isDark ? colors.outline.withValues(alpha: 0.12) : colors.outline,
          width: isDark ? 1 : 0.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Schedules overview',
                  style: AppTokens.typography.title.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: colors.onSurface,
                  ),
                ),
              ),
              menuButton,
            ],
          ),
          SizedBox(height: spacing.xl),
          if (highlight != null) ...[
            _ScheduleHighlightHero(highlight: highlight, now: now),
            SizedBox(height: spacing.xl),
          ],
          Row(
            children: [
              Expanded(
                child: _CompactMetricChip(
                  icon: Icons.event_note_outlined,
                  value: summary.total,
                  label: 'Scheduled',
                  tint: colors.primary,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: _CompactMetricChip(
                  icon: Icons.toggle_off_outlined,
                  value: summary.disabled,
                  label: 'Disabled',
                  tint: colors.error,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: _CompactMetricChip(
                  icon: Icons.edit_outlined,
                  value: summary.custom,
                  label: 'Custom',
                  tint: colors.tertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xl),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Add class',
                  onPressed: onAddClass,
                  minHeight: 48,
                  expanded: true,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: SecondaryButton(
                  label: 'Scan card',
                  onPressed: onScanCard,
                  minHeight: 48,
                  expanded: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return RepaintBoundary(child: card);
  }
}

class _ScheduleHighlightHero extends StatelessWidget {
  const _ScheduleHighlightHero({
    required this.highlight,
    required this.now,
  });

  final ScheduleHighlight highlight;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final item = highlight.item;
    final rawTitle = (item.title ?? item.code ?? '').trim();
    final subject = rawTitle.isEmpty ? 'Upcoming class' : rawTitle;
    final location = (item.room ?? '').trim();
    final instructor = (item.instructor ?? '').trim();
    final instructorAvatar = (item.instructorAvatar ?? '').trim();
    final hasInstructor = instructor.isNotEmpty;
    final isLive = highlight.status == ScheduleHighlightStatus.ongoing;
    final statusLabel = isLive ? 'Live Now' : 'Coming Up';
    final timeLabel =
        '${DateFormat('h:mm a').format(highlight.start)} - ${DateFormat('h:mm a').format(highlight.end)}';
    final dateLabel = DateFormat('EEEE, MMMM d').format(highlight.start);
    final isDark = theme.brightness == Brightness.dark;
    final foreground = colors.onPrimary;

    // Calculate time until class
    final now = DateTime.now();
    final timeUntil = highlight.start.difference(now);
    String timeUntilText = '';
    if (!isLive && timeUntil.inMinutes > 0) {
      if (timeUntil.inHours > 0) {
        timeUntilText = 'in ${timeUntil.inHours}h ${timeUntil.inMinutes % 60}m';
      } else {
        timeUntilText = 'in ${timeUntil.inMinutes}m';
      }
    }

    return Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: AppTokens.radius.lg,
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Row(
            children: [
              Container(
                padding: spacing.edgeInsetsSymmetric(horizontal: spacing.md, vertical: spacing.sm - 1),
                decoration: BoxDecoration(
                  color: foreground.withValues(alpha: 0.20),
                  borderRadius: AppTokens.radius.pill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLive)
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(right: spacing.sm),
                        decoration: BoxDecoration(
                          color: foreground,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: foreground.withValues(alpha: 0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      )
                    else
                      Icon(
                        Icons.schedule_rounded,
                        size: AppTokens.iconSize.sm,
                        color: foreground,
                      ),
                    if (!isLive) SizedBox(width: spacing.xs + 2),
                    Text(
                      statusLabel,
                      style: AppTokens.typography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: foreground,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (timeUntilText.isNotEmpty) ...[
                SizedBox(width: spacing.sm + 2),
                Text(
                  timeUntilText,
                  style: AppTokens.typography.caption.copyWith(
                    color: foreground.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: spacing.xl),
          
          // Class title
          Text(
            subject,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTokens.typography.headline.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: foreground,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: spacing.lg + 2),
          
          // Time
          Row(
            children: [
              Container(
                padding: spacing.edgeInsetsAll(spacing.sm),
                decoration: BoxDecoration(
                  color: foreground.withValues(alpha: 0.15),
                  borderRadius: AppTokens.radius.sm,
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  size: AppTokens.iconSize.sm,
                  color: foreground,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeLabel,
                      style: AppTokens.typography.subtitle.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppTokens.spacing.xs),
                    Text(
                      dateLabel,
                      style: AppTokens.typography.caption.copyWith(
                        color: foreground.withValues(alpha: 0.80),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (location.isNotEmpty) ...[
            SizedBox(height: spacing.md + 2),
            Row(
              children: [
                Container(
                  padding: spacing.edgeInsetsAll(spacing.sm),
                  decoration: BoxDecoration(
                    color: foreground.withValues(alpha: 0.15),
                    borderRadius: AppTokens.radius.sm,
                  ),
                  child: Icon(
                    Icons.place_outlined,
                    size: AppTokens.iconSize.sm,
                    color: foreground,
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTokens.typography.body.copyWith(
                      color: foreground.withValues(alpha: 0.90),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          if (hasInstructor) ...[
            SizedBox(height: spacing.lg),
            Container(
              padding: spacing.edgeInsetsAll(spacing.md),
              decoration: BoxDecoration(
                color: foreground.withValues(alpha: 0.12),
                borderRadius: AppTokens.radius.md,
              ),
              child: _ScheduleInstructorRow(
                name: instructor,
                avatarUrl: instructorAvatar.isEmpty ? null : instructorAvatar,
                tint: foreground,
                inverse: true,
                dense: false,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleHeroChip extends StatelessWidget {
  const _ScheduleHeroChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: AppTokens.spacing.edgeInsetsSymmetric(
        horizontal: AppTokens.spacing.sm + 2,
        vertical: AppTokens.spacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTokens.radius.pill,
        border: Border.all(color: foreground.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTokens.iconSize.xs, color: foreground),
          SizedBox(width: AppTokens.spacing.xs + 2),
          Text(
            label,
            style: AppTokens.typography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleMetricChip extends StatelessWidget {
  const _ScheduleMetricChip({
    required this.icon,
    required this.tint,
    required this.label,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final Color tint;
  final String label;
  final int value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.md + 2),
      decoration: BoxDecoration(
        color: isDark ? tint.withValues(alpha: 0.12) : colors.surfaceContainerHighest,
        borderRadius: AppTokens.radius.md,
        border: Border.all(
          color: isDark ? tint.withValues(alpha: 0.20) : colors.outline,
          width: isDark ? 1 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: isDark ? 0.20 : 0.12),
              borderRadius: AppTokens.radius.sm,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: tint,
              size: AppTokens.iconSize.sm,
            ),
          ),
          SizedBox(height: spacing.sm + 2),
          Text(
            '$value',
            style: AppTokens.typography.headline.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: AppTokens.spacing.xs),
          Text(
            label,
            style: AppTokens.typography.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppTokens.spacing.xs),
          Text(
            caption,
            style: AppTokens.typography.caption.copyWith(
              color: colors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Compact horizontal metric chip for timeline-style layout
class _CompactMetricChip extends StatelessWidget {
  const _CompactMetricChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.tint,
  });

  final IconData icon;
  final int value;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.lg),
      decoration: BoxDecoration(
        color: isDark ? tint.withValues(alpha: 0.12) : tint.withValues(alpha: 0.08),
        borderRadius: AppTokens.radius.md,
        border: Border.all(
          color: tint.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: spacing.edgeInsetsAll(spacing.sm + 2),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.15),
              borderRadius: AppTokens.radius.sm,
            ),
            child: Icon(
              icon,
              size: AppTokens.iconSize.lg,
              color: tint,
            ),
          ),
          SizedBox(height: spacing.md),
          Text(
            '$value',
            style: AppTokens.typography.display.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.0,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            label,
            style: AppTokens.typography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class ScheduleRow extends StatelessWidget {
  const ScheduleRow({
    super.key,
    required this.item,
    required this.isLast,
    required this.highlight,
    required this.onOpenDetails,
    required this.onToggleEnabled,
    required this.toggleBusy,
    this.onDelete,
  });

  final sched.ClassItem item;
  final bool isLast;
  final bool highlight;
  final VoidCallback onOpenDetails;
  final void Function(bool enable) onToggleEnabled;
  final bool toggleBusy;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;
    final now = DateTime.now();
    final nextStart = ScheduleClassListCard._nextOccurrence(item, now);
    final nextEnd = ScheduleClassListCard._endFor(item, nextStart);
    final rawSubject = ((item.title ?? item.code ?? '').trim());
    final subject = rawSubject.isEmpty ? 'Class ${item.id}' : rawSubject;
    final location = (item.room ?? '').trim();
    final instructor = (item.instructor ?? '').trim();
    final instructorAvatar = (item.instructorAvatar ?? '').trim();
    final isLive = now.isAfter(nextStart) && now.isBefore(nextEnd);
    final isNext = !isLive && nextStart.difference(now).inMinutes < 60;
    final isHidden = !item.enabled;

    final timeFormat = DateFormat('h:mm a');
    final timeRange = '${timeFormat.format(nextStart)} - ${timeFormat.format(nextEnd)}';

    final child = Material(
      color: Colors.transparent,
      borderRadius: AppTokens.radius.lg,
      child: InkWell(
        onTap: onOpenDetails,
        borderRadius: AppTokens.radius.md,
        splashColor: colors.primary.withValues(alpha: 0.05),
        highlightColor: colors.primary.withValues(alpha: 0.02),
        child: Container(
          padding: spacing.edgeInsetsAll(spacing.lg),
          decoration: BoxDecoration(
            color: isDark ? colors.surfaceContainerHigh : colors.surface,
            borderRadius: AppTokens.radius.md,
            border: Border.all(
              color: isLive 
                  ? colors.primary.withValues(alpha: 0.30)
                  : colors.outline.withValues(alpha: isDark ? 0.12 : 0.5),
              width: isLive ? 1.5 : 0.5,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: isLive ? 0.08 : 0.04),
                      blurRadius: isLive ? 12 : 6,
                      offset: const Offset(0, 2),
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
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: isHidden
                            ? colors.onSurfaceVariant
                            : colors.onSurface,
                        decoration: isHidden ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  // Status badge or toggle
                  if (isLive || isNext)
                    Container(
                      padding: spacing.edgeInsetsSymmetric(horizontal: spacing.sm + 2, vertical: spacing.xs),
                      decoration: BoxDecoration(
                        color: isLive
                            ? colors.primary.withValues(alpha: 0.15)
                            : colors.primary.withValues(alpha: 0.08),
                        borderRadius: AppTokens.radius.sm,
                      ),
                      child: Text(
                        isLive ? 'Live' : 'Next',
                        style: AppTokens.typography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    )
                  else
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: !isHidden,
                        onChanged: toggleBusy ? null : onToggleEnabled,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              SizedBox(height: spacing.md),
              // Bottom row: Time, Location, Instructor
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
                    timeRange,
                    style: AppTokens.typography.bodySecondary.copyWith(
                      fontWeight: FontWeight.w500,
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
                          fontWeight: FontWeight.w500,
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
                        width: 24,
                        height: 24,
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
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            instructor[0].toUpperCase(),
                            style: AppTokens.typography.caption.copyWith(
                              fontWeight: FontWeight.w600,
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
                          fontWeight: FontWeight.w500,
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
        ),
      ),
    );

    if (!item.isCustom || onDelete == null) {
      return child;
    }

    return ClipRRect(
      borderRadius: AppTokens.radius.lg,
      child: Slidable(
        key: ValueKey('dismiss-class-${item.id}'),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.4,
          children: [
            CustomSlidableAction(
              onPressed: (context) async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete custom class?'),
                    content: const Text(
                      'This class will be removed from your schedules and reminders.',
                    ),
                    actions: [
                      SecondaryButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(false),
                        minHeight: 44,
                        expanded: false,
                      ),
                      PrimaryButton(
                        label: 'Delete',
                        onPressed: () => Navigator.of(context).pop(true),
                        minHeight: 44,
                        expanded: false,
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  onDelete!();
                }
              },
              backgroundColor: Colors.transparent,
              foregroundColor: colors.onError,
              child: Container(
                margin: EdgeInsets.only(left: AppTokens.spacing.sm),
                decoration: BoxDecoration(
                  color: colors.error,
                  borderRadius: AppTokens.radius.lg,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.delete_outline_rounded, color: colors.onError),
                    SizedBox(height: AppTokens.spacing.xs),
                    Text(
                      'Delete',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onError,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _ScheduleInstructorRow extends StatelessWidget {
  const _ScheduleInstructorRow({
    required this.name,
    required this.tint,
    this.avatarUrl,
    this.inverse = false,
    this.dense = true,
  });

  final String name;
  final Color tint;
  final String? avatarUrl;
  final bool inverse;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textStyle =
        (dense ? AppTokens.typography.body : AppTokens.typography.subtitle)
            .copyWith(
      fontWeight: FontWeight.w600,
      color: inverse
          ? colors.onPrimary.withValues(alpha: 0.95)
          : colors.onSurfaceVariant,
    );
    return Row(
      children: [
        InstructorAvatar(
          name: name,
          avatarUrl: avatarUrl,
          tint: tint,
          inverse: inverse,
          size: dense ? 26 : 28,
        ),
        SizedBox(width: dense ? 6 : 8),
        Expanded(
          child: Text(
            name,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedHeaderDelegate({
    required this.child,
    required this.height,
    required this.maxWidth,
    required this.backgroundColor,
  });

  final Widget child;
  final double height;
  final double maxWidth;
  final Color backgroundColor;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return child != oldDelegate.child ||
        height != oldDelegate.height ||
        maxWidth != oldDelegate.maxWidth ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
