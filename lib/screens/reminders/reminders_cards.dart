// ignore_for_file: unused_local_variable, unused_element
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../models/reminder_scope.dart';
import '../../services/reminders_api.dart';
import '../../ui/kit/kit.dart';
import '../../ui/kit/reminder_details_sheet.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/time_format.dart';
import 'reminders_controller.dart';
import 'reminders_data.dart';

class ReminderGroupSliver extends StatelessWidget implements ScreenShellSliver {
  const ReminderGroupSliver({
    super.key,
    required this.header,
    required this.group,
    required this.timeFormat,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onSnooze,
    this.queuedIds = const <int>{},
    this.showHeader = true,
  });

  final Widget header;
  final ReminderGroup group;
  final DateFormat timeFormat;
  final Future<void> Function(ReminderEntry entry, bool isActive) onToggle;
  final Future<void> Function(ReminderEntry entry) onEdit;
  final Future<void> Function(ReminderEntry entry) onDelete;
  final Future<void> Function(ReminderEntry entry) onSnooze;
  final Set<int> queuedIds;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    // This build method is for non-sliver usage (if any),
    // but ScreenShell uses buildSlivers.
    // We'll just return a Column of cards.
    return Column(
      children: [
        header,
        ...group.items.map((entry) => Padding(
              padding: spacing.edgeInsetsOnly(bottom: spacing.md),
              child: ReminderRow(
                entry: entry,
                timeFormat: timeFormat,
                onToggle: (v) => onToggle(entry, v),
                onEdit: () => onEdit(entry),
                onDelete: () => onDelete(entry),
                onSnooze: () => onSnooze(entry),
                showQueuedBadge: queuedIds.contains(entry.id),
              ),
            )),
      ],
    );
  }

  @override
  List<Widget> buildSlivers(
    BuildContext context,
    double maxWidth,
    EdgeInsetsGeometry horizontalPadding,
  ) {
    final spacing = AppTokens.spacing;
    // We use SliverToBoxAdapter for the header to avoid sticky behavior
    // overlapping with the box style headers.
    return [
      SliverPadding(
        padding: horizontalPadding,
        sliver: SliverToBoxAdapter(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: header,
          ),
        ),
      ),
      SliverPadding(
        padding: horizontalPadding,
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final entry = group.items[index];
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Padding(
                    padding: spacing.edgeInsetsOnly(bottom: spacing.md),
                    child: ReminderRow(
                      entry: entry,
                      timeFormat: timeFormat,
                      onToggle: (v) => onToggle(entry, v),
                      onEdit: () => onEdit(entry),
                      onDelete: () => onDelete(entry),
                      onSnooze: () => onSnooze(entry),
                      showQueuedBadge: queuedIds.contains(entry.id),
                    ),
                  ),
                ),
              );
            },
            childCount: group.items.length,
          ),
        ),
      ),
    ];
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
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
              color: colors.onSurfaceVariant
                  .withValues(alpha: AppOpacity.secondary),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ReminderSummaryCard extends StatelessWidget {
  const ReminderSummaryCard({
    super.key,
    required this.summary,
    required this.now,
    required this.onCreate,
    required this.onToggleCompleted,
    required this.showCompleted,
    this.menuButton,
  });

  final ReminderSummary summary;
  final DateTime now;
  final VoidCallback onCreate;
  final VoidCallback onToggleCompleted;
  final bool showCompleted;
  final Widget? menuButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final highlight = summary.highlight;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    final card = Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: isDark
              ? colors.outline.withValues(alpha: AppOpacity.overlay)
              : colors.outline,
          width: isDark
              ? AppTokens.componentSize.divider
              : AppTokens.componentSize.dividerThin,
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
                  'Reminders overview',
                  style: AppTokens.typography.title.copyWith(
                    fontWeight: AppTokens.fontWeight.bold,
                    letterSpacing: AppLetterSpacing.snug,
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (menuButton != null)
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
            ReminderHighlightHero(highlight: highlight, now: now),
            SizedBox(height: spacing.xl),
          ] else ...[
            _EmptyHeroPlaceholder(
              icon: Icons.task_alt_rounded,
              title: 'All caught up',
              subtitle: 'Create a reminder to stay on top of tasks.',
            ),
            SizedBox(height: spacing.xl),
          ],
          Row(
            children: [
              Expanded(
                child: MetricChip(
                  icon: Icons.pending_actions_rounded,
                  tint: colors.primary,
                  label: 'Pending',
                  value: '${summary.pending}',
                  displayStyle: true,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: MetricChip(
                  icon: Icons.warning_amber_rounded,
                  tint: colors.error,
                  label: 'Overdue',
                  value: '${summary.overdue}',
                  displayStyle: true,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: MetricChip(
                  icon: Icons.snooze_rounded,
                  tint: colors.secondary,
                  label: 'Snoozed',
                  value: '${summary.snoozed}',
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
                  label: 'New reminder',
                  onPressed: onCreate,
                  minHeight: AppTokens.componentSize.buttonMd,
                  expanded: true,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: SecondaryButton(
                  label: showCompleted ? 'Hide completed' : 'Show completed',
                  onPressed: onToggleCompleted,
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

class ReminderHighlightHero extends StatelessWidget {
  const ReminderHighlightHero({
    super.key,
    required this.highlight,
    required this.now,
  });

  final ReminderHighlight highlight;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final entry = highlight.entry;
    final target = highlight.targetTime;
    final label = switch (highlight.status) {
      ReminderHighlightStatus.overdue => 'Overdue',
      ReminderHighlightStatus.snoozed => 'Snoozed',
      ReminderHighlightStatus.upcoming => 'Next reminder',
    };
    final labelIcon = switch (highlight.status) {
      ReminderHighlightStatus.overdue => Icons.report_problem_rounded,
      ReminderHighlightStatus.snoozed => Icons.snooze_rounded,
      ReminderHighlightStatus.upcoming => Icons.arrow_forward_rounded,
    };
    final badgeIcon = switch (highlight.status) {
      ReminderHighlightStatus.overdue => Icons.warning_amber_rounded,
      ReminderHighlightStatus.snoozed => Icons.alarm_on_rounded,
      ReminderHighlightStatus.upcoming => Icons.flash_on_rounded,
    };
    final badgeLabel = switch (highlight.status) {
      ReminderHighlightStatus.overdue => 'Action needed',
      ReminderHighlightStatus.snoozed => 'Snoozed',
      ReminderHighlightStatus.upcoming => 'Next',
    };
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;
    final baseColor = colors.primary;
    final gradient = [
      baseColor,
      baseColor.withValues(alpha: AppOpacity.prominent),
    ];
    final shadowColor = baseColor.withValues(alpha: AppOpacity.ghost);
    final foreground = colors.onPrimary;
    final timeLabel = AppTimeFormat.formatTime(target);
    final dateLabel = DateFormat('EEEE, MMMM d').format(target);
    final subtitle = _formatRelativeDuration(target.difference(now)) ??
        (highlight.status == ReminderHighlightStatus.overdue
            ? 'Just overdue'
            : 'Due soon');
    final title =
        entry.title.trim().isEmpty ? 'Upcoming reminder' : entry.title.trim();
    final details = entry.details?.trim() ?? '';

    return Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: AppTokens.radius.lg,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: AppTokens.shadow.xl,
            offset: AppShadowOffset.lg,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ReminderHeroChip(
                icon: labelIcon,
                label: label,
                foreground: foreground,
              ),
              SizedBox(width: spacing.sm + AppTokens.spacing.micro),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: AppTokens.typography.caption.copyWith(
                    color: foreground.withValues(alpha: AppOpacity.prominent),
                    fontWeight: AppTokens.fontWeight.medium,
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.xl),
          Text(
            title,
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
                        color:
                            foreground.withValues(alpha: AppOpacity.secondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (details.isNotEmpty) ...[
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
                    Icons.notes_rounded,
                    size: AppTokens.iconSize.sm,
                    color: foreground,
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Text(
                    details,
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
        ],
      ),
    );
  }

  String? _formatRelativeDuration(Duration delta) {
    if (delta.inMinutes.abs() < 1) return null;
    final positive = delta.isNegative ? -delta : delta;
    final days = positive.inDays;
    final hours = positive.inHours % 24;
    final minutes = positive.inMinutes % 60;
    final parts = <String>[];
    if (days > 0) {
      parts.add('${days}d');
      parts.add('${hours}h');
    } else {
      if (hours > 0) parts.add('${hours}h');
      if (minutes > 0) parts.add('${minutes}m');
    }
    final formatted = parts.isEmpty ? 'moments' : parts.join(' ');
    if (delta.isNegative) {
      return 'Overdue by $formatted';
    }
    return 'in $formatted';
  }
}

class ReminderHeroChip extends StatelessWidget {
  const ReminderHeroChip({
    super.key,
    required this.icon,
    required this.label,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.md,
        vertical: spacing.sm - spacing.micro,
      ),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: AppOpacity.border),
        borderRadius: AppTokens.radius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTokens.iconSize.sm, color: foreground),
          SizedBox(width: spacing.xs + spacing.micro),
          Text(
            label,
            style: AppTokens.typography.caption.copyWith(
              fontWeight: AppTokens.fontWeight.semiBold,
              color: foreground,
              letterSpacing: AppLetterSpacing.wider,
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderGroupCard extends StatelessWidget {
  const ReminderGroupCard({
    super.key,
    required this.group,
    required this.timeFormat,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onSnooze,
    this.queuedIds = const <int>{},
    this.showHeader = true,
  });

  final ReminderGroup group;
  final DateFormat timeFormat;
  final Future<void> Function(ReminderEntry entry, bool isActive) onToggle;
  final Future<void> Function(ReminderEntry entry) onEdit;
  final Future<void> Function(ReminderEntry entry) onDelete;
  final Future<void> Function(ReminderEntry entry) onSnooze;
  final Set<int> queuedIds;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;
    final queuedCount =
        group.items.where((item) => queuedIds.contains(item.id)).length;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: isDark
              ? colors.outline.withValues(alpha: AppOpacity.overlay)
              : colors.outline,
          width: isDark
              ? AppTokens.componentSize.divider
              : AppTokens.componentSize.dividerThin,
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
          if (showHeader) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.label,
                    style: AppTokens.typography.subtitle.copyWith(
                      fontWeight: AppTokens.fontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                Text(
                  '${group.items.length} reminder${group.items.length == 1 ? '' : 's'}',
                  style: AppTokens.typography.caption.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: AppTokens.fontWeight.medium,
                  ),
                ),
                AnimatedSwitcher(
                  duration: AppTokens.motion.fast,
                  child: queuedCount > 0
                      ? Padding(
                          key: ValueKey('queued-$queuedCount'),
                          padding: EdgeInsets.only(left: AppTokens.spacing.sm),
                          child: QueuedBadge(label: 'Queued $queuedCount'),
                        )
                      : Row(
                          key: const ValueKey('synced-indicator'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: AppTokens.spacing.sm),
                            Icon(
                              Icons.check_circle_rounded,
                              size: AppTokens.iconSize.sm,
                              color: colors.tertiary,
                            ),
                            SizedBox(width: AppTokens.spacing.xs),
                            Text(
                              'Synced',
                              style: AppTokens.typography.caption.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: AppTokens.fontWeight.semiBold,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.spacing.md),
          ],
          ...List.generate(
            group.items.length,
            (index) => ReminderRow(
              entry: group.items[index],
              timeFormat: timeFormat,
              onToggle: (value) => onToggle(group.items[index], value),
              onEdit: () => onEdit(group.items[index]),
              onDelete: () => onDelete(group.items[index]),
              onSnooze: () => onSnooze(group.items[index]),
              showQueuedBadge: queuedIds.contains(group.items[index].id),
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderRow extends StatelessWidget {
  const ReminderRow({
    super.key,
    required this.entry,
    required this.timeFormat,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onSnooze,
    this.showQueuedBadge = false,
    this.highlight = false,
  });

  final ReminderEntry entry;
  final DateFormat timeFormat;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSnooze;
  final bool showQueuedBadge;
  /// Whether to show a highlight effect on this row (newly added).
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;
    final localDue = entry.dueAt.toLocal();
    final dueLabel = 'Due ${DateFormat('MMM d').format(localDue)}, ${AppTimeFormat.formatTime(localDue)}';
    final details = (entry.details ?? '').trim();
    final isDone = entry.isCompleted;

    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final highlightColor = highlight ? palette.positive : null;

    final child = Material(
      color: Colors.transparent,
      borderRadius: AppTokens.radius.lg,
      child: InkWell(
        onTap: () => _showDetails(context),
        borderRadius: AppTokens.radius.lg,
        splashColor: colors.primary.withValues(alpha: AppOpacity.faint),
        highlightColor: colors.primary.withValues(alpha: AppOpacity.ultraMicro),
        child: Container(
          padding: spacing.edgeInsetsAll(spacing.lg),
          decoration: BoxDecoration(
            color: isDark ? colors.surfaceContainerHigh : colors.surface,
            borderRadius: AppTokens.radius.lg,
            border: Border.all(
              color: highlight
                  ? highlightColor!.withValues(alpha: AppOpacity.medium)
                  : colors.outlineVariant,
              width: highlight
                  ? AppTokens.componentSize.dividerThick
                  : AppTokens.componentSize.dividerThin,
            ),
            boxShadow: highlight
                ? [
                    BoxShadow(
                      color: highlightColor!.withValues(alpha: AppOpacity.medium),
                      blurRadius: AppTokens.shadow.lg,
                      spreadRadius: AppTokens.componentSize.divider,
                    ),
                  ]
                : isDark
                    ? null
                    : [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: AppOpacity.faint),
                          blurRadius: AppTokens.shadow.sm,
                          offset: AppShadowOffset.xs,
                        ),
                      ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: AppTokens.componentSize.badgeLg,
                width: AppTokens.componentSize.badgeLg,
                child: Transform.scale(
                  scale: AppScale.enlarged,
                  child: Checkbox(
                    value: isDone,
                    onChanged: (value) {
                      if (value == null) return;
                      onToggle(!value);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTokens.radius.sm,
                    ),
                    side: BorderSide(
                      color: colors.primary.withValues(alpha: AppOpacity.subtle),
                      width: AppTokens.componentSize.dividerThick,
                    ),
                    activeColor: colors.primary,
                  ),
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: AppTokens.typography.subtitle.copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                        letterSpacing: AppLetterSpacing.compact,
                        color: isDone ? colors.onSurfaceVariant : colors.onSurface,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (details.isNotEmpty) ...[
                      SizedBox(height: spacing.xsPlus),
                      Text(
                        details,
                        style: AppTokens.typography.bodySecondary.copyWith(
                          color: colors.onSurfaceVariant
                              .withValues(alpha: AppOpacity.muted),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: spacing.md),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: AppTokens.iconSize.xs,
                          color: colors.onSurfaceVariant
                              .withValues(alpha: AppOpacity.muted),
                        ),
                        SizedBox(width: spacing.xsPlus),
                        Expanded(
                          child: Text(
                            dueLabel,
                            style: AppTokens.typography.caption.copyWith(
                              color: colors.onSurfaceVariant
                                  .withValues(alpha: AppOpacity.prominent),
                              fontWeight: AppTokens.fontWeight.medium,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (showQueuedBadge) ...[
                SizedBox(width: spacing.md),
                SizedBox(
                  width: AppTokens.componentSize.badgeMd,
                  height: AppTokens.componentSize.badgeMd,
                  child: CircularProgressIndicator(
                    strokeWidth: AppInteraction.progressStrokeWidth,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Slidable(
      key: ValueKey('dismiss-reminder-${entry.id}'),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: AppScale.slideExtent,
        children: [
          CustomSlidableAction(
            autoClose: true,
            padding: EdgeInsets.zero,
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.transparent,
            foregroundColor: colors.onError,
            child: Container(
              margin: EdgeInsets.only(left: spacing.sm),
              decoration: BoxDecoration(
                color: colors.error,
                borderRadius: AppTokens.radius.lg,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.delete_outline_rounded, color: colors.onError),
                  SizedBox(height: spacing.xs),
                  Text(
                    'Delete',
                    textAlign: TextAlign.center,
                    style: AppTokens.typography.label.copyWith(
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
    );
  }

  Future<void> _showDetails(BuildContext context) async {
    final media = MediaQuery.of(context);
    final spacing = AppTokens.spacing;
    await showOverlaySheet(
      context: context,
      alignment: Alignment.center,
      dimBackground: true,
      padding: spacing.edgeInsetsOnly(
        left: spacing.xl,
        right: spacing.xl,
        top: media.padding.top + spacing.xxl,
        bottom: media.padding.bottom + spacing.xxl,
      ),
      builder: (context) => ReminderDetailsSheet(
        entry: entry,
        isActive: !entry.isCompleted,
        onEdit: onEdit,
        onSnooze: onSnooze,
        onDelete: onDelete,
        onToggle: onToggle,
      ),
    );
  }
}

class ReminderStatusTag extends StatelessWidget {
  const ReminderStatusTag({super.key, required this.label, required this.tint});

  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = tint.withValues(
        alpha: isDark ? AppOpacity.darkTint : AppOpacity.statusBg);

    return Container(
      padding: AppTokens.spacing.edgeInsetsSymmetric(
        horizontal: AppTokens.spacing.sm + AppTokens.spacing.micro,
        vertical: AppTokens.spacing.xs + AppTokens.spacing.micro,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTokens.radius.lg,
      ),
      child: Text(
        label,
        style: AppTokens.typography.caption.copyWith(
          fontWeight: AppTokens.fontWeight.semiBold,
          color: tint,
        ),
      ),
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

class ReminderListCard extends StatefulWidget {
  const ReminderListCard({
    super.key,
    required this.groups,
    required this.timeFormat,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onSnooze,
    required this.queuedIds,
    required this.scope,
    required this.onScopeChanged,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.sortOption,
    required this.onSortChanged,
    this.highlightReminderId,
    this.reminderKeyBuilder,
  });

  final List<ReminderGroup> groups;
  final DateFormat timeFormat;
  final Future<void> Function(ReminderEntry entry, bool isActive) onToggle;
  final Future<void> Function(ReminderEntry entry) onEdit;
  final Future<void> Function(ReminderEntry entry) onDelete;
  final Future<void> Function(ReminderEntry entry) onSnooze;
  final Set<int> queuedIds;
  final ReminderScope scope;
  final ValueChanged<ReminderScope> onScopeChanged;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ReminderSortOption sortOption;
  final ValueChanged<ReminderSortOption> onSortChanged;
  /// ID of the reminder to highlight (newly added).
  final int? highlightReminderId;
  /// Callback to get a GlobalKey for a specific reminder ID, used for scroll-to.
  final GlobalKey Function(int reminderId)? reminderKeyBuilder;

  @override
  State<ReminderListCard> createState() => _ReminderListCardState();
}

class _ReminderListCardState extends State<ReminderListCard> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(ReminderListCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if parent changed the query (e.g., clear button pressed externally)
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: isDark
              ? colors.outline.withValues(alpha: AppOpacity.overlay)
              : colors.outline,
          width: isDark
              ? AppTokens.componentSize.divider
              : AppTokens.componentSize.dividerThin,
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
          // Header
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
                    color: colors.primary
                        .withValues(alpha: AppOpacity.borderEmphasis),
                    width: AppTokens.componentSize.dividerThick,
                  ),
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  color: colors.primary,
                  size: AppTokens.iconSize.xl,
                ),
              ),
              SizedBox(width: AppTokens.spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scheduled reminders',
                      style: AppTokens.typography.title.copyWith(
                        fontWeight: AppTokens.fontWeight.extraBold,
                        letterSpacing: AppLetterSpacing.tight,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: AppTokens.spacing.xs),
                    Text(
                      'Pinned headers keep each group visible.',
                      style: AppTokens.typography.bodySecondary.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: AppTokens.fontWeight.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.spacing.xl),

          // Scope filter pills
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ReminderScope>(
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  spacing.edgeInsetsSymmetric(
                    horizontal: spacing.md,
                    vertical: spacing.md,
                  ),
                ),
                side: WidgetStateProperty.resolveWith(
                  (states) => BorderSide(
                    color: states.contains(WidgetState.selected)
                        ? colors.primary
                        : colors.outline.withValues(alpha: AppOpacity.barrier),
                    width: AppTokens.componentSize.dividerMedium,
                  ),
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? colors.primary.withValues(alpha: AppOpacity.statusBg)
                      : colors.surfaceContainerHighest
                          .withValues(alpha: AppOpacity.barrier),
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? colors.primary
                      : colors.onSurfaceVariant
                          .withValues(alpha: AppOpacity.prominent),
                ),
              ),
              segments: ReminderScope.values.map((option) {
                return ButtonSegment<ReminderScope>(
                  value: option,
                  label: Text(
                    option.label,
                    softWrap: false,
                  ),
                );
              }).toList(),
              selected: <ReminderScope>{widget.scope},
              onSelectionChanged: (value) {
                if (value.isNotEmpty) widget.onScopeChanged(value.first);
              },
            ),
          ),
          SizedBox(height: spacing.lg),

          // Search bar
          TextField(
            controller: _searchController,
            style: AppTokens.typography.body.copyWith(
              color: colors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Search reminders...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: colors.surfaceContainerHigh,
              contentPadding: spacing.edgeInsetsSymmetric(
                horizontal: spacing.mdLg,
                vertical: spacing.md,
              ),
              border: OutlineInputBorder(
                borderRadius: AppTokens.radius.lg,
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: widget.onSearchChanged,
          ),
          SizedBox(height: spacing.md),

          // Sort dropdown
          Container(
            padding: spacing.edgeInsetsSymmetric(
              horizontal: spacing.mdLg,
              vertical: spacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: AppTokens.radius.lg,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ReminderSortOption>(
                value: widget.sortOption,
                isDense: true,
                isExpanded: true,
                icon: Icon(
                  Icons.sort_rounded,
                  size: AppTokens.iconSize.md,
                  color: colors.onSurfaceVariant,
                ),
                style: AppTokens.typography.body.copyWith(
                  color: colors.onSurface,
                ),
                dropdownColor: isDark ? colors.surfaceContainerHigh : colors.surface,
                borderRadius: AppTokens.radius.lg,
                items: ReminderSortOption.values
                    .map((opt) => DropdownMenuItem(
                          value: opt,
                          child: Text(opt.label),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) widget.onSortChanged(value);
                },
              ),
            ),
          ),
          SizedBox(height: AppTokens.spacing.xxl),

          // Groups or empty state
          if (widget.groups.isEmpty)
            _buildEmptyState(context)
          else
            for (var g = 0; g < widget.groups.length; g++) ...[
              _buildGroupHeader(context, widget.groups[g]),
              SizedBox(height: AppTokens.spacing.md),
              for (var i = 0; i < widget.groups[g].items.length; i++) ...[
                Builder(builder: (context) {
                  final item = widget.groups[g].items[i];
                  final isHighlighted = widget.highlightReminderId == item.id;
                  return ReminderRow(
                    key: widget.reminderKeyBuilder?.call(item.id),
                    entry: item,
                    timeFormat: widget.timeFormat,
                    onToggle: (v) => widget.onToggle(item, v),
                    onEdit: () => widget.onEdit(item),
                    onDelete: () => widget.onDelete(item),
                    onSnooze: () => widget.onSnooze(item),
                    showQueuedBadge: widget.queuedIds.contains(item.id),
                    highlight: isHighlighted,
                  );
                }),
                if (i != widget.groups[g].items.length - 1)
                  SizedBox(
                      height: AppTokens.spacing.sm + AppTokens.spacing.micro),
              ],
              if (g != widget.groups.length - 1) SizedBox(height: AppTokens.spacing.xl),
            ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final title = switch (widget.scope) {
      ReminderScope.today => 'No reminders in this filter',
      ReminderScope.week => 'No reminders in this filter',
      ReminderScope.all => 'No reminders yet',
    };

    final subtitle = switch (widget.scope) {
      ReminderScope.today => 'Create or rescope to see reminders here.',
      ReminderScope.week => 'Create or rescope to see reminders here.',
      ReminderScope.all => 'Tap "New reminder" above to create one.',
    };

    return _EmptyHeroPlaceholder(
      icon: Icons.notifications_none_rounded,
      title: title,
      subtitle: subtitle,
    );
  }

  Widget _buildGroupHeader(BuildContext context, ReminderGroup group) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final label = group.label;
    final count = group.items.length;
    final spacing = AppTokens.spacing;

    return Container(
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
              label,
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
              '$count ${count == 1 ? 'reminder' : 'reminders'}',
              style: AppTokens.typography.caption.copyWith(
                fontWeight: AppTokens.fontWeight.bold,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
