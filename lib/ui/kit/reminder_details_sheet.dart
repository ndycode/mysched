import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/reminders_api.dart';
import '../theme/card_styles.dart';
import '../theme/tokens.dart';
import 'kit.dart';

class ReminderDetailsSheet extends StatefulWidget {
  const ReminderDetailsSheet({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onSnooze,
    required this.onDelete,
    required this.onToggle,
    required this.isActive,
  });

  final ReminderEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onSnooze;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;
  final bool isActive;

  @override
  State<ReminderDetailsSheet> createState() => _ReminderDetailsSheetState();
}

class _ReminderDetailsSheetState extends State<ReminderDetailsSheet> {
  bool _toggleBusy = false;
  bool _deleteBusy = false;

  Future<void> _handleToggle() async {
    if (_toggleBusy) return;
    setState(() => _toggleBusy = true);
    try {
      widget.onToggle(!widget.isActive);
    } finally {
      if (mounted) setState(() => _toggleBusy = false);
    }
  }

  Future<void> _handleDelete() async {
    if (_deleteBusy) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: const Text(
          'This reminder will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    setState(() => _deleteBusy = true);
    try {
      widget.onDelete();
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _deleteBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final cardBackground = elevatedCardBackground(theme, solid: true);
    final borderColor = elevatedCardBorder(theme, solid: true);
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * 0.78;
    final isDark = theme.brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: AppTokens.radius.xl,
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(
                alpha: isDark ? 0.32 : 0.18,
              ),
              blurRadius: 24,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: EdgeInsets.all(spacing.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Premium Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          Icons.notifications_active_rounded,
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
                              widget.entry.title,
                              style: AppTokens.typography.title.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                height: 1.2,
                                color: isDark ? colors.onSurface : const Color(0xFF1A1A1A),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppTokens.spacing.xs),
                            Text(
                              'Reminder details',
                              style: AppTokens.typography.bodySecondary.copyWith(
                                color: isDark ? colors.onSurfaceVariant.withValues(alpha: 0.75) : const Color(0xFF757575),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppTokens.spacing.md),
                      PressableScale(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.onSurface.withValues(alpha: 0.05),
                            borderRadius: AppTokens.radius.md,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: AppTokens.iconSize.md,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.xl),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tags
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _InfoChip(
                                icon: widget.isActive
                                    ? Icons.pending_actions_rounded
                                    : Icons.check_circle_outline_rounded,
                                label: widget.isActive ? 'Pending' : 'Completed',
                                color: widget.isActive
                                    ? colors.primary
                                    : colors.tertiary,
                              ),
                              if (widget.entry.isOverdue)
                                _InfoChip(
                                  icon: Icons.error_outline_rounded,
                                  label: 'Overdue',
                                  color: colors.error,
                                ),
                              if (widget.entry.isSnoozed)
                                _InfoChip(
                                  icon: Icons.snooze_rounded,
                                  label: 'Snoozed',
                                  color: colors.secondary,
                                ),
                            ],
                          ),
                          SizedBox(height: spacing.lg),

                          // Main Details Container
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? colors.surfaceContainerHighest.withValues(alpha: 0.3) 
                                  : colors.primary.withValues(alpha: 0.04),
                              borderRadius: AppTokens.radius.lg,
                              border: Border.all(
                                color: isDark 
                                    ? colors.outline.withValues(alpha: 0.12) 
                                    : colors.primary.withValues(alpha: 0.10),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                _DetailRow(
                                  icon: Icons.event_rounded,
                                  label: 'Due date',
                                  value: DateFormat.yMMMMd().add_jm().format(widget.entry.dueAt),
                                  isPremium: true,
                                ),
                                if (widget.entry.details != null && widget.entry.details!.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Divider(
                                      height: 1,
                                      color: isDark 
                                          ? colors.outline.withValues(alpha: 0.15) 
                                          : colors.primary.withValues(alpha: 0.10),
                                    ),
                                  ),
                                  _DetailRow(
                                    icon: Icons.notes_rounded,
                                    label: 'Details',
                                    value: widget.entry.details!,
                                    isPremium: true,
                                  ),
                                ],
                                if (widget.entry.snoozeUntil != null) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Divider(
                                      height: 1,
                                      color: isDark 
                                          ? colors.outline.withValues(alpha: 0.15) 
                                          : colors.primary.withValues(alpha: 0.10),
                                    ),
                                  ),
                                  _DetailRow(
                                    icon: Icons.notifications_paused_outlined,
                                    label: 'Snoozed until',
                                    value: DateFormat.yMMMMd().add_jm().format(widget.entry.snoozeUntil!),
                                    helper: 'You won\'t receive notifications until this time.',
                                    isPremium: true,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          SizedBox(height: spacing.xl),

                          // Actions
                          _ReminderActions(
                            isActive: widget.isActive,
                            onEdit: () {
                              Navigator.of(context).pop();
                              widget.onEdit();
                            },
                            onSnooze: () {
                              Navigator.of(context).pop();
                              widget.onSnooze();
                            },
                            onToggle: _handleToggle,
                            onDelete: _handleDelete,
                            toggleBusy: _toggleBusy,
                            deleteBusy: _deleteBusy,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReminderActions extends StatelessWidget {
  const _ReminderActions({
    required this.isActive,
    required this.onEdit,
    required this.onSnooze,
    required this.onToggle,
    required this.onDelete,
    required this.toggleBusy,
    required this.deleteBusy,
  });

  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onSnooze;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final bool toggleBusy;
  final bool deleteBusy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    final children = <Widget>[
      FilledButton.icon(
        onPressed: onEdit,
        icon: Icon(Icons.edit_rounded, size: AppTokens.iconSize.sm),
        label: const Text('Edit'),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.radius.md,
          ),
        ),
      ),
      if (isActive)
        FilledButton.tonalIcon(
          onPressed: onSnooze,
          icon: Icon(Icons.snooze_rounded, size: AppTokens.iconSize.sm),
          label: const Text('Snooze'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: AppTokens.radius.md,
            ),
          ),
        ),
      FilledButton.tonalIcon(
        onPressed: toggleBusy ? null : onToggle,
        icon: toggleBusy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              )
            : Icon(isActive
                ? Icons.check_circle_outline_rounded
                : Icons.replay_rounded, size: AppTokens.iconSize.md),
        label: Text(isActive ? 'Mark as done' : 'Mark as pending'),
        style: FilledButton.styleFrom(
          backgroundColor: isActive ? colors.primaryContainer : null,
          foregroundColor: isActive ? colors.onPrimaryContainer : null,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.radius.md,
          ),
        ),
      ),
      TextButton.icon(
        onPressed: deleteBusy ? null : onDelete,
        icon: deleteBusy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.error),
                ),
              )
            : Icon(Icons.delete_outline_rounded, size: AppTokens.iconSize.md),
        label: const Text('Delete reminder'),
        style: TextButton.styleFrom(
          foregroundColor: colors.error,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.radius.md,
          ),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _spaced(children),
    );
  }

  List<Widget> _spaced(List<Widget> items) {
    if (items.length <= 1) return items;
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(SizedBox(height: AppTokens.spacing.md));
      }
    }
    return result;
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundOpacity = theme.brightness == Brightness.dark ? 0.24 : 0.12;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: backgroundOpacity),
        borderRadius: AppTokens.radius.md,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTokens.iconSize.sm, color: color),
          SizedBox(width: AppTokens.spacing.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.helper,
    this.isPremium = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? helper;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPremium ? colors.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: AppTokens.radius.sm,
          ),
          child: Icon(icon, size: AppTokens.iconSize.md, color: colors.primary),
        ),
        SizedBox(width: AppTokens.spacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTokens.typography.caption.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppTokens.spacing.xs),
              Text(
                value,
                style: AppTokens.typography.subtitle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              if (helper != null && helper!.isNotEmpty) ...[
                SizedBox(height: AppTokens.spacing.xs),
                Text(
                  helper!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
