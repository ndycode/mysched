import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A unified metric chip component for displaying stats.
/// 
/// Used in schedules and reminders summary cards to show counts,
/// durations, and other metrics with consistent styling.
class MetricChip extends StatelessWidget {
  const MetricChip({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.tint,
    this.compact = false,
  });

  /// The primary value to display (e.g., "5", "2h 30m")
  final String value;

  /// Label describing the value (e.g., "classes", "total time")
  final String label;

  /// Icon to show before the value
  final IconData icon;

  /// Optional accent color (defaults to primary)
  final Color? tint;

  /// If true, uses horizontal compact layout
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final accent = tint ?? colors.primary;

    if (compact) {
      return Container(
        padding: spacing.edgeInsetsSymmetric(
          horizontal: spacing.md,
          vertical: spacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isDark ? 0.20 : 0.12),
          borderRadius: AppTokens.radius.md,
          border: Border.all(
            color: accent.withValues(alpha: 0.20),
            width: AppTokens.componentSize.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: AppTokens.componentSize.avatarSm,
              width: AppTokens.componentSize.avatarSm,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.20 : 0.12),
                borderRadius: AppTokens.radius.sm,
              ),
              child: Icon(icon, size: AppTokens.iconSize.sm, color: accent),
            ),
            SizedBox(width: spacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTokens.typography.subtitle.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: AppTokens.typography.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Card-style layout for larger displays
    return Container(
      padding: spacing.edgeInsetsAll(spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.10),
            accent.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: AppTokens.radius.md,
        border: Border.all(
          color: accent.withValues(alpha: 0.20),
          width: AppTokens.componentSize.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: spacing.edgeInsetsAll(spacing.sm),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: AppTokens.radius.sm,
            ),
            child: Icon(icon, size: AppTokens.iconSize.sm, color: accent),
          ),
          SizedBox(height: spacing.md),
          Text(
            value,
            style: AppTokens.typography.title.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            label,
            style: AppTokens.typography.bodySecondary.copyWith(
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
