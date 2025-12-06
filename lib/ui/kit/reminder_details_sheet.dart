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
    required this.onToggle,
    required this.isActive,
  });

  final ReminderEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onSnooze;
  final ValueChanged<bool> onToggle;
  final bool isActive;

  @override
  State<ReminderDetailsSheet> createState() => _ReminderDetailsSheetState();
}

class _ReminderDetailsSheetState extends State<ReminderDetailsSheet> {
  bool _toggleBusy = false;

  Future<void> _handleToggle() async {
    if (_toggleBusy) return;
    setState(() => _toggleBusy = true);
    try {
      widget.onToggle(!widget.isActive);
    } finally {
      if (mounted) setState(() => _toggleBusy = false);
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
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.xl),
          child: ConstrainedBox(
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
                                color: isDark ? palette.muted.withValues(alpha: AppOpacity.muted) : palette.muted,
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
                            color: palette.muted,
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
                                  color: palette.danger,
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
                            toggleBusy: _toggleBusy,
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
    required this.toggleBusy,
  });

  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onSnooze;
  final VoidCallback onToggle;
  final bool toggleBusy;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      PrimaryButton(
        label: 'Edit',
        icon: Icons.edit_rounded,
        onPressed: onEdit,
        minHeight: AppTokens.componentSize.buttonMd,
      ),
      if (isActive)
        SecondaryButton(
          label: 'Snooze',
          icon: Icons.snooze_rounded,
          onPressed: onSnooze,
          minHeight: AppTokens.componentSize.buttonMd,
        ),
      SecondaryButton(
        label: isActive ? 'Mark as done' : 'Mark as pending',
        icon: isActive ? Icons.check_circle_outline_rounded : Icons.replay_rounded,
        onPressed: toggleBusy ? null : onToggle,
        loading: toggleBusy,
        minHeight: AppTokens.componentSize.buttonMd,
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
