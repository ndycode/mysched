// ignore_for_file: unused_element
part of 'dashboard_screen.dart';

class _DashboardReminderCard extends StatelessWidget {
  const _DashboardReminderCard({
    required this.reminders,
    required this.loading,
    required this.pendingActions,
    required this.formatDue,
    required this.onOpenReminders,
    required this.onAddReminder,
    required this.onToggle,
    required this.onSnooze,
    required this.scope,
    required this.onScopeChanged,
  });

  final List<ReminderEntry> reminders;
  final bool loading;
  final Set<int> pendingActions;
  final String Function(ReminderEntry) formatDue;
  final VoidCallback onOpenReminders;
  final VoidCallback onAddReminder;
  final void Function(ReminderEntry entry, bool completed) onToggle;
  final void Function(ReminderEntry entry) onSnooze;
  final ReminderScope scope;
  final ValueChanged<ReminderScope> onScopeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final now = DateTime.now();
    final scoped = reminders
        .where(
          (entry) => scope.includes(entry.dueAt.toLocal(), now),
        )
        .toList();
    final pending = scoped.where((entry) => !entry.isCompleted).toList()
      ..sort(
        (a, b) =>
            (a.snoozeUntil ?? a.dueAt).compareTo(b.snoozeUntil ?? b.dueAt),
      );
    final display =
        pending.take(AppDisplayLimits.reminderPreviewCount).toList();
    final total = scoped.length;
    final completedCount = scoped.length - pending.length;
    final completionLabel = reminders.isEmpty
        ? 'No reminders yet'
        : total == 0
            ? 'No reminders in this filter'
            : '$completedCount of $total done';
    final completionProgress =
        total == 0 ? 0.0 : (completedCount.clamp(0, total) / total.toDouble());
    final subtitle = loading
        ? 'Refreshing reminders...'
        : reminders.isEmpty
            ? 'Tap Add to plan your next task.'
            : total == 0
                ? 'Nothing scheduled here. Expand the scope.'
                : pending.isEmpty
                    ? 'Everything is complete. Nice work!'
                    : 'Keep tasks ahead of schedule.';

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
                  Icons.check_circle_outline_rounded,
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
                      'Reminders',
                      style: AppTokens.typography.title.copyWith(
                        fontWeight: AppTokens.fontWeight.extraBold,
                        letterSpacing: AppLetterSpacing.tight,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      subtitle,
                      style: AppTokens.typography.bodySecondary.copyWith(
                        color: palette.muted,
                        fontWeight: AppTokens.fontWeight.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          SegmentedPills<ReminderScope>(
            value: scope,
            options: ReminderScope.values,
            onChanged: onScopeChanged,
            labelBuilder: (option) => option.label,
          ),
          SizedBox(height: spacing.md),
          _ReminderProgressPill(
            label: completionLabel,
            progress: completionProgress,
            color: palette.muted,
          ),
          SizedBox(height: spacing.md),
          if (display.isEmpty) ...[
            EmptyHeroPlaceholder(
              icon: Icons.notifications_none_rounded,
              title: total == 0
                  ? 'No reminders in this filter'
                  : 'All reminders complete',
              subtitle: total == 0
                  ? 'Create or rescope to see reminders here.'
                  : 'Everything is done. Great work!',
            ),
          ] else ...[
            ...display.map((entry) => Padding(
                  padding: spacing.edgeInsetsOnly(bottom: spacing.md),
                  child: _DashboardReminderTile(
                    entry: entry,
                    pendingAction: pendingActions.contains(entry.id),
                    dueLabel: formatDue(entry),
                    onToggle: onToggle,
                    onSnooze: onSnooze,
                  ),
                )),
            if (pending.length > display.length)
              Padding(
                padding: spacing.edgeInsetsOnly(top: spacing.xs),
                child: Center(
                  child: Text(
                    '+${pending.length - display.length} more pending reminder'
                    '${pending.length - display.length == 1 ? '' : 's'}',
                    style: AppTokens.typography.bodySecondary.copyWith(
                      color: colors.primary,
                      fontWeight: AppTokens.fontWeight.semiBold,
                    ),
                  ),
                ),
              ),
          ],
          SizedBox(height: spacing.lg),
          _ReminderActions(
            onAddReminder: onAddReminder,
            onOpenReminders: onOpenReminders,
            colors: colors,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _ReminderActions extends StatelessWidget {
  const _ReminderActions({
    required this.onAddReminder,
    required this.onOpenReminders,
    required this.colors,
    required this.theme,
  });

  final VoidCallback onAddReminder;
  final VoidCallback onOpenReminders;
  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;

    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            label: 'Add reminder',
            onPressed: onAddReminder,
            minHeight: AppTokens.componentSize.buttonMd,
            expanded: true,
          ),
        ),
        SizedBox(width: spacing.md),
        Expanded(
          child: SecondaryButton(
            label: 'Reminders',
            onPressed: onOpenReminders,
            minHeight: AppTokens.componentSize.buttonMd,
            expanded: true,
          ),
        ),
      ],
    );
  }
}

