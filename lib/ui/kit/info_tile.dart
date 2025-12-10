import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'responsive_provider.dart';

/// A unified info tile for displaying icon + title + description.
///
/// Used in privacy, about, settings, and other info screens for
/// consistent list items with icon, title, and optional description.
/// Automatically adapts to screen size via [ResponsiveProvider].
class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.showChevron = false,
    this.iconInContainer = false,
    this.compactContainer = false,
    this.tint,
    this.onTap,
  });

  /// Icon to display
  final IconData icon;

  /// Primary title text
  final String title;

  /// Optional subtitle/description
  final String? subtitle;

  /// Whether to show a chevron on the right (for navigation tiles)
  final bool showChevron;

  /// Whether to wrap icon in a colored container
  final bool iconInContainer;

  /// If true, uses smaller container (for feature tiles)
  final bool compactContainer;

  /// Optional accent color for icon (defaults to primary)
  final Color? tint;

  /// Optional tap handler
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final accent = tint ?? colors.primary;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    Widget iconWidget;
    if (iconInContainer) {
      if (compactContainer) {
        // Compact container style (for feature tiles)
        iconWidget = Container(
          decoration: BoxDecoration(
            color: accent.withValues(alpha: AppOpacity.overlay),
            borderRadius: AppTokens.radius.sm,
          ),
          padding: spacing.edgeInsetsAll(spacing.md * spacingScale),
          child: Icon(icon, color: accent, size: AppTokens.iconSize.md * scale),
        );
      } else {
        // Large container style (for settings tiles)
        iconWidget = Container(
          width: AppTokens.componentSize.avatarLg * scale,
          height: AppTokens.componentSize.avatarLg * scale,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: AppOpacity.medium),
            borderRadius: AppTokens.radius.sm,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: accent, size: AppTokens.iconSize.lg * scale),
        );
      }
    } else {
      iconWidget = Icon(icon, color: accent, size: AppTokens.iconSize.md * scale);
    }

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        iconWidget,
        SizedBox(width: (iconInContainer ? spacing.md : spacing.sm) * spacingScale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: iconInContainer
                    ? AppTokens.typography.subtitleScaled(scale).copyWith(
                        fontWeight: AppTokens.fontWeight.semiBold,
                        color: colors.onSurface,
                      )
                    : AppTokens.typography.subtitleScaled(scale).copyWith(
                        fontWeight: AppTokens.fontWeight.semiBold,
                      ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: spacing.xs * spacingScale),
                Text(
                  subtitle!,
                  style: AppTokens.typography.bodyScaled(scale).copyWith(
                    color: palette.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showChevron) ...[
          SizedBox(width: spacing.sm * spacingScale),
          Icon(
            Icons.chevron_right_rounded,
            color: palette.muted,
            size: AppTokens.iconSize.md * scale,
          ),
        ],
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: spacing.edgeInsetsSymmetric(vertical: spacing.sm * spacingScale),
          child: content,
        ),
      );
    }

    return content;
  }
}

