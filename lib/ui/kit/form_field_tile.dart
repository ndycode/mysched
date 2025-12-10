import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'responsive_provider.dart';

/// A tile for displaying form field selections like date and time.
///
/// Shows an icon, label, value, and chevron. Typically used in forms
/// for tappable date/time pickers.
/// Automatically adapts to screen size via [ResponsiveProvider].
class FormFieldTile extends StatelessWidget {
  const FormFieldTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.fontSize,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  /// Override the value font size.
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return InkWell(
      borderRadius: AppTokens.radius.lg,
      onTap: onTap,
      child: Container(
        padding: AppTokens.spacing.edgeInsetsSymmetric(
          horizontal: AppTokens.spacing.lg * spacingScale,
          vertical: AppTokens.spacing.mdLg * spacingScale,
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
              width: AppTokens.componentSize.avatarSm * scale,
              height: AppTokens.componentSize.avatarSm * scale,
              decoration: BoxDecoration(
                borderRadius: AppTokens.radius.md,
                color: colors.primary.withValues(alpha: AppOpacity.statusBg),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: colors.primary,
                size: AppTokens.iconSize.sm * scale,
              ),
            ),
            SizedBox(width: AppTokens.spacing.md * spacingScale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  SizedBox(height: AppTokens.spacing.xs * spacingScale),
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
            SizedBox(width: AppTokens.spacing.sm * spacingScale),
            Icon(
              Icons.chevron_right_rounded,
              size: AppTokens.iconSize.md * scale,
              color: palette.muted.withValues(alpha: AppOpacity.subtle),
            ),
          ],
        ),
      ),
    );
  }
}

