import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A token-driven progress pill showing label + percentage (Dashboard-style).
///
/// Used for showing completion progress with a gradient background,
/// leading icon, label text, and trailing percentage badge.
class ProgressPill extends StatelessWidget {
  const ProgressPill({
    super.key,
    required this.label,
    required this.progress,
    this.icon,
    this.tint,
  });

  /// The label text to display.
  final String label;

  /// Progress value between 0.0 and 1.0.
  final double progress;

  /// Optional icon (defaults to track_changes_rounded).
  final IconData? icon;

  /// Optional tint color (defaults to muted from palette).
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final percent = (progress.clamp(0.0, 1.0) * 100).round();
    final headerColor = tint ?? palette.muted;
    final displayIcon = icon ?? Icons.track_changes_rounded;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            headerColor.withValues(alpha: AppOpacity.dim),
            headerColor.withValues(alpha: AppOpacity.veryFaint),
          ],
        ),
        borderRadius: AppTokens.radius.md,
        border: Border.all(
          color: headerColor.withValues(alpha: AppOpacity.accent),
          width: AppTokens.componentSize.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: spacing.edgeInsetsAll(spacing.sm),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: AppOpacity.medium),
              borderRadius: AppTokens.radius.sm,
            ),
            child: Icon(
              displayIcon,
              size: AppTokens.iconSize.sm,
              color: headerColor,
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTokens.typography.subtitle.copyWith(
                fontWeight: AppTokens.fontWeight.extraBold,
                letterSpacing: AppLetterSpacing.snug,
                color: colors.onSurface,
              ),
            ),
          ),
          Container(
            padding: spacing.edgeInsetsSymmetric(
              horizontal: spacing.smMd,
              vertical: spacing.xsPlus,
            ),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: AppOpacity.overlay),
              borderRadius: AppTokens.radius.sm,
            ),
            child: Text(
              '$percent%',
              style: AppTokens.typography.caption.copyWith(
                fontWeight: AppTokens.fontWeight.bold,
                color: headerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
