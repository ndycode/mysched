import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A small chip displaying an icon and label with a colored background.
///
/// Use for status indicators like "Pending", "Completed", "Custom", "Synced", etc.
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
        theme.brightness == Brightness.dark ? 0.24 : 0.12;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.spacing.md,
        vertical: AppTokens.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: backgroundOpacity),
        borderRadius: AppTokens.radius.md,
        border: Border.all(color: color.withValues(alpha: AppOpacity.barrier)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTokens.iconSize.sm, color: color),
          SizedBox(width: AppTokens.spacing.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppTokens.spacing.sm),
          decoration: BoxDecoration(
            color: accentIcon
                ? colors.primary.withValues(alpha: AppOpacity.overlay)
                : Colors.transparent,
            borderRadius: AppTokens.radius.sm,
          ),
          child:
              Icon(icon, size: AppTokens.iconSize.md, color: colors.primary),
        ),
        SizedBox(width: AppTokens.spacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTokens.typography.caption.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppTokens.spacing.xs),
              Text(
                value,
                style: AppTokens.typography.subtitle.copyWith(
                  fontWeight: AppTokens.fontWeight.semiBold,
                  color: colors.onSurface,
                ),
              ),
              if (helper != null && helper!.isNotEmpty) ...[
                SizedBox(height: AppTokens.spacing.xs),
                Text(
                  helper!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
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
