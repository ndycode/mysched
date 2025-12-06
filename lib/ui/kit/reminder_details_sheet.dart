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
    final confirm = await AppModal.confirm(
      context: context,
      title: 'Delete reminder?',
      message: 'This reminder will be permanently removed.',
      confirmLabel: 'Delete',
      isDanger: true,
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
    final borderWidth = elevatedCardBorderWidth(theme);
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * AppLayout.sheetMaxHeightRatio;
    final isDark = theme.brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: AppLayout.sheetMaxWidth),
      child: Container(
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: AppTokens.radius.xl,
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: isDark
              ? null
              : [
                  AppTokens.shadow.modal(
                    theme.shadowColor.withValues(alpha: AppOpacity.border),
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
                        height: AppTokens.componentSize.buttonLg,
                        width: AppTokens.componentSize.buttonLg,
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
                                fontWeight: AppTokens.fontWeight.extraBold,
                                letterSpacing: AppLetterSpacing.tight,
                                height: AppLineHeight.headline,
                                color: isDark ? colors.onSurface : colors.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppTokens.spacing.xs),
                            Text(
                              'Reminder details',
                              style: AppTokens.typography.bodySecondary.copyWith(
                                color: isDark ? colors.onSurfaceVariant.withValues(alpha: AppOpacity.muted) : colors.onSurfaceVariant,
                                fontWeight: AppTokens.fontWeight.medium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppTokens.spacing.md),
                      PressableScale(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.all(AppTokens.spacing.sm),
                          decoration: BoxDecoration(
                            color: colors.onSurface.withValues(alpha: AppOpacity.faint),
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
                            spacing: AppTokens.spacing.sm,
                            runSpacing: AppTokens.spacing.sm,
                            children: [
                              StatusInfoChip(
                                icon: widget.isActive
                                    ? Icons.pending_actions_rounded
                                    : Icons.check_circle_outline_rounded,
                                label: widget.isActive ? 'Pending' : 'Completed',
                                color: widget.isActive
                                    ? colors.primary
                                    : colors.tertiary,
                              ),
                              if (widget.entry.isOverdue)
                                StatusInfoChip(
                                  icon: Icons.error_outline_rounded,
                                  label: 'Overdue',
                                  color: colors.error,
                                ),
                              if (widget.entry.isSnoozed)
                                StatusInfoChip(
                                  icon: Icons.snooze_rounded,
                                  label: 'Snoozed',
                                  color: colors.secondary,
                                ),
                            ],
                          ),
                          SizedBox(height: spacing.lg),

                          // Main Details Container
                          Container(
                            padding: EdgeInsets.all(AppTokens.spacing.xl),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.ghost) 
                                  : colors.primary.withValues(alpha: AppOpacity.micro),
                              borderRadius: AppTokens.radius.lg,
                              border: Border.all(
                                color: isDark 
                                    ? colors.outline.withValues(alpha: AppOpacity.overlay) 
                                    : colors.primary.withValues(alpha: AppOpacity.dim),
                                width: AppTokens.componentSize.divider,
                              ),
                            ),
                            child: Column(
                              children: [
                                DetailRow(
                                  icon: Icons.event_rounded,
                                  label: 'Due date',
                                  value: DateFormat.yMMMMd().add_jm().format(widget.entry.dueAt),
                                  accentIcon: true,
                                ),
                                if (widget.entry.details != null && widget.entry.details!.isNotEmpty) ...[
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: AppTokens.spacing.lg),
                                    child: Divider(
                                      height: AppTokens.componentSize.divider,
                                      color: isDark 
                                          ? colors.outline.withValues(alpha: AppOpacity.medium) 
                                          : colors.primary.withValues(alpha: AppOpacity.dim),
                                    ),
                                  ),
                                  DetailRow(
                                    icon: Icons.notes_rounded,
                                    label: 'Details',
                                    value: widget.entry.details!,
                                    accentIcon: true,
                                  ),
                                ],
                                if (widget.entry.snoozeUntil != null) ...[
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: AppTokens.spacing.lg),
                                    child: Divider(
                                      height: AppTokens.componentSize.divider,
                                      color: isDark 
                                          ? colors.outline.withValues(alpha: AppOpacity.medium) 
                                          : colors.primary.withValues(alpha: AppOpacity.dim),
                                    ),
                                  ),
                                  DetailRow(
                                    icon: Icons.notifications_paused_outlined,
                                    label: 'Snoozed until',
                                    value: DateFormat.yMMMMd().add_jm().format(widget.entry.snoozeUntil!),
                                    helper: 'You won\'t receive notifications until this time.',
                                    accentIcon: true,
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
          minimumSize: Size.fromHeight(AppTokens.componentSize.buttonMd),
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
            minimumSize: Size.fromHeight(AppTokens.componentSize.buttonMd),
            shape: RoundedRectangleBorder(
              borderRadius: AppTokens.radius.md,
            ),
          ),
        ),
      FilledButton.tonalIcon(
        onPressed: toggleBusy ? null : onToggle,
        icon: toggleBusy
            ? SizedBox(
                width: AppInteraction.loaderSize,
                height: AppInteraction.loaderSize,
                child: CircularProgressIndicator(
                  strokeWidth: AppInteraction.progressStrokeWidth,
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
          minimumSize: Size.fromHeight(AppTokens.componentSize.buttonMd),
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.radius.md,
          ),
        ),
      ),
      TextButton.icon(
        onPressed: deleteBusy ? null : onDelete,
        icon: deleteBusy
            ? SizedBox(
                width: AppInteraction.loaderSize,
                height: AppInteraction.loaderSize,
                child: CircularProgressIndicator(
                  strokeWidth: AppInteraction.progressStrokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.error),
                ),
              )
            : Icon(Icons.delete_outline_rounded, size: AppTokens.iconSize.md),
        label: const Text('Delete reminder'),
        style: TextButton.styleFrom(
          foregroundColor: colors.error,
          minimumSize: Size.fromHeight(AppTokens.componentSize.buttonMd),
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

// _InfoChip and _DetailRow removed - using global StatusInfoChip and DetailRow from kit.dart
