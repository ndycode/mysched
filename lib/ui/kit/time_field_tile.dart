import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'responsive_provider.dart';

/// A tappable field tile for displaying time/date values.
///
/// Used in form pages for time and date picker fields.
/// Automatically adapts to screen size via [ResponsiveProvider].
class TimeFieldTile extends StatelessWidget {
  const TimeFieldTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  /// The field label (e.g., "Start time", "End time").
  final String label;

  /// The displayed value (e.g., "9:00 AM").
  final String value;

  /// The leading icon.
  final IconData icon;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    // Scaled dimensions
    final iconContainerSize = AppTokens.componentSize.avatarSm * scale;
    final iconSize = AppTokens.iconSize.sm * scale;

    return InkWell(
      borderRadius: AppTokens.radius.lg,
      onTap: onTap,
      child: Container(
        padding: spacing.edgeInsetsSymmetric(
          horizontal: spacing.md * spacingScale,
          vertical: spacing.md * spacingScale,
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
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                borderRadius: AppTokens.radius.md,
                color: colors.primary.withValues(alpha: AppOpacity.statusBg),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: colors.primary,
                size: iconSize,
              ),
            ),
            SizedBox(width: spacing.md * spacingScale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label - prevent wrapping with FittedBox
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: AppTokens.typography.captionScaled(scale).copyWith(
                        color: palette.muted,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(height: spacing.xs * spacingScale),
                  // Value
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: AppTokens.typography.subtitleScaled(scale).copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.sm * spacingScale),
            Icon(
              Icons.chevron_right_rounded,
              size: AppTokens.iconSize.md * scale,
              color: palette.muted.withValues(alpha: AppOpacity.soft),
            ),
          ],
        ),
      ),
    );
  }
}
