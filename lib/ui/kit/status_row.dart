import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'responsive_provider.dart';

/// A row showing a status item with icon, label, description, and status pill.
///
/// Used for permission/settings status displays.
/// Automatically adapts to screen size via [ResponsiveProvider].
class StatusRow extends StatelessWidget {
  const StatusRow({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.status,
    this.optional = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;

  /// Current status: true = allowed, false = action needed, null = unknown.
  final bool? status;

  /// If true, shows "Recommended" instead of "Action needed" when false.
  final bool optional;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final accent = colors.primary;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: spacing.edgeInsetsAll(spacing.md * spacingScale),
        decoration: BoxDecoration(
          color: isDark ? colors.surfaceContainerHigh : colors.surface,
          borderRadius: AppTokens.radius.lg,
          boxShadow: isDark
              ? null
              : [
                  AppTokens.shadow.elevation1(
                    colors.shadow.withValues(alpha: AppOpacity.faint),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: AppTokens.componentSize.avatarLg * scale,
              width: AppTokens.componentSize.avatarLg * scale,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? AppOpacity.darkTint : AppOpacity.overlay),
                borderRadius: AppTokens.radius.sm,
              ),
              child: Icon(icon, color: accent, size: AppTokens.iconSize.lg * scale),
            ),
            SizedBox(width: spacing.md * spacingScale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: AppTokens.typography.subtitleScaled(scale).copyWith(
                            color: colors.onSurface,
                            fontWeight: AppTokens.fontWeight.semiBold,
                          ),
                        ),
                      ),
                      _StatusPill(status: status, optional: optional, scale: scale, spacingScale: spacingScale),
                    ],
                  ),
                  SizedBox(height: spacing.xs * spacingScale),
                  Text(
                    description,
                    style: AppTokens.typography.captionScaled(scale).copyWith(
                      color: palette.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Internal status pill widget for StatusRow.
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.status,
    required this.optional,
    required this.scale,
    required this.spacingScale,
  });

  final bool? status;
  final bool optional;
  final double scale;
  final double spacingScale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final isOk = status == true;
    final isUnknown = status == null;
    final label = isUnknown
        ? 'Unknown'
        : isOk
            ? 'Allowed'
            : optional
                ? 'Recommended'
                : 'Action needed';

    Color bg;
    Color fg;

    if (isUnknown) {
      bg = isDark
          ? colors.surfaceContainerHighest
          : colors.surfaceContainerHigh;
      fg = palette.muted;
    } else if (isOk) {
      bg = colors.primary.withValues(alpha: isDark ? AppOpacity.darkTint : AppOpacity.overlay);
      fg = colors.primary;
    } else {
      bg = optional
          ? (isDark
              ? palette.warning.withValues(alpha: AppOpacity.darkTint)
              : palette.warning.withValues(alpha: AppOpacity.overlay))
          : palette.danger.withValues(alpha: AppOpacity.statusBg);
      fg = optional ? palette.warning : palette.danger;
    }

    final spacing = AppTokens.spacing;
    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.md * spacingScale,
        vertical: spacing.xsPlus * spacingScale,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppTokens.radius.sm,
      ),
      child: Text(
        label,
        style: AppTokens.typography.captionScaled(scale).copyWith(
          color: fg,
          fontWeight: AppTokens.fontWeight.semiBold,
        ),
      ),
    );
  }
}

