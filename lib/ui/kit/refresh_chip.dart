import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A chip that displays a refresh status label.
///
/// Used in dashboard summary cards to show last refresh time.
class RefreshChip extends StatelessWidget {
  const RefreshChip({
    super.key,
    required this.label,
  });

  /// Label to display (e.g., "Just now", "2m ago")
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.smMd,
        vertical: spacing.xsPlus,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: isDark ? AppOpacity.shadowAction : AppOpacity.overlay),
        borderRadius: AppTokens.radius.pill,
        border: Border.all(
          color: colors.primary.withValues(alpha: isDark ? AppOpacity.divider : AppOpacity.shadowBubble),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.refresh_rounded,
            size: AppTokens.iconSize.xs,
            color: colors.primary,
          ),
          SizedBox(width: spacing.xsPlus),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: AppTokens.typography.caption.fontSize,
              fontWeight: AppTokens.fontWeight.semiBold,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
