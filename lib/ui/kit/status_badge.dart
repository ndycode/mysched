import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Status badge variants for entity tiles
enum StatusBadgeVariant {
  /// Currently active/live (green accent)
  live,
  /// Next up in queue (primary accent)
  next,
  /// Completed/done (muted)
  done,
  /// Overdue item (error accent)
  overdue,
  /// Snoozed item (warning accent)
  snoozed,
}

/// A unified status badge component used across dashboard, schedules, and reminders.
/// 
/// Displays a small pill-shaped badge with consistent styling.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.variant,
    this.compact = false,
  });

  /// Text to display in the badge
  final String label;

  /// Visual variant determining colors
  final StatusBadgeVariant variant;

  /// If true, uses smaller padding
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    final (backgroundColor, foregroundColor) = switch (variant) {
      StatusBadgeVariant.live => (
          colors.primary.withValues(alpha: AppOpacity.medium),
          colors.primary,
        ),
      StatusBadgeVariant.next => (
          colors.primary.withValues(alpha: AppOpacity.highlight),
          colors.primary,
        ),
      StatusBadgeVariant.done => (
          colors.surfaceContainerHighest,
          colors.onSurfaceVariant,
        ),
      StatusBadgeVariant.overdue => (
          colors.error.withValues(alpha: AppOpacity.overlay),
          colors.error,
        ),
      StatusBadgeVariant.snoozed => (
          palette.warning.withValues(alpha: AppOpacity.overlay),
          palette.warning,
        ),
    };

    return Container(
      padding: compact
          ? spacing.edgeInsetsSymmetric(
              horizontal: spacing.sm,
              vertical: spacing.xs - 2,
            )
          : spacing.edgeInsetsSymmetric(
              horizontal: spacing.sm + 2,
              vertical: spacing.xs,
            ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppTokens.radius.sm,
      ),
      child: Text(
        label,
        style: AppTokens.typography.caption.copyWith(
          fontWeight: AppTokens.fontWeight.bold,
          color: foregroundColor,
        ),
      ),
    );
  }
}
