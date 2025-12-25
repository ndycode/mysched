import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/tokens.dart';
import 'responsive_provider.dart';

/// A reusable empty state placeholder with a gradient icon circle and messaging.
///
/// Used across dashboard, schedules, and reminders for consistent "all caught up"
/// or "no items" states within summary cards.
/// Features smooth entrance animation.
/// Automatically adapts to screen size via [ResponsiveProvider].
class EmptyHeroPlaceholder extends StatelessWidget {
  const EmptyHeroPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.accentColor,
  });

  /// Icon to display in the center circle.
  final IconData icon;

  /// Primary title text (e.g., "All caught up").
  final String title;

  /// Secondary subtitle text describing the state.
  final String subtitle;

  /// Optional accent color override (defaults to primary).
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final accent = accentColor ?? colors.primary;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return Container(
      width: double.infinity,
      padding: spacing.edgeInsetsAll(spacing.xxxl * spacingScale),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: AppOpacity.micro),
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: accent.withValues(alpha: AppOpacity.dim),
          width: AppTokens.componentSize.divider,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: spacing.emptyStateSize * scale,
            height: spacing.emptyStateSize * scale,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: AppOpacity.medium),
                  accent.withValues(alpha: AppOpacity.highlight),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: accent.withValues(alpha: AppOpacity.accent),
                width: AppTokens.componentSize.dividerThick,
              ),
            ),
            child: Icon(
              icon,
              size: AppTokens.iconSize.xxl * scale,
              color: accent,
            ),
          ),
          SizedBox(height: spacing.xl * spacingScale),
          Text(
            title,
            style: AppTokens.typography.subtitleScaled(scale).copyWith(
              fontWeight: AppTokens.fontWeight.bold,
              color: palette.muted,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.sm * spacingScale),
          Text(
            subtitle,
            style: AppTokens.typography.bodyScaled(scale).copyWith(
              color: palette.muted.withValues(alpha: AppOpacity.secondary),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).appEntrance();
  }
}
