import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A reusable empty state placeholder with a gradient icon circle and messaging.
///
/// Used across dashboard, schedules, and reminders for consistent "all caught up"
/// or "no items" states within summary cards.
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

    return Container(
      width: double.infinity,
      padding: spacing.edgeInsetsAll(spacing.xxxl),
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
            width: spacing.emptyStateSize,
            height: spacing.emptyStateSize,
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
              size: AppTokens.iconSize.xxl,
              color: accent,
            ),
          ),
          SizedBox(height: spacing.xl),
          Text(
            title,
            style: AppTokens.typography.subtitle.copyWith(
              fontWeight: AppTokens.fontWeight.bold,
              color: palette.muted,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.sm),
          Text(
            subtitle,
            style: AppTokens.typography.bodySecondary.copyWith(
              color: palette.muted.withValues(alpha: AppOpacity.secondary),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
