// ignore_for_file: unused_local_variable, unused_element
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../models/reminder_scope.dart';
import '../../services/reminders_api.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/card_styles.dart';
import '../../ui/kit/queued_badge.dart';
import '../../ui/kit/reminder_details_sheet.dart';
import '../../ui/theme/tokens.dart';
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
            width: spacing.quad + spacing.xxl,
            height: spacing.quad + spacing.xxl,
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

class ReminderSummaryCard extends StatelessWidget {
  const ReminderSummaryCard({
    super.key,
    required this.summary,
    required this.now,
    required this.onCreate,
    required this.onToggleCompleted,
    required this.showCompleted,
    this.menuButton,
    required this.scope,
    required this.onScopeChanged,
  });

  final ReminderSummary summary;
  final DateTime now;
  final VoidCallback onCreate;
  final VoidCallback onToggleCompleted;
  final bool showCompleted;
  final Widget? menuButton;
  final ReminderScope scope;
  final ValueChanged<ReminderScope> onScopeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final highlight = summary.highlight;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    final card = CardX(
      padding: spacing.edgeInsetsAll(spacing.xl),
      backgroundColor: isDark ? colors.surfaceContainerHigh : colors.surface,
      borderColor:
          isDark ? colors.outline.withValues(alpha: AppOpacity.overlay) : colors.outline,
      borderRadius: AppTokens.radius.xl,
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
                    color: isDark ? colors.onSurface : colors.onSurface,
                  ),
                ),
              ),
              if (menuButton != null) menuButton!,
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
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: SecondaryButton(
                  label: showCompleted ? 'Hide completed' : 'Show completed',
                  onPressed: onToggleCompleted,
                  minHeight: AppTokens.componentSize.buttonMd,
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
    final scheduleWindow = DateFormat("EEE, MMM d 'at' h:mm a")
        .format(target)
        .replaceAll('\u202f', ' ');
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
                background: foreground.withValues(alpha: AppOpacity.accent),
                foreground: foreground,
              ),
              SizedBox(width: spacing.md),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: AppTokens.typography.bodySecondary.copyWith(
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
          SizedBox(height: spacing.lg + spacing.xs),
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
                child: Text(
                  scheduleWindow,
                  style: AppTokens.typography.body.copyWith(
                    color: foreground,
                    fontWeight: AppTokens.fontWeight.semiBold,
                  ),
                ),
              ),
            ],
          ),
          if (details.isNotEmpty) ...[
            SizedBox(height: spacing.md + spacing.xs),
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
                    style: AppTokens.typography.bodySecondary.copyWith(
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
    final hours = positive.inHours;
    final minutes = positive.inMinutes % 60;
    final parts = <String>[];
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
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
    final cardBackground = elevatedCardBackground(theme);
    final borderColor = elevatedCardBorder(theme);
    final queuedCount =
        group.items.where((item) => queuedIds.contains(item.id)).length;

    return CardX(
      backgroundColor: cardBackground,
      borderColor: borderColor,
      padding: AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppTokens.fontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${group.items.length} reminder${group.items.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: AppTokens.fontWeight.medium,
                  ),
                ),
                AnimatedSwitcher(
                  duration: AppTokens.motion.fast,
                  child: queuedCount > 0
                      ? Padding(
                          key: ValueKey('queued-$queuedCount'),
                          padding:
                              EdgeInsets.only(left: AppTokens.spacing.sm),
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
                              style: theme.textTheme.labelSmall?.copyWith(
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
  });

  final ReminderEntry entry;
  final DateFormat timeFormat;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSnooze;
  final bool showQueuedBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final localDue = entry.dueAt.toLocal();
    final timeLabel = timeFormat.format(localDue);
    final details = (entry.details ?? '').trim();
    final snoozeUntil = entry.snoozeUntil?.toLocal();
    final isActive = !entry.isCompleted;
    final isOverdue =
        isActive && snoozeUntil == null && localDue.isBefore(DateTime.now());

    final palette = theme.brightness == Brightness.dark
        ? AppTokens.darkColors
        : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    
    // Build tags
    final tags = <Widget>[];
    if (showQueuedBadge) {
      tags.add(
        AnimatedSwitcher(
          duration: AppTokens.motion.fast,
          child: const QueuedBadge(key: ValueKey('queued-tag')),
        ),
      );
    }
    if (!isActive) {
      tags.add(
        ReminderStatusTag(
          label: 'Completed',
          tint: palette.positive,
        ),
      );
    } else if (snoozeUntil != null) {
      tags.add(
        ReminderStatusTag(
          label: 'Snoozed',
          tint: palette.warning,
        ),
      );
    } else if (isOverdue) {
      tags.add(
        ReminderStatusTag(
          label: 'Overdue',
          tint: colors.error,
        ),
      );
    }

    // Build metadata items
    final metadata = <MetadataItem>[
      MetadataItem(icon: Icons.access_time_rounded, label: timeLabel),
      if (details.isNotEmpty)
        MetadataItem(icon: Icons.notes_rounded, label: details, expanded: true),
    ];

    // Build trailing toggle
    final trailing = Semantics(
      label: entry.title,
      hint: isActive ? 'Mark as done' : 'Move back to pending',
      toggled: isActive,
      child: Transform.scale(
        scale: AppScale.dense,
        child: Switch.adaptive(
          value: isActive,
          onChanged: onToggle,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );

    // Build snooze info as bottom content
    Widget? bottomContent;
    if (snoozeUntil != null) {
      bottomContent = Row(
        children: [
          Icon(
            Icons.snooze_rounded,
            size: AppTokens.iconSize.xs,
            color: palette.warning,
          ),
          SizedBox(width: spacing.sm),
          Text(
            'Snoozed until ${DateFormat('h:mm a').format(snoozeUntil)}',
            style: AppTokens.typography.caption.copyWith(
              color: palette.warning,
              fontWeight: AppTokens.fontWeight.semiBold,
            ),
          ),
        ],
      );
    }

    final child = EntityTile(
      title: entry.title,
      isActive: isActive,
      isStrikethrough: !isActive,
      isHighlighted: isActive,
      metadata: metadata,
      tags: tags,
      trailing: trailing,
      bottomContent: bottomContent,
      onTap: () => _showDetails(context),
      borderRadius: AppTokens.radius.lg,
    );

    return ClipRRect(
      borderRadius: AppTokens.radius.md,
      child: Slidable(
        key: ValueKey('dismiss-reminder-${entry.id}'),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: AppScale.slideExtentNarrow,
          children: [
            CustomSlidableAction(
              onPressed: (context) => _handleDelete(context),
              backgroundColor: colors.shadow.withValues(alpha: 0),
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

  Future<void> _handleDelete(BuildContext context) async {
    final confirm = await AppModal.showConfirmDialog(
      context: context,
      title: 'Delete reminder?',
      message: 'This reminder will be permanently removed.',
      confirmLabel: 'Delete',
      isDanger: true,
    );
    if (confirm == true) {
      onDelete();
    }
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
    final background = tint.withValues(alpha: isDark ? AppOpacity.darkTint : AppOpacity.statusBg);

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
        style: theme.textTheme.bodySmall?.copyWith(
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



class ReminderListCard extends StatelessWidget {
  const ReminderListCard({
    super.key,
    required this.groups,
    required this.timeFormat,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onSnooze,
    required this.queuedIds,
  });

  final List<ReminderGroup> groups;
  final DateFormat timeFormat;
  final Future<void> Function(ReminderEntry entry, bool isActive) onToggle;
  final Future<void> Function(ReminderEntry entry) onEdit;
  final Future<void> Function(ReminderEntry entry) onDelete;
  final Future<void> Function(ReminderEntry entry) onSnooze;
  final Set<int> queuedIds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    return CardX(
      padding: spacing.edgeInsetsAll(spacing.xl),
      backgroundColor: isDark ? colors.surfaceContainerHigh : colors.surface,
      borderColor:
          isDark ? colors.outline.withValues(alpha: AppOpacity.overlay) : colors.outline,
      borderRadius: AppTokens.radius.xl,
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
                    color: colors.primary.withValues(alpha: AppOpacity.borderEmphasis),
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
                      style: AppTokens.typography.headline.copyWith(
                        fontWeight: AppTokens.fontWeight.extraBold,
                        letterSpacing: AppLetterSpacing.tight,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: AppTokens.spacing.xs),
                    Text(
                      'Pinned headers keep each group visible.',
                      style: AppTokens.typography.bodySecondary.copyWith(
                        color: colors.onSurfaceVariant.withValues(alpha: AppOpacity.tertiary),
                        fontWeight: AppTokens.fontWeight.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.spacing.xxl),

          // Groups
          for (var g = 0; g < groups.length; g++) ...[
            _buildGroupHeader(context, groups[g]),
            SizedBox(height: AppTokens.spacing.md),
            for (var i = 0; i < groups[g].items.length; i++) ...[
              ReminderRow(
                entry: groups[g].items[i],
                timeFormat: timeFormat,
                onToggle: (v) => onToggle(groups[g].items[i], v),
                onEdit: () => onEdit(groups[g].items[i]),
                onDelete: () => onDelete(groups[g].items[i]),
                onSnooze: () => onSnooze(groups[g].items[i]),
                showQueuedBadge: queuedIds.contains(groups[g].items[i].id),
              ),
              if (i != groups[g].items.length - 1) SizedBox(height: AppTokens.spacing.md),
            ],
            if (g != groups.length - 1) SizedBox(height: AppTokens.spacing.xl),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupHeader(BuildContext context, ReminderGroup group) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final label = group.label;
    final count = group.items.length;

    final isOverdue = label.toLowerCase().contains('overdue');
    final isToday = label.toLowerCase().contains('today');

    final baseColor = isOverdue
        ? colors.error
        : (isToday ? colors.primary : colors.surfaceContainerHighest);

    final icon = isOverdue
        ? Icons.warning_amber_rounded
        : (isToday ? Icons.today_rounded : Icons.event_note_rounded);

    final gradientColors = isOverdue
        ? [
            colors.error.withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.dim),
            colors.error.withValues(alpha: isDark ? AppOpacity.dim : AppOpacity.faint),
          ]
        : isToday
            ? [
                colors.primary.withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.dim),
                colors.primary.withValues(alpha: isDark ? AppOpacity.dim : AppOpacity.faint),
              ]
            : [
                isDark ? colors.surfaceContainerHighest : colors.surfaceContainerHigh,
                isDark ? colors.surfaceContainerHigh : colors.surfaceContainer,
              ];

    final borderColor = isOverdue
        ? colors.error.withValues(alpha: AppOpacity.accent)
        : isToday
            ? colors.primary.withValues(alpha: AppOpacity.accent)
            : colors.outline.withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.ghost);

    final textColor = isOverdue
        ? colors.error
        : isToday
            ? colors.primary
            : colors.onSurfaceVariant;
    final spacing = AppTokens.spacing;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: AppTokens.radius.lg,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: spacing.edgeInsetsAll(spacing.sm),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: AppOpacity.medium),
              borderRadius: AppTokens.radius.md,
            ),
            child: Icon(
              icon,
              size: AppTokens.iconSize.sm,
              color: textColor,
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
              horizontal: spacing.md,
              vertical: spacing.sm,
            ),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: AppOpacity.overlay),
              borderRadius: AppTokens.radius.sm,
            ),
            child: Text(
              '$count ${count == 1 ? 'reminder' : 'reminders'}',
              style: AppTokens.typography.caption.copyWith(
                fontWeight: AppTokens.fontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
