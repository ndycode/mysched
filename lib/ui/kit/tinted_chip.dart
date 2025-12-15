import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A token-driven tinted chip/badge for labels and counts.
///
/// Used for small inline labels like class counts, status indicators,
/// and category tags.
class TintedChip extends StatelessWidget {
  const TintedChip({
    super.key,
    required this.label,
    this.tint,
    this.backgroundAlpha,
    this.icon,
  });

  /// The text label to display.
  final String label;

  /// Optional tint color (defaults to primary).
  final Color? tint;

  /// Optional background alpha override.
  final double? backgroundAlpha;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final tintColor = tint ?? colors.primary;
    final alpha = backgroundAlpha ?? AppOpacity.overlay;

    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.sm + spacing.micro,
        vertical: spacing.xs + spacing.microHalf,
      ),
      decoration: BoxDecoration(
        color: tintColor.withValues(alpha: alpha),
        borderRadius: AppTokens.radius.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppTokens.iconSize.xs, color: tintColor),
            SizedBox(width: spacing.xs),
          ],
          Text(
            label,
            style: AppTokens.typography.caption.copyWith(
              fontWeight: AppTokens.fontWeight.bold,
              color: tintColor,
            ),
          ),
        ],
      ),
    );
  }
}
