import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A token-driven gradient header card for section headers (day headers, etc.).
///
/// Provides a subtle gradient background with border, typically used for
/// grouping headers like day labels in schedule lists.
class GradientHeaderCard extends StatelessWidget {
  const GradientHeaderCard({
    super.key,
    required this.child,
    this.tint,
    this.isHighlighted = false,
    this.padding,
  });

  /// The content to display inside the header.
  final Widget child;

  /// Optional tint color (defaults to primary).
  final Color? tint;

  /// Whether this header is in a highlighted/emphasized state.
  final bool isHighlighted;

  /// Optional padding override.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final tintColor = tint ?? colors.primary;

    return Container(
      padding: padding ?? spacing.edgeInsetsAll(spacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tintColor.withValues(
                alpha: isHighlighted ? AppOpacity.medium : AppOpacity.dim),
            tintColor.withValues(alpha: AppOpacity.veryFaint),
          ],
        ),
        borderRadius: AppTokens.radius.md,
        border: Border.all(
          color: tintColor.withValues(
              alpha: isHighlighted ? AppOpacity.dim : AppOpacity.accent),
          width: isHighlighted
              ? AppTokens.componentSize.dividerThick
              : AppTokens.componentSize.divider,
        ),
      ),
      child: child,
    );
  }
}
