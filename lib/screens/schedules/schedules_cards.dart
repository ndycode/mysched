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
          color: isDark ? colors.outline.withValues(alpha: AppOpacity.overlay) : colors.outline,
          width: isDark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: AppOpacity.veryFaint),
                  blurRadius: AppTokens.shadow.lg,
                  offset: AppShadowOffset.sm,
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
                height: AppTokens.componentSize.avatarXl,
                width: AppTokens.componentSize.avatarXl,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary.withValues(alpha: AppOpacity.medium),
                      colors.primary.withValues(alpha: AppOpacity.dim),
                    ],
                  ),
                  borderRadius: AppTokens.radius.md,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: AppOpacity.borderEmphasis),
                    width: AppTokens.componentSize.dividerThick,
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
                        fontWeight: AppTokens.fontWeight.extraBold,
                        letterSpacing: AppLetterSpacing.tight,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      dateLabel,
                      style: AppTokens.typography.bodySecondary.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: AppTokens.fontWeight.medium,
                      ),
                    ),
                  ],
                ),
              ),
              if (onRefresh != null) ...[
                SizedBox(
                  height: AppTokens.componentSize.buttonXs,
                  child: IconButton(
                    onPressed: refreshing ? null : onRefresh,
                    tooltip: 'Refresh',
                    style: IconButton.styleFrom(
                      minimumSize: Size.square(AppTokens.componentSize.buttonXs),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: colors.onSurfaceVariant,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTokens.radius.md,
                      ),
                    ),
                    icon: refreshing
                        ? SizedBox(
                            width: AppTokens.componentSize.badgeMd,
                            height: AppTokens.componentSize.badgeMd,
                            child: CircularProgressIndicator(
                              strokeWidth: AppInteraction.progressStrokeWidth,
                              valueColor: AlwaysStoppedAnimation(colors.primary),
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            size: AppTokens.iconSize.md,
                          ),
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
                color: isDark ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.divider) : colors.primary.withValues(alpha: AppOpacity.micro),
                borderRadius: AppTokens.radius.lg,
                border: Border.all(
                  color: isDark ? colors.outline.withValues(alpha: AppOpacity.overlay) : colors.primary.withValues(alpha: AppOpacity.dim),
                  width: AppTokens.componentSize.divider,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: spacing.edgeInsetsAll(spacing.lg),
                    decoration: BoxDecoration(
                      color: isDark ? colors.primary.withValues(alpha: AppOpacity.medium) : colors.primary.withValues(alpha: AppOpacity.dim),
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
                      fontWeight: AppTokens.fontWeight.bold,
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing.sm),
                  Text(
                    'Add a class or scan your student card to get started.',
                    style: AppTokens.typography.bodySecondary.copyWith(
                      color: colors.onSurfaceVariant.withValues(alpha: AppOpacity.secondary),
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
                          groups[g].label,
                          style: AppTokens.typography.subtitle.copyWith(
                            fontWeight: AppTokens.fontWeight.extraBold,
                            letterSpacing: AppLetterSpacing.snug,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: spacing.edgeInsetsSymmetric(horizontal: spacing.sm + AppTokens.spacing.micro, vertical: spacing.xs + AppTokens.spacing.microHalf),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: AppOpacity.overlay),
                          borderRadius: AppTokens.radius.sm,
                        ),
                        child: Text(
                          '${groups[g].items.length} ${groups[g].items.length == 1 ? 'class' : 'classes'}',
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
                  if (i != groups[g].items.length - 1) SizedBox(height: spacing.sm + AppTokens.spacing.micro),
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
            height: AppTokens.componentSize.listItemMd,
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
    final shadowColor = colors.outline.withValues(alpha: AppOpacity.highlight);
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
                  blurRadius: AppTokens.shadow.lg,
                  offset: AppShadowOffset.hero,
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
                fontWeight: AppTokens.fontWeight.bold,
              ),
            ),
            SizedBox(height: spacing.md + AppTokens.spacing.micro),
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
            if (i != group.items.length - 1) SizedBox(height: spacing.sm + AppTokens.spacing.micro),
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
          color: isDark ? colors.outline.withValues(alpha: AppOpacity.overlay) : colors.outline,
          width: isDark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: AppOpacity.faint),
                  blurRadius: AppTokens.shadow.md,
                  offset: AppShadowOffset.sm,
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
                    fontWeight: AppTokens.fontWeight.bold,
                    letterSpacing: AppLetterSpacing.snug,
                    color: colors.onSurface,
                  ),
                ),
              ),
              SizedBox(
                width: AppTokens.componentSize.buttonXs,
                height: AppTokens.componentSize.buttonXs,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                      width: AppTokens.componentSize.buttonXs,
                      height: AppTokens.componentSize.buttonXs,
                    ),
                    child: menuButton,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xl),
          if (highlight != null) ...[
            _ScheduleHighlightHero(highlight: highlight, now: now),
            SizedBox(height: spacing.xl),
          ] else ...[
            _EmptyHeroPlaceholder(
              icon: Icons.calendar_month_outlined,
              title: 'All caught up',
              subtitle: 'No upcoming classes in this scope.',
            ),
            SizedBox(height: spacing.xl),
          ],
          Row(
            children: [
              Expanded(
                child: MetricChip(
                  icon: Icons.event_note_outlined,
                  value: '${summary.total}',
                  label: 'Scheduled',
                  tint: colors.primary,
                  displayStyle: true,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: MetricChip(
                  icon: Icons.toggle_off_outlined,
                  value: '${summary.disabled}',
                  label: 'Disabled',
                  tint: colors.error,
                  displayStyle: true,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: MetricChip(
                  icon: Icons.edit_outlined,
                  value: '${summary.custom}',
                  label: 'Custom',
                  tint: colors.tertiary,
                  displayStyle: true,
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
                  minHeight: AppTokens.componentSize.buttonMd,
                  expanded: true,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: SecondaryButton(
                  label: 'Scan card',
                  onPressed: onScanCard,
                  minHeight: AppTokens.componentSize.buttonMd,
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
            colors.primary.withValues(alpha: AppOpacity.prominent),
          ],
        ),
        borderRadius: AppTokens.radius.lg,
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: AppOpacity.ghost),
            blurRadius: AppTokens.shadow.xl,
            offset: AppShadowOffset.lg,
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
                padding: spacing.edgeInsetsSymmetric(horizontal: spacing.md, vertical: spacing.sm - spacing.micro),
                decoration: BoxDecoration(
                  color: foreground.withValues(alpha: AppOpacity.border),
                  borderRadius: AppTokens.radius.pill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLive)
                      Container(
                        width: AppTokens.componentSize.badgeSm,
                        height: AppTokens.componentSize.badgeSm,
                        margin: EdgeInsets.only(right: spacing.sm),
                        decoration: BoxDecoration(
                          color: foreground,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: foreground.withValues(alpha: AppOpacity.subtle),
                              blurRadius: AppTokens.shadow.xs,
                              spreadRadius: AppTokens.componentSize.divider,
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
                    if (!isLive) SizedBox(width: spacing.xs + AppTokens.spacing.micro),
                    Text(
                      statusLabel,
                      style: AppTokens.typography.caption.copyWith(
                        fontWeight: AppTokens.fontWeight.semiBold,
                        color: foreground,
                        letterSpacing: AppLetterSpacing.wider,
                      ),
                    ),
                  ],
                ),
              ),
              if (timeUntilText.isNotEmpty) ...[
                SizedBox(width: spacing.sm + AppTokens.spacing.micro),
                Text(
                  timeUntilText,
                  style: AppTokens.typography.caption.copyWith(
                    color: foreground.withValues(alpha: AppOpacity.prominent),
                    fontWeight: AppTokens.fontWeight.medium,
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
              fontWeight: AppTokens.fontWeight.bold,
              height: AppLineHeight.compact,
              color: foreground,
              letterSpacing: AppLetterSpacing.tight,
            ),
          ),
          SizedBox(height: spacing.lg + AppTokens.spacing.micro),
          
          // Time
          Row(
            children: [
              Container(
                padding: spacing.edgeInsetsAll(spacing.sm),
                decoration: BoxDecoration(
                  color: foreground.withValues(alpha: AppOpacity.medium),
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
                        fontWeight: AppTokens.fontWeight.semiBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.spacing.xs),
                    Text(
                      dateLabel,
                      style: AppTokens.typography.caption.copyWith(
                        color: foreground.withValues(alpha: AppOpacity.secondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (location.isNotEmpty) ...[
            SizedBox(height: spacing.md + AppTokens.spacing.micro),
            Row(
              children: [
                Container(
                  padding: spacing.edgeInsetsAll(spacing.sm),
                  decoration: BoxDecoration(
                    color: foreground.withValues(alpha: AppOpacity.medium),
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
                      color: foreground.withValues(alpha: AppOpacity.high),
                      fontWeight: AppTokens.fontWeight.medium,
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
                color: foreground.withValues(alpha: AppOpacity.overlay),
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

class _EmptyHeroPlaceholder extends StatelessWidget {
  const _EmptyHeroPlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spacing = AppTokens.spacing;
    return Container(
      width: double.infinity,
      padding: spacing.edgeInsetsAll(spacing.xxxl),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: AppOpacity.micro),
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: colors.primary.withValues(alpha: AppOpacity.dim),
          width: AppTokens.componentSize.divider,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: spacing.emptyStateSize,
            height: spacing.emptyStateSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primary.withValues(alpha: AppOpacity.medium),
                  colors.primary.withValues(alpha: AppOpacity.highlight),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.primary.withValues(alpha: AppOpacity.accent),
                width: AppTokens.componentSize.dividerThick,
              ),
            ),
            child: Icon(
              icon,
              size: AppTokens.iconSize.xxl,
              color: colors.primary,
            ),
          ),
          SizedBox(height: spacing.xl),
          Text(
            title,
            style: AppTokens.typography.subtitle.copyWith(
              fontWeight: AppTokens.fontWeight.bold,
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.sm),
          Text(
            subtitle,
            style: AppTokens.typography.bodySecondary.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: AppOpacity.secondary),
            ),
            textAlign: TextAlign.center,
          ),
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
        horizontal: AppTokens.spacing.sm + AppTokens.spacing.micro,
        vertical: AppTokens.spacing.xs + AppTokens.spacing.microHalf,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTokens.radius.pill,
        border: Border.all(color: foreground.withValues(alpha: AppOpacity.borderEmphasis)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTokens.iconSize.xs, color: foreground),
          SizedBox(width: AppTokens.spacing.xs + AppTokens.spacing.micro),
          Text(
            label,
            style: AppTokens.typography.caption.copyWith(
              fontWeight: AppTokens.fontWeight.semiBold,
              color: foreground,
            ),
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

    // Build metadata items
    final metadata = <MetadataItem>[
      MetadataItem(icon: Icons.access_time_rounded, label: timeRange),
      if (location.isNotEmpty)
        MetadataItem(icon: Icons.location_on_outlined, label: location, expanded: true),
    ];

    // Build trailing widget (badge or toggle)
    Widget? trailing;
    StatusBadge? badge;
    
    if (isLive) {
      badge = const StatusBadge(label: 'Live', variant: StatusBadgeVariant.live);
    } else if (isNext) {
      badge = const StatusBadge(label: 'Next', variant: StatusBadgeVariant.next);
    } else {
      trailing = Transform.scale(
        scale: AppScale.dense,
        child: Switch(
          value: !isHidden,
          onChanged: toggleBusy ? null : onToggleEnabled,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }

    final child = EntityTile(
      title: subject,
      isActive: !isHidden,
      isStrikethrough: isHidden,
      isHighlighted: isLive,
      metadata: metadata,
      badge: badge,
      trailing: trailing,
      bottomContent: instructor.isNotEmpty
          ? InstructorRow(
              name: instructor,
              avatarUrl: instructorAvatar.isNotEmpty ? instructorAvatar : null,
            )
          : null,
      onTap: onOpenDetails,
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
          extentRatio: AppScale.slideExtent,
          children: [
            CustomSlidableAction(
              onPressed: (context) async {
                final confirm = await AppModal.showConfirmDialog(
                  context: context,
                  title: 'Delete custom class?',
                  message: 'This class will be removed from your schedules and reminders.',
                  confirmLabel: 'Delete',
                  isDanger: true,
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
                        fontWeight: AppTokens.fontWeight.semiBold,
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
      fontWeight: AppTokens.fontWeight.semiBold,
      color: inverse
          ? colors.onPrimary.withValues(alpha: AppOpacity.full)
          : colors.onSurfaceVariant,
    );
    final spacing = AppTokens.spacing;
    final sizes = AppTokens.componentSize;
    return Row(
      children: [
        InstructorAvatar(
          name: name,
          avatarUrl: avatarUrl,
          tint: tint,
          inverse: inverse,
          size: dense ? sizes.avatarXsDense : sizes.avatarSmDense,
        ),
        SizedBox(width: dense ? spacing.xsPlus : spacing.sm),
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
