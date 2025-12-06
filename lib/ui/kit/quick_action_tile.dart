import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A reusable action tile for quick action menus.
///
/// Displays an icon in a colored container, label, description, and chevron.
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

    return InkWell(
      onTap: onTap,
      borderRadius: AppTokens.radius.lg,
      child: Container(
        padding: AppTokens.spacing.edgeInsetsSymmetric(
          horizontal: AppTokens.spacing.lg,
          vertical: AppTokens.spacing.md,
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
              width: AppTokens.componentSize.avatarLg,
              height: AppTokens.componentSize.avatarLg,
              decoration: BoxDecoration(
                borderRadius: AppTokens.radius.md,
                color: accent.withValues(alpha: AppOpacity.statusBg),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: accent),
            ),
            SizedBox(width: AppTokens.spacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTokens.typography.subtitle.copyWith(
                      fontWeight: AppTokens.fontWeight.semiBold,
                      color: colors.onSurface,
                    ),
                  ),
                  SizedBox(height: AppTokens.spacing.xs),
                  Text(
                    description,
                    style: AppTokens.typography.caption.copyWith(
                      color: palette.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: palette.muted.withValues(alpha: AppOpacity.subtle),
            ),
          ],
        ),
      ),
    );
  }
}
