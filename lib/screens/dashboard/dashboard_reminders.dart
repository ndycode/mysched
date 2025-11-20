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

    final cardBackground = elevatedCardBackground(theme);
    final cardBorder = elevatedCardBorder(theme);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 22,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminders',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.78),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReminderScope.values.map((option) {
              final selected = option == scope;
              return ChoiceChip(
                label: Text(option.label),
                selected: selected,
                onSelected: (value) {
                  if (value) onScopeChanged(option);
                },
                selectedColor: colors.primary.withValues(alpha: 0.18),
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
                backgroundColor:
                    colors.surfaceContainerHigh.withValues(alpha: 0.5),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _ReminderProgressPill(
            label: completionLabel,
            progress: completionProgress,
            color: colors.primary,
          ),
          const SizedBox(height: 16),
          if (loading && reminders.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (display.isEmpty)
            Text(
              total == 0
                  ? 'Create a reminder to stay on top of tasks.'
                  : 'All reminders are complete. Enjoy the calm!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.78),
                fontSize: 16,
              ),
            )
          else ...[
            ...display.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DashboardReminderTile(
                    entry: entry,
                    pendingAction: pendingActions.contains(entry.id),
                    dueLabel: formatDue(entry),
                    onToggle: onToggle,
                    onSnooze: onSnooze,
                  ),
                )),
            if (pending.length > display.length)
              Text(
                '+${pending.length - display.length} more pending reminder'
                '${pending.length - display.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: kSummaryMuted,
                  fontSize: 14,
                ),
              ),
          ],
          const SizedBox(height: 20),
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
    Widget buildAddButton() {
      return FilledButton.icon(
        onPressed: onAddReminder,
        icon: const Icon(Icons.add_alarm_rounded, size: 18),
        label: const Text('Add reminder'),
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.radius.xl,
          ),
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    Widget buildManageButton() {
      return OutlinedButton.icon(
        onPressed: onOpenReminders,
        icon: const Icon(Icons.launch_rounded, size: 18),
        label: const Text('Manage list'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.radius.xl,
          ),
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
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
              const SizedBox(width: 12),
              Expanded(child: manageButton),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            addButton,
            const SizedBox(height: 10),
            manageButton,
          ],
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
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
    final clamped = progress.clamp(0.0, 1.0);
    final indicatorColor = color;
    final isDark = theme.brightness == Brightness.dark;
    final baseStart =
        isDark ? color.withValues(alpha: 0.28) : color.withValues(alpha: 0.18);
    final baseEnd =
        isDark ? color.withValues(alpha: 0.14) : color.withValues(alpha: 0.08);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: clamped),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final percent = (value * 100).round();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [baseStart, baseEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppTokens.radius.lg,
            border: Border.all(color: indicatorColor.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: indicatorColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.track_changes_rounded,
                      size: 16,
                      color: indicatorColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: indicatorColor,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percent%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: indicatorColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 4,
                  color: indicatorColor,
                  backgroundColor: indicatorColor.withValues(alpha: 0.24),
                ),
              ),
            ],
          ),
        );
      },
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
    final isDone = entry.isCompleted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 44,
            width: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 1.05,
                  child: Checkbox(
                    value: isDone,
                    onChanged: pendingAction
                        ? null
                        : (value) {
                            if (value == null) return;
                            onToggle(entry, value);
                          },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.details?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.details!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.72),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        dueLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: pendingAction
                            ? null
                            : () => onToggle(entry, !isDone),
                        icon: Icon(
                          isDone ? Icons.undo_rounded : Icons.done_all_rounded,
                          size: 18,
                        ),
                        label: Text(isDone ? 'Mark pending' : 'Mark done'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppTokens.radius.md,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: pendingAction || isDone
                            ? null
                            : () => onSnooze(entry),
                        icon: const Icon(Icons.snooze_rounded, size: 18),
                        label: const Text('Snooze 1h'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppTokens.radius.md,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (pendingAction) ...[
            const SizedBox(width: 14),
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
    );
  }
}
