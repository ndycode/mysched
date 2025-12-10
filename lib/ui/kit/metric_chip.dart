import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'responsive_provider.dart';

/// A unified metric chip component for displaying stats.
/// 
/// Used in schedules and reminders summary cards to show counts,
/// durations, and other metrics with consistent styling.
/// 
/// Automatically adapts to screen size via [ResponsiveProvider].
class MetricChip extends StatelessWidget {
  const MetricChip({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.caption,
    this.tint,
    this.backgroundTint,
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

  /// Optional override for background tint (defaults to a translucent [tint]).
  final Color? backgroundTint;

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
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final accent = tint ?? colors.primary;
    final bgTint = backgroundTint ??
        (isDark
            ? accent.withValues(alpha: AppOpacity.dim)
            : accent.withValues(alpha: AppOpacity.veryFaint));

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    // Scaled dimensions
    final scaledPadding = spacing.mdLg * spacingScale;
    final scaledIconContainer = AppTokens.componentSize.avatarSm * scale;
    final scaledIconSize = AppTokens.iconSize.sm * scale;

    if (compact) {
      return Container(
        padding: spacing.edgeInsetsSymmetric(
          horizontal: spacing.md * spacingScale,
          vertical: spacing.smMd * spacingScale,
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
              height: scaledIconContainer,
              width: scaledIconContainer,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.dim),
                borderRadius: AppTokens.radius.sm,
              ),
              child: Icon(icon, size: scaledIconSize, color: accent),
            ),
            SizedBox(width: spacing.md * spacingScale),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTokens.typography.subtitleScaled(scale).copyWith(
                    fontWeight: AppTokens.fontWeight.extraBold,
                    letterSpacing: AppLetterSpacing.snug,
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: AppTokens.typography.captionScaled(scale).copyWith(
                    fontWeight: AppTokens.fontWeight.medium,
                    color: palette.muted,
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
      padding: spacing.edgeInsetsAll(scaledPadding),
      decoration: BoxDecoration(
        color: bgTint,
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
            height: scaledIconContainer,
            width: scaledIconContainer,
            decoration: BoxDecoration(
              color: (backgroundTint ?? accent).withValues(
                alpha: isDark ? AppOpacity.medium : AppOpacity.dim,
              ),
              borderRadius: AppTokens.radius.sm,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: scaledIconSize, color: accent),
          ),
          SizedBox(height: spacing.smMd * spacingScale),
          Text(
            value,
            style: displayStyle
                ? AppTokens.typography.displayScaled(scale).copyWith(
                    fontWeight: AppTokens.fontWeight.extraBold,
                    height: AppLineHeight.single,
                    color: colors.onSurface,
                  )
                : AppTokens.typography.headlineScaled(scale).copyWith(
                    fontWeight: AppTokens.fontWeight.bold,
                    color: colors.onSurface,
                  ),
          ),
          SizedBox(height: spacing.xs * spacingScale),
          Text(
            label,
            style: AppTokens.typography.captionScaled(scale).copyWith(
              fontWeight: AppTokens.fontWeight.medium,
              color: palette.muted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (caption != null) ...[
            SizedBox(height: spacing.xs * spacingScale),
            Text(
              caption!,
              style: AppTokens.typography.captionScaled(scale).copyWith(
                color: palette.muted,
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

