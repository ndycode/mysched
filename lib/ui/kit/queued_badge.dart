import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/tokens.dart';
import 'responsive_provider.dart';

/// Small pill badge to indicate queued/offline items.
/// Features subtle breathing animation to indicate pending state.
/// Automatically adapts to screen size via [ResponsiveProvider].
class QueuedBadge extends StatelessWidget {
  const QueuedBadge({super.key, this.label = 'Queued'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return Container(
      padding: AppTokens.spacing.edgeInsetsSymmetric(
        horizontal: AppTokens.spacing.sm * spacingScale,
        vertical: AppTokens.spacing.xs * spacingScale,
      ),
      decoration: BoxDecoration(
        color: colors.secondary.withValues(alpha: AppOpacity.statusBg),
        borderRadius: AppTokens.radius.pill,
      ),
      child: Text(
        label,
        style: AppTokens.typography.captionScaled(scale).copyWith(
              color: colors.secondary,
              fontWeight: AppTokens.fontWeight.bold,
            ),
      ),
    ).appBreathing();
  }
}
