import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'responsive_provider.dart';

/// A unified info chip for displaying icon + label pairs.
///
/// Used in forms and summaries to show scope, summary, or status information
/// in a pill-shaped container.
/// Automatically adapts to screen size via [ResponsiveProvider].
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

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.mdLg * spacingScale,
        vertical: spacing.smMd * spacingScale,
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
          Icon(icon, size: AppTokens.iconSize.sm * scale, color: colors.primary),
          SizedBox(width: spacing.sm * spacingScale),
          Flexible(
            child: Text(
              label,
              style: AppTokens.typography.bodyScaled(scale).copyWith(
                fontWeight: AppTokens.fontWeight.semiBold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

