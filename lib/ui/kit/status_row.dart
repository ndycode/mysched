import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A row showing a status item with icon, label, description, and status pill.
///
/// Used for permission/settings status displays.
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
    final accent = colors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: spacing.edgeInsetsAll(spacing.md),
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
              height: AppTokens.componentSize.avatarLg,
              width: AppTokens.componentSize.avatarLg,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? AppOpacity.darkTint : AppOpacity.overlay),
                borderRadius: AppTokens.radius.sm,
              ),
              child: Icon(icon, color: accent, size: AppTokens.iconSize.lg),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: AppTokens.typography.subtitle.copyWith(
                            color: colors.onSurface,
                            fontSize: AppTokens.typography.body.fontSize,
                            fontWeight: AppTokens.fontWeight.semiBold,
                          ),
                        ),
                      ),
                      _StatusPill(status: status, optional: optional),
                    ],
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: AppTokens.typography.caption.fontSize,
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
  const _StatusPill({required this.status, required this.optional});

  final bool? status;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
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
      fg = colors.onSurfaceVariant;
    } else if (isOk) {
      bg = colors.primary.withValues(alpha: isDark ? AppOpacity.darkTint : AppOpacity.overlay);
      fg = colors.primary;
    } else {
      bg = optional
          ? (isDark
              ? AppTokens.lightColors.warning.withValues(alpha: AppOpacity.darkTint)
              : AppTokens.lightColors.warning.withValues(alpha: AppOpacity.overlay))
          : colors.errorContainer;
      fg = optional ? AppTokens.lightColors.warning : colors.error;
    }

    final spacing = AppTokens.spacing;
    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.md,
        vertical: spacing.xsPlus,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppTokens.radius.sm,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontSize: AppTokens.typography.caption.fontSize,
          fontWeight: AppTokens.fontWeight.semiBold,
        ),
      ),
    );
  }
}
