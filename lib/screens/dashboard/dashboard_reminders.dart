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
    final display = pending.take(3).toList();
    final total = scoped.length;
    final completedCount = scoped.length - pending.length;
    final completionLabel = reminders.isEmpty
        ? 'No reminders yet'
        : total == 0
            ? 'No reminders in this filter'
            : '$completedCount of $total done';
    final completionProgress = total == 0
        ? 0.0
        : (completedCount.clamp(0, total) / total.toDouble());
    final subtitle = loading
        ? 'Refreshing reminders...'
        : reminders.isEmpty
            ? 'Tap Add to plan your next task.'
            : total == 0
                ? 'Nothing scheduled here. Expand the scope.'
                : pending.isEmpty
                    ? 'Everything is complete. Nice work!'
                    : 'Keep tasks ahead of schedule.';

    return CardX(
      padding: spacing.edgeInsetsAll(spacing.xl),
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
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: AppTokens.typography.title.fontSize,
                        letterSpacing: -0.5,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: AppTokens.typography.bodySecondary.fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          Center(
            child: SegmentedButton<ReminderScope>(
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                padding: WidgetStateProperty.all(
                  spacing.edgeInsetsSymmetric(
                    horizontal: spacing.md,
                    vertical: spacing.sm,
                  ),
                ),
                side: WidgetStateProperty.resolveWith(
                  (states) => BorderSide(
                    color: states.contains(WidgetState.selected)
                        ? colors.primary
                        : colors.outline.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? colors.primary.withValues(alpha: 0.14)
                      : colors.surfaceContainerHighest.withValues(alpha: 0.45),
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? colors.primary
                      : colors.onSurfaceVariant.withValues(alpha: 0.9),
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
              selected: <ReminderScope>{scope},
              onSelectionChanged: (value) {
                if (value.isNotEmpty) onScopeChanged(value.first);
              },
            ),
          ),
          SizedBox(height: spacing.md),
          _ReminderProgressPill(
            label: completionLabel,
            progress: completionProgress,
            color: colors.onSurfaceVariant,
          ),
          SizedBox(height: spacing.md),
          if (loading && reminders.isEmpty)
            Center(
              child: Padding(
                padding: spacing.edgeInsetsSymmetric(vertical: spacing.sm),
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (display.isEmpty)
            Text(
              total == 0
                  ? 'Create a reminder to stay on top of tasks.'
                  : 'All reminders are complete. Enjoy the calm!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.78),
                fontSize: AppTokens.typography.body.fontSize,
              ),
            )
          else ...[
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: AppTokens.typography.bodySecondary.fontSize,
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
    Widget buildAddButton() {
      return PrimaryButton(
        icon: Icons.add_alarm_rounded,
        label: 'Add reminder',
        onPressed: onAddReminder,
        minHeight: AppTokens.componentSize.buttonMd,
        expanded: true,
      );
    }

    Widget buildManageButton() {
      return SecondaryButton(
        icon: Icons.launch_rounded,
        label: 'Manage list',
        onPressed: onOpenReminders,
        minHeight: AppTokens.componentSize.buttonMd,
        expanded: true,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 520;
        final addButton = buildAddButton();
        final manageButton = buildManageButton();

        if (isWide) {
          return Row(
            children: [
              Expanded(child: addButton),
              SizedBox(width: spacing.md),
              Expanded(child: manageButton),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            addButton,
            SizedBox(height: spacing.sm + 2),
            manageButton,
          ],
        );
      },
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
    
    // Use neutral gray for the card, matching Schedule's "Completed" section
    final headerColor = colors.onSurfaceVariant;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            headerColor.withValues(alpha: 0.10),
            headerColor.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: AppTokens.radius.md,
        border: Border.all(
          color: headerColor.withValues(alpha: 0.20),
          width: AppTokens.componentSize.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: spacing.edgeInsetsAll(spacing.sm),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.15),
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
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: AppTokens.typography.subtitle.fontSize,
                letterSpacing: -0.3,
                color: colors.onSurface,
              ),
            ),
          ),
          Container(
            padding: spacing.edgeInsetsSymmetric(
              horizontal: spacing.md,
              vertical: spacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.12),
              borderRadius: AppTokens.radius.sm,
            ),
            child: Text(
              '$percent%',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: AppTokens.typography.caption.fontSize,
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
    final spacing = AppTokens.spacing;
    final isDone = entry.isCompleted;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.lg),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: colors.outlineVariant,
          width: 0.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
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
              scale: 1.1,
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
                  color: colors.primary.withValues(alpha: 0.5),
                  width: 1.5,
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: AppTokens.typography.subtitle.fontSize,
                    letterSpacing: -0.2,
                    color: isDone
                        ? colors.onSurfaceVariant
                        : colors.onSurface,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.details?.isNotEmpty == true) ...[
                  SizedBox(height: spacing.xs + 2),
                  Text(
                    entry.details!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: AppTokens.typography.bodySecondary.fontSize,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.72),
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
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    SizedBox(width: spacing.xs + 2),
                    Expanded(
                      child: Text(
                        dueLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                          fontSize: AppTokens.typography.caption.fontSize,
                          fontWeight: FontWeight.w500,
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
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
    );
  }
}
