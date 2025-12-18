import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'responsive_provider.dart';

/// A reusable action tile for quick action menus.
///
/// Displays an icon in a colored container, label, description, and chevron.
/// Automatically adapts to screen size via [ResponsiveProvider].
class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  /// Override the icon color (defaults to primary).
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final accent = iconColor ?? colors.primary;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return InkWell(
      onTap: onTap,
      borderRadius: AppTokens.radius.lg,
      child: Container(
        padding: AppTokens.spacing.edgeInsetsSymmetric(
          horizontal: AppTokens.spacing.lg * spacingScale,
          vertical: AppTokens.spacing.md * spacingScale,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: AppTokens.radius.lg,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: AppOpacity.ghost),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: AppTokens.componentSize.avatarLg * scale,
              height: AppTokens.componentSize.avatarLg * scale,
              decoration: BoxDecoration(
                borderRadius: AppTokens.radius.md,
                // Use withValues for better precision
                color: accent.withValues(alpha: AppOpacity.statusBg),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                // Ensure icon is fully opaque
                color: accent.withValues(alpha: 1.0),
                size: AppTokens.iconSize.md * scale,
              ),
            ),
            SizedBox(width: AppTokens.spacing.lg * spacingScale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTokens.typography.subtitleScaled(scale).copyWith(
                      fontWeight: AppTokens.fontWeight.semiBold,
                      color: colors.onSurface,
                    ),
                  ),
                  SizedBox(height: AppTokens.spacing.xs * spacingScale),
                  Text(
                    description,
                    style: AppTokens.typography.captionScaled(scale).copyWith(
                      color: palette.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: palette.muted.withValues(alpha: AppOpacity.subtle),
              size: AppTokens.iconSize.md * scale,
            ),
          ],
        ),
      ),
    );
  }
}

