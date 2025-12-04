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

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? colors.outline.withValues(alpha: 0.12) : const Color(0xFFE5E5E5),
          width: isDark ? 1 : 0.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
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
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: colors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminders',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 21,
                        letterSpacing: -0.5,
                        color: isDark ? colors.onSurface : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? colors.onSurfaceVariant.withValues(alpha: 0.75) : const Color(0xFF757575),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: SegmentedButton<ReminderScope>(
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
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
          const SizedBox(height: 16),
          _ReminderProgressPill(
            label: completionLabel,
            progress: completionProgress,
            color: isDark ? colors.onSurfaceVariant : const Color(0xFF616161),
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
              Padding(
                padding: EdgeInsets.only(top: AppTokens.spacing.xs),
                child: Center(
                  child: Text(
                    '+${pending.length - display.length} more pending reminder'
                    '${pending.length - display.length == 1 ? '' : 's'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
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
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
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
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final percent = (progress.clamp(0.0, 1.0) * 100).round();
    
    // Use neutral gray for the card, matching Schedule's "Completed" section
    final headerColor = colors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            headerColor.withValues(alpha: 0.10),
            headerColor.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: headerColor.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.track_changes_rounded,
              size: 18,
              color: headerColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                letterSpacing: -0.3,
                color: isDark ? colors.onSurface : const Color(0xFF1A1A1A),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$percent%',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
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
    final isDone = entry.isCompleted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? colors.outline.withValues(alpha: 0.12) : const Color(0xFFE5E5E5),
          width: 0.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 24,
            width: 24,
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
                  borderRadius: BorderRadius.circular(6),
                ),
                side: BorderSide(
                  color: colors.primary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                activeColor: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: -0.2,
                    color: isDone
                        ? (isDark ? colors.onSurfaceVariant : const Color(0xFF9E9E9E))
                        : (isDark ? colors.onSurface : const Color(0xFF1A1A1A)),
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.details?.isNotEmpty == true) ...[
                  const SizedBox(height: 6),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        dueLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                          fontSize: 13,
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
            const SizedBox(width: 12),
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
    );
  }
}
