import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'responsive_provider.dart';

/// Automatically adapts to screen size via [ResponsiveProvider].
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: (spacing.md - spacing.micro) * spacingScale,
        vertical: spacing.xsPlus * spacingScale,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTokens.radius.pill,
        border: Border.all(color: foreground.withValues(alpha: AppOpacity.borderEmphasis)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTokens.iconSize.xs * scale, color: foreground),
          SizedBox(width: AppTokens.spacing.xs * spacingScale),
          Text(
            label,
            style: AppTokens.typography.captionScaled(scale).copyWith(
                  fontWeight: AppTokens.fontWeight.semiBold,
                  color: foreground,
                ),
          ),
        ],
      ),
    );
  }
}

