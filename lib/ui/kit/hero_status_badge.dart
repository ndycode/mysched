import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A token-driven status badge for hero cards (Live Now, Coming Up, etc.).
///
/// Used inside gradient hero cards to show live/upcoming status
/// with optional pulsing indicator.
class HeroStatusBadge extends StatelessWidget {
  const HeroStatusBadge({
    super.key,
    required this.label,
    this.isLive = false,
    this.foreground,
  });

  /// The status label text.
  final String label;

  /// Whether to show the live pulsing indicator.
  final bool isLive;

  /// Optional foreground color (defaults to onPrimary).
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final fg = foreground ?? colors.onPrimary;

    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.md,
        vertical: spacing.sm - spacing.micro,
      ),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: AppOpacity.border),
        borderRadius: AppTokens.radius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive)
            Container(
              width: AppTokens.componentSize.badgeSm,
              height: AppTokens.componentSize.badgeSm,
              margin: EdgeInsets.only(right: spacing.sm),
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: fg.withValues(alpha: AppOpacity.subtle),
                    blurRadius: AppTokens.shadow.xs,
                    spreadRadius: AppTokens.componentSize.divider,
                  ),
                ],
              ),
            )
          else
            Icon(
              Icons.schedule_rounded,
              size: AppTokens.iconSize.sm,
              color: fg,
            ),
          if (!isLive) SizedBox(width: spacing.xs + spacing.micro),
          Text(
            label,
            style: AppTokens.typography.caption.copyWith(
              fontWeight: AppTokens.fontWeight.semiBold,
              color: fg,
              letterSpacing: AppLetterSpacing.wider,
            ),
          ),
        ],
      ),
    );
  }
}
