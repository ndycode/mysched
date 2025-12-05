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
    this.caption,
    this.tint,
    this.compact = false,
    this.displayStyle = false,
  });

  /// The primary value to display (e.g., "5", "2h 30m")
  final String value;

  /// Label describing the value (e.g., "classes", "total time")
  final String label;

  /// Icon to show before the value
  final IconData icon;

  /// Optional caption below label
  final String? caption;

  /// Optional accent color (defaults to primary)
  final Color? tint;

  /// If true, uses horizontal compact layout
  final bool compact;

  /// If true, uses larger display typography for value
  final bool displayStyle;

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
          vertical: spacing.smMd,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.dim),
          borderRadius: AppTokens.radius.md,
          border: Border.all(
            color: accent.withValues(alpha: AppOpacity.medium),
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
                color: accent.withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.dim),
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
                    fontWeight: AppTokens.fontWeight.extraBold,
                    letterSpacing: AppLetterSpacing.snug,
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: AppTokens.typography.caption.copyWith(
                    fontWeight: AppTokens.fontWeight.medium,
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
      padding: spacing.edgeInsetsAll(spacing.mdLg),
      decoration: BoxDecoration(
        color: isDark 
            ? accent.withValues(alpha: AppOpacity.dim) 
            : accent.withValues(alpha: AppOpacity.veryFaint),
        borderRadius: AppTokens.radius.md,
        border: Border.all(
          color: accent.withValues(alpha: AppOpacity.medium),
          width: AppTokens.componentSize.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: AppTokens.componentSize.avatarSm,
            width: AppTokens.componentSize.avatarSm,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.dim),
              borderRadius: AppTokens.radius.sm,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: AppTokens.iconSize.sm, color: accent),
          ),
          SizedBox(height: spacing.smMd),
          Text(
            value,
            style: displayStyle
                ? AppTokens.typography.display.copyWith(
                    fontWeight: AppTokens.fontWeight.extraBold,
                    height: AppLineHeight.single,
                    color: colors.onSurface,
                  )
                : AppTokens.typography.headline.copyWith(
                    fontWeight: AppTokens.fontWeight.bold,
                    color: colors.onSurface,
                  ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            label,
            style: AppTokens.typography.caption.copyWith(
              fontWeight: AppTokens.fontWeight.medium,
              color: colors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (caption != null) ...[
            SizedBox(height: spacing.xs),
            Text(
              caption!,
              style: AppTokens.typography.caption.copyWith(
                color: colors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

