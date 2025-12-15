import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A token-driven hero chip for use inside gradient hero cards.
///
/// Provides a pill-shaped chip with icon, label, and border,
/// typically used for metadata display on hero cards.
class HeroChip extends StatelessWidget {
  const HeroChip({
    super.key,
    required this.icon,
    required this.label,
    this.background,
    this.foreground,
  });

  /// The leading icon.
  final IconData icon;

  /// The text label.
  final String label;

  /// Optional background color.
  final Color? background;

  /// Optional foreground color (defaults to onPrimary).
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final fg = foreground ?? colors.onPrimary;
    final bg = background ?? fg.withValues(alpha: AppOpacity.border);

    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.sm + spacing.micro,
        vertical: spacing.xs + spacing.microHalf,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppTokens.radius.pill,
        border: Border.all(
          color: fg.withValues(alpha: AppOpacity.borderEmphasis),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTokens.iconSize.xs, color: fg),
          SizedBox(width: spacing.xs + spacing.micro),
          Text(
            label,
            style: AppTokens.typography.caption.copyWith(
              fontWeight: AppTokens.fontWeight.semiBold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
