import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Icon box size variants.
enum IconBoxSize {
  /// Small icon box (sm padding, sm icon).
  sm,

  /// Medium icon box (md padding, md icon).
  md,
}

/// A token-driven icon container with tinted background.
///
/// Used for small decorative icon backgrounds in hero cards,
/// list items, and detail rows.
class IconBox extends StatelessWidget {
  const IconBox({
    super.key,
    required this.icon,
    this.tint,
    this.size = IconBoxSize.sm,
    this.backgroundAlpha,
  });

  /// The icon to display.
  final IconData icon;

  /// Optional tint color (defaults to onPrimary for hero contexts).
  final Color? tint;

  /// The size variant.
  final IconBoxSize size;

  /// Optional background alpha override.
  final double? backgroundAlpha;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final tintColor = tint ?? colors.onPrimary;
    final alpha = backgroundAlpha ?? AppOpacity.medium;

    final paddingValue = size == IconBoxSize.sm ? spacing.sm : spacing.md;
    final iconSize =
        size == IconBoxSize.sm ? AppTokens.iconSize.sm : AppTokens.iconSize.md;
    final radius =
        size == IconBoxSize.sm ? AppTokens.radius.sm : AppTokens.radius.md;

    return Container(
      padding: spacing.edgeInsetsAll(paddingValue),
      decoration: BoxDecoration(
        color: tintColor.withValues(alpha: alpha),
        borderRadius: radius,
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: tintColor,
      ),
    );
  }
}
