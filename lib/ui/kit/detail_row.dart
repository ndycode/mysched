import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'responsive_provider.dart';

/// A small chip displaying an icon and label with a colored background.
///
/// Use for status indicators like "Pending", "Completed", "Custom", "Synced", etc.
/// Automatically adapts to screen size via [ResponsiveProvider].
class StatusInfoChip extends StatelessWidget {
  const StatusInfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundOpacity =
        theme.brightness == Brightness.dark ? AppOpacity.shadowBubble : AppOpacity.overlay;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.spacing.md * spacingScale,
        vertical: AppTokens.spacing.sm * spacingScale,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: backgroundOpacity),
        borderRadius: AppTokens.radius.md,
        border: Border.all(color: color.withValues(alpha: AppOpacity.barrier)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTokens.iconSize.sm * scale, color: color),
          SizedBox(width: AppTokens.spacing.xs * spacingScale),
          Text(
            label,
            style: AppTokens.typography.captionScaled(scale).copyWith(
              fontWeight: AppTokens.fontWeight.semiBold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// A row showing an icon, label, value, and optional helper text.
///
/// Use for detail displays like "Due date: Dec 5, 2025" or "Room: 301".
/// Automatically adapts to screen size via [ResponsiveProvider].
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.helper,
    this.accentIcon = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? helper;

  /// Whether to show the icon in an accent-colored container.
  final bool accentIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppTokens.spacing.sm * spacingScale),
          decoration: BoxDecoration(
            color: accentIcon
                ? colors.primary.withValues(alpha: AppOpacity.overlay)
                : Colors.transparent,
            borderRadius: AppTokens.radius.sm,
          ),
          child:
              Icon(icon, size: AppTokens.iconSize.md * scale, color: colors.primary),
        ),
        SizedBox(width: AppTokens.spacing.lg * spacingScale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTokens.typography.captionScaled(scale).copyWith(
                  color: palette.muted,
                ),
              ),
              SizedBox(height: AppTokens.spacing.xs * spacingScale),
              Text(
                value,
                style: AppTokens.typography.subtitleScaled(scale).copyWith(
                  fontWeight: AppTokens.fontWeight.semiBold,
                  color: colors.onSurface,
                ),
              ),
              if (helper != null && helper!.isNotEmpty) ...[
                SizedBox(height: AppTokens.spacing.xs * spacingScale),
                Text(
                  helper!,
                  style: AppTokens.typography.captionScaled(scale).copyWith(
                    color: palette.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

