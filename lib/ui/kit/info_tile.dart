import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A unified info tile for displaying icon + title + description.
///
/// Used in privacy, about, settings, and other info screens for
/// consistent list items with icon, title, and optional description.
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
    final spacing = AppTokens.spacing;
    final accent = tint ?? colors.primary;

    Widget iconWidget;
    if (iconInContainer) {
      if (compactContainer) {
        // Compact container style (for feature tiles)
        iconWidget = Container(
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: AppTokens.radius.sm,
          ),
          padding: spacing.edgeInsetsAll(spacing.md),
          child: Icon(icon, color: accent, size: AppTokens.iconSize.md),
        );
      } else {
        // Large container style (for settings tiles)
        iconWidget = Container(
          width: AppTokens.componentSize.avatarLg,
          height: AppTokens.componentSize.avatarLg,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            borderRadius: AppTokens.radius.sm,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: accent, size: AppTokens.iconSize.lg),
        );
      }
    } else {
      iconWidget = Icon(icon, color: accent);
    }

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        iconWidget,
        SizedBox(width: iconInContainer ? spacing.md : spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: iconInContainer
                    ? AppTokens.typography.subtitle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      )
                    : theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: spacing.xs),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showChevron) ...[
          SizedBox(width: spacing.sm),
          Icon(
            Icons.chevron_right_rounded,
            color: colors.onSurfaceVariant,
          ),
        ],
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: spacing.edgeInsetsSymmetric(vertical: spacing.sm),
          child: content,
        ),
      );
    }

    return content;
  }
}
