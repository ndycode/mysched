import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A tappable field tile for displaying time/date values.
///
/// Used in form pages for time and date picker fields.
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

    return InkWell(
      borderRadius: AppTokens.radius.lg,
      onTap: onTap,
      child: Container(
        padding: spacing.edgeInsetsSymmetric(
          horizontal: spacing.md,
          vertical: spacing.md,
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
              width: AppTokens.componentSize.avatarSm,
              height: AppTokens.componentSize.avatarSm,
              decoration: BoxDecoration(
                borderRadius: AppTokens.radius.md,
                color: colors.primary.withValues(alpha: AppOpacity.statusBg),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: colors.primary,
                size: AppTokens.iconSize.sm,
              ),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.muted,
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                        fontSize: AppTokens.typography.subtitle.fontSize,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              size: AppTokens.iconSize.md,
              color: palette.muted.withValues(alpha: AppOpacity.soft),
            ),
          ],
        ),
      ),
    );
  }
}
