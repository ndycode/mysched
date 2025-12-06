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
  /// Enabled state (primary accent)
  enabled,
  /// Disabled/off state (error accent)
  disabled,
  /// Custom class tag (positive accent)
  custom,
}

extension StatusBadgeVariantLabels on StatusBadgeVariant {
  /// Display label for the badge.
  String get label => switch (this) {
    StatusBadgeVariant.live => 'Live',
    StatusBadgeVariant.next => 'Next',
    StatusBadgeVariant.done => 'Done',
    StatusBadgeVariant.overdue => 'Overdue',
    StatusBadgeVariant.snoozed => 'Snoozed',
    StatusBadgeVariant.enabled => 'On',
    StatusBadgeVariant.disabled => 'Off',
    StatusBadgeVariant.custom => 'Custom',
  };
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
    this.accent,
  });

  /// Text to display in the badge
  final String label;

  /// Visual variant determining colors
  final StatusBadgeVariant variant;

  /// If true, uses smaller padding
  final bool compact;

  /// Optional accent override (defaults to variant-based color)
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    Color resolvedAccent;
    double resolvedBgAlpha;

    switch (variant) {
      case StatusBadgeVariant.live:
        resolvedAccent = accent ?? colors.primary;
        resolvedBgAlpha = AppOpacity.highlight;
        break;
      case StatusBadgeVariant.next:
        resolvedAccent = accent ?? colors.primary;
        resolvedBgAlpha = AppOpacity.highlight;
        break;
      case StatusBadgeVariant.done:
        resolvedAccent = accent ?? colors.onSurfaceVariant;
        resolvedBgAlpha = AppOpacity.overlay;
        break;
      case StatusBadgeVariant.overdue:
        resolvedAccent = accent ?? colors.error;
        resolvedBgAlpha = AppOpacity.overlay;
        break;
      case StatusBadgeVariant.snoozed:
        resolvedAccent = accent ?? palette.warning;
        resolvedBgAlpha = AppOpacity.overlay;
        break;
      case StatusBadgeVariant.enabled:
        resolvedAccent = accent ?? colors.primary;
        resolvedBgAlpha = AppOpacity.statusBg;
        break;
      case StatusBadgeVariant.disabled:
        resolvedAccent = accent ?? colors.error;
        resolvedBgAlpha = AppOpacity.statusBg;
        break;
      case StatusBadgeVariant.custom:
        resolvedAccent = accent ?? palette.positive;
        resolvedBgAlpha = AppOpacity.highlight;
        break;
    }

    final backgroundColor = switch (variant) {
      StatusBadgeVariant.done => colors.surfaceContainerHighest,
      StatusBadgeVariant.disabled => colors.error.withValues(alpha: resolvedBgAlpha),
      _ => resolvedAccent.withValues(alpha: resolvedBgAlpha),
    };

    final foregroundColor = resolvedAccent;

    return Container(
      padding: compact
          ? spacing.edgeInsetsSymmetric(
              horizontal: spacing.sm,
              vertical: spacing.micro,
            )
          : spacing.edgeInsetsSymmetric(
              horizontal: spacing.smMd,
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