class _ReminderProgressPill extends StatelessWidget {
  const _ReminderProgressPill({
    required this.label,
    required this.progress,
    required this.color,
  });

  final String label;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final percent = (progress.clamp(0.0, 1.0) * 100).round();

    // Use the passed color parameter for the card
    final headerColor = color;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            headerColor.withValues(alpha: AppOpacity.dim),
            headerColor.withValues(alpha: AppOpacity.veryFaint),
          ],
        ),
        borderRadius: AppTokens.radius.md,
        border: Border.all(
          color: headerColor.withValues(alpha: AppOpacity.accent),
          width: AppTokens.componentSize.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: spacing.edgeInsetsAll(spacing.sm),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: AppOpacity.medium),
              borderRadius: AppTokens.radius.sm,
            ),
            child: Icon(
              Icons.track_changes_rounded,
              size: AppTokens.iconSize.sm,
              color: headerColor,
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
              horizontal: spacing.smMd,
              vertical: spacing.xsPlus,
            ),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: AppOpacity.overlay),
              borderRadius: AppTokens.radius.sm,
            ),
            child: Text(
              '$percent%',
              style: AppTokens.typography.caption.copyWith(
                fontWeight: AppTokens.fontWeight.bold,
                color: headerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardReminderTile extends StatelessWidget {
  const _DashboardReminderTile({
    required this.entry,
    required this.pendingAction,
    required this.dueLabel,
    required this.onToggle,
    required this.onSnooze,
  });

  final ReminderEntry entry;
  final bool pendingAction;
  final String dueLabel;
  final void Function(ReminderEntry entry, bool completed) onToggle;
  final void Function(ReminderEntry entry) onSnooze;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final isDone = entry.isCompleted;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.lg),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: colors.outlineVariant,
          width: AppTokens.componentSize.dividerThin,
        ),
        boxShadow: isDark
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
                onChanged: pendingAction
                    ? null
                    : (value) {
                        if (value == null) return;
                        onToggle(entry, value);
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
                    color: isDone ? palette.muted : colors.onSurface,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.details?.isNotEmpty == true) ...[
                  SizedBox(height: spacing.xsPlus),
                  Text(
                    entry.details!,
                    style: AppTokens.typography.bodySecondary.copyWith(
                      color: palette.muted
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
                      color: palette.muted
                          .withValues(alpha: AppOpacity.muted),
                    ),
                    SizedBox(width: spacing.xsPlus),
                    Expanded(
                      child: Text(
                        dueLabel,
                        style: AppTokens.typography.caption.copyWith(
                          color: palette.muted
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
          if (pendingAction) ...[
            SizedBox(width: spacing.md),
            SizedBox(
              width: AppTokens.componentSize.badgeMd,
              height: AppTokens.componentSize.badgeMd,
              child: CircularProgressIndicator(
                  strokeWidth: AppInteraction.progressStrokeWidth),
            ),
          ],
        ],
      ),
    );
  }
}
