import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A unified info chip for displaying icon + label pairs.
///
/// Used in forms and summaries to show scope, summary, or status information
/// in a pill-shaped container.
class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
  });

  /// Icon to display
  final IconData icon;

  /// Label text
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.md + spacing.xs / 2,
        vertical: spacing.sm + spacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: AppOpacity.track),
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: AppOpacity.track),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTokens.iconSize.sm, color: colors.primary),
          SizedBox(width: spacing.sm),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
