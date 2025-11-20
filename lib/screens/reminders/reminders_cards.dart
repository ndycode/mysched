part of 'reminders_screen.dart';

class _ReminderGroupSliver extends StatelessWidget
    implements ScreenShellSliver {
  const _ReminderGroupSliver({
    required this.header,
    required this.group,
    required this.timeFormat,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onSnooze,
    this.showHeader = true,
  });

  final Widget header;
  final _ReminderGroup group;
  final DateFormat timeFormat;
  final Future<void> Function(ReminderEntry entry, bool isActive) onToggle;
  final Future<void> Function(ReminderEntry entry) onEdit;
  final Future<void> Function(ReminderEntry entry) onDelete;
  final Future<void> Function(ReminderEntry entry) onSnooze;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return ScreenStickyGroup(
      header: header,
      child: _ReminderGroupCard(
        group: group,
        timeFormat: timeFormat,
        onToggle: onToggle,
        onEdit: onEdit,
        onDelete: onDelete,
        onSnooze: onSnooze,
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final background = elevatedCardBackground(theme);
    final isDark = theme.brightness == Brightness.dark;
    final radius = AppTokens.radius.xl;

    Widget buildRow(int index) {
      final entry = group.items[index];
      final isLast = index == group.items.length - 1;
      final isFirst = index == 0;
      final borderRadius = BorderRadius.only(
        topLeft: isFirst ? radius.topLeft : Radius.zero,
        topRight: isFirst ? radius.topRight : Radius.zero,
        bottomLeft: isLast ? radius.bottomLeft : Radius.zero,
        bottomRight: isLast ? radius.bottomRight : Radius.zero,
      );

      return RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: borderRadius,
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.24),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: colors.outline.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 14),
                ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            18,
          ),
          child: Column(
            children: [
              _ReminderRow(
                entry: entry,
                timeFormat: timeFormat,
                onToggle: (value) => onToggle(entry, value),
                onEdit: () => onEdit(entry),
                onDelete: () => onDelete(entry),
                onSnooze: () => onSnooze(entry),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Divider(
                    color: colors.outlineVariant.withValues(alpha: 0.25),
                    height: 0,
                    thickness: 1,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return [
      SliverPadding(
        padding: horizontalPadding,
        sliver: SliverPersistentHeader(
          pinned: false,
          delegate: _PinnedHeaderDelegate(
            height: 56,
            maxWidth: maxWidth,
            backgroundColor: colors.surface,
            child: header,
          ),
        ),
      ),
      SliverPadding(
        padding: horizontalPadding,
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: buildRow(index),
              ),
            ),
            childCount: group.items.length,
          ),
        ),
      ),
    ];
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.summary,
    required this.now,
    required this.onCreate,
    required this.onToggleCompleted,
    required this.showCompleted,
    this.menuButton,
    required this.scope,
    required this.onScopeChanged,
  });

  final _ReminderSummary summary;
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
    final cardBackground = elevatedCardBackground(theme);
    final borderColor = elevatedCardBorder(theme);

    final card = CardX(
      padding: const EdgeInsets.all(20),
      backgroundColor: cardBackground,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminders overview',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM d').format(now),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (menuButton != null) ...[
                const SizedBox(width: 4),
                SizedBox(
                  height: 36,
                  width: 36,
                  child: Center(child: menuButton!),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          if (highlight != null) ...[
            _ReminderHighlightHero(highlight: highlight, now: now),
            const SizedBox(height: 18),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: AppTokens.radius.lg,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All caught up. Create a new reminder to get started.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          RepaintBoundary(
            child: Wrap(
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
                  selectedColor: colors.primary.withValues(alpha: 0.2),
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: selected ? colors.primary : colors.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  backgroundColor:
                      colors.surfaceContainerHighest.withValues(alpha: 0.4),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ReminderMetricChip(
                  icon: Icons.pending_actions_rounded,
                  tint: colors.primary,
                  label: 'Pending',
                  value: summary.pending,
                  caption: '${summary.total} total',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReminderMetricChip(
                  icon: Icons.warning_amber_rounded,
                  tint: colors.error,
                  label: 'Overdue',
                  value: summary.overdue,
                  caption: summary.overdue == 0
                      ? 'On schedule'
                      : '${summary.overdue} to tackle',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReminderMetricChip(
                  icon: Icons.snooze_rounded,
                  tint: colors.secondary,
                  label: 'Snoozed',
                  value: summary.snoozed,
                  caption:
                      summary.snoozed == 0 ? 'All active' : 'Taking a break',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onCreate,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTokens.radius.xl,
                    ),
                  ),
                  child: const Text('New reminder'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onToggleCompleted,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTokens.radius.xl,
                    ),
                  ),
                  child:
                      Text(showCompleted ? 'Hide completed' : 'Show completed'),
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

class _ReminderHighlightHero extends StatelessWidget {
  const _ReminderHighlightHero({
    required this.highlight,
    required this.now,
  });

  final _ReminderHighlight highlight;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final entry = highlight.entry;
    final target = highlight.targetTime;
    final label = switch (highlight.status) {
      _ReminderHighlightStatus.overdue => 'Overdue',
      _ReminderHighlightStatus.snoozed => 'Snoozed',
      _ReminderHighlightStatus.upcoming => 'Next reminder',
    };
    final labelIcon = switch (highlight.status) {
      _ReminderHighlightStatus.overdue => Icons.report_problem_rounded,
      _ReminderHighlightStatus.snoozed => Icons.snooze_rounded,
      _ReminderHighlightStatus.upcoming => Icons.arrow_forward_rounded,
    };
    final badgeIcon = switch (highlight.status) {
      _ReminderHighlightStatus.overdue => Icons.warning_amber_rounded,
      _ReminderHighlightStatus.snoozed => Icons.alarm_on_rounded,
      _ReminderHighlightStatus.upcoming => Icons.flash_on_rounded,
    };
    final badgeLabel = switch (highlight.status) {
      _ReminderHighlightStatus.overdue => 'Action needed',
      _ReminderHighlightStatus.snoozed => 'Snoozed',
      _ReminderHighlightStatus.upcoming => 'Next',
    };
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = colors.primary;
    final gradient = [
      baseColor.withValues(alpha: isDark ? 0.85 : 0.95),
      baseColor.withValues(alpha: isDark ? 0.65 : 0.7),
    ];
    final shadowColor = baseColor.withValues(alpha: isDark ? 0.32 : 0.22);
    final foreground = colors.onPrimary;
    final scheduleWindow = DateFormat("EEE, MMM d 'at' h:mm a")
        .format(target)
        .replaceAll('\u202f', ' ');
    final subtitle = _formatRelativeDuration(target.difference(now)) ??
        (highlight.status == _ReminderHighlightStatus.overdue
            ? 'Just overdue'
            : 'Due soon');
    final title =
        entry.title.trim().isEmpty ? 'Upcoming reminder' : entry.title.trim();
    final details = entry.details?.trim() ?? '';

    return Container(
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
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ReminderHeroChip(
                icon: labelIcon,
                label: label,
                background: foreground.withValues(alpha: 0.16),
                foreground: foreground.withValues(alpha: 0.9),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: foreground.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      badgeIcon,
                      size: 18,
                      color: foreground.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      badgeLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: foreground.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: foreground,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: foreground.withValues(alpha: 0.78),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  scheduleWindow,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.hourglass_bottom_rounded,
                size: 14,
                color: foreground.withValues(alpha: 0.75),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground.withValues(alpha: 0.78),
                  ),
                ),
              ),
            ],
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              details,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: foreground.withValues(alpha: 0.82),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
    return 'Due in $formatted';
  }
}

class _ReminderHeroChip extends StatelessWidget {
  const _ReminderHeroChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

class _ReminderMetricChip extends StatelessWidget {
  const _ReminderMetricChip({
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
    final isDark = theme.brightness == Brightness.dark;
    final background = tint.withValues(alpha: isDark ? 0.20 : 0.10);
    final border = tint.withValues(alpha: isDark ? 0.28 : 0.18);
    final iconBackground = tint.withValues(alpha: isDark ? 0.22 : 0.16);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTokens.radius.lg,
        border: Border.all(color: border),
      ),
      constraints: const BoxConstraints(minHeight: 132),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 18,
              color: tint.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'SFProRounded',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
              fontSize: 14,
            ),
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    );
  }
}

class _ReminderGroupCard extends StatelessWidget {
  const _ReminderGroupCard({
    required this.group,
    required this.timeFormat,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onSnooze,
    this.showHeader = true,
  });

  final _ReminderGroup group;
  final DateFormat timeFormat;
  final Future<void> Function(ReminderEntry entry, bool isActive) onToggle;
  final Future<void> Function(ReminderEntry entry) onEdit;
  final Future<void> Function(ReminderEntry entry) onDelete;
  final Future<void> Function(ReminderEntry entry) onSnooze;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cardBackground = elevatedCardBackground(theme);
    final borderColor = elevatedCardBorder(theme);

    return CardX(
      backgroundColor: cardBackground,
      borderColor: borderColor,
      padding: const EdgeInsets.all(20),
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${group.items.length} reminder${group.items.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          ...List.generate(
            group.items.length,
            (index) => _ReminderRow(
              entry: group.items[index],
              timeFormat: timeFormat,
              onToggle: (value) => onToggle(group.items[index], value),
              onEdit: () => onEdit(group.items[index]),
              onDelete: () => onDelete(group.items[index]),
              onSnooze: () => onSnooze(group.items[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.entry,
    required this.timeFormat,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onSnooze,
  });

  final ReminderEntry entry;
  final DateFormat timeFormat;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSnooze;

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

    final primaryText = isActive ? colors.onSurface : colors.outline;
    final secondaryText = colors.onSurfaceVariant;

    final tags = <Widget>[];
    if (!isActive) {
      tags.add(
        const _StatusTag(
          label: 'Completed',
          tint: Color(0xFF4CAF50),
        ),
      );
    } else if (snoozeUntil != null) {
      tags.add(
        const _StatusTag(
          label: 'Snoozed',
          tint: Color(0xFFFB8C00),
        ),
      );
    } else if (isOverdue) {
      tags.add(
        _StatusTag(
          label: 'Overdue',
          tint: colors.error,
        ),
      );
    }

    final containerColor = isOverdue
        ? colors.error.withValues(alpha: 0.1)
        : colors.surfaceContainerHigh;
    final borderColor = isOverdue
        ? colors.error.withValues(alpha: 0.3)
        : colors.outline.withValues(alpha: 0.12);
    final pillAccent = !isActive
        ? colors.outline
        : isOverdue
            ? colors.error
            : colors.primary;

    return InkWell(
      onTap: onEdit,
      onLongPress: () => _showActions(context),
      borderRadius: AppTokens.radius.lg,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: AppTokens.radius.lg,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReminderDatePill(
              date: localDue,
              accent: pillAccent,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (tags.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: tags,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                  if (details.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        details,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: secondaryText,
                        ),
                      ),
                    ),
                  if (snoozeUntil != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Snoozed until ${DateFormat('h:mm a').format(snoozeUntil)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: secondaryText,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      label: entry.title,
                      hint: isActive ? 'Mark as done' : 'Move back to pending',
                      toggled: isActive,
                      child: Switch.adaptive(
                        value: isActive,
                        onChanged: onToggle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _MenuButton(
                      onEdit: onEdit,
                      onSnooze: onSnooze,
                      onDelete: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final action = await showModalBottomSheet<_ReminderRowAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReminderActionsSheet(entry: entry),
    );
    switch (action) {
      case _ReminderRowAction.edit:
        onEdit();
        break;
      case _ReminderRowAction.snooze:
        onSnooze();
        break;
      case _ReminderRowAction.delete:
        onDelete();
        break;
      case null:
        break;
    }
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.label, required this.tint});

  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = tint.withValues(alpha: isDark ? 0.22 : 0.16);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
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

class _ReminderDatePill extends StatelessWidget {
  const _ReminderDatePill({
    required this.date,
    required this.accent,
  });

  final DateTime date;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final weekday = DateFormat('EEE').format(date).toUpperCase();
    final formatted = DateFormat('MMM d').format(date);
    final baseColor = accent.withValues(alpha: 0.14);
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            weekday,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: accent,
                  letterSpacing: 0.6,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            formatted,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}
