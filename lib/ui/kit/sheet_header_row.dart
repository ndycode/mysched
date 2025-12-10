import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'pressable_scale.dart';
import 'responsive_provider.dart';

/// A reusable header row for sheets and dialogs.
///
/// Displays an icon in a gradient container, title, subtitle, and close button.
/// Automatically adapts to screen size via [ResponsiveProvider].
class SheetHeaderRow extends StatelessWidget {
  const SheetHeaderRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onClose,
    this.iconColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onClose;

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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: AppTokens.componentSize.avatarXl * scale,
          width: AppTokens.componentSize.avatarXl * scale,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: AppOpacity.statusBg),
                accent.withValues(alpha: AppOpacity.overlay),
              ],
            ),
            borderRadius: AppTokens.radius.md,
            border: Border.all(
              color: accent.withValues(alpha: AppOpacity.ghost),
              width: AppTokens.componentSize.dividerThick,
            ),
          ),
          child: Icon(
            icon,
            color: accent,
            size: AppTokens.iconSize.xl * scale,
          ),
        ),
        SizedBox(width: AppTokens.spacing.lg * spacingScale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTokens.typography.titleScaled(scale).copyWith(
                  fontWeight: AppTokens.fontWeight.extraBold,
                  letterSpacing: AppLetterSpacing.tight,
                  height: AppLineHeight.headline,
                  color: colors.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppTokens.spacing.xs * spacingScale),
              Text(
                subtitle,
                style: AppTokens.typography.bodyScaled(scale).copyWith(
                  color: palette.muted,
                  fontWeight: AppTokens.fontWeight.medium,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppTokens.spacing.md * spacingScale),
        PressableScale(
          onTap: onClose,
          child: Container(
            padding: EdgeInsets.all(AppTokens.spacing.sm * spacingScale),
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: AppOpacity.faint),
              borderRadius: AppTokens.radius.md,
            ),
            child: Icon(
              Icons.close_rounded,
              size: AppTokens.iconSize.md * scale,
              color: palette.muted,
            ),
          ),
        ),
      ],
    );
  }
}

