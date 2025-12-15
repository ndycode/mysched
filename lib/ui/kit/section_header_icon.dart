import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A token-driven gradient icon box used in section headers (Dashboard-style).
///
/// Displays an icon inside a gradient container with a subtle border,
/// typically used as the leading element in a section header row.
class SectionHeaderIcon extends StatelessWidget {
  const SectionHeaderIcon({
    super.key,
    required this.icon,
    this.tint,
    this.size,
  });

  /// The icon to display.
  final IconData icon;

  /// Optional tint color (defaults to primary).
  final Color? tint;

  /// Optional size override (defaults to avatarXl).
  final double? size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tintColor = tint ?? colors.primary;
    final boxSize = size ?? AppTokens.componentSize.avatarXl;

    return Container(
      height: boxSize,
      width: boxSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tintColor.withValues(alpha: AppOpacity.medium),
            tintColor.withValues(alpha: AppOpacity.dim),
          ],
        ),
        borderRadius: AppTokens.radius.md,
        border: Border.all(
          color: tintColor.withValues(alpha: AppOpacity.borderEmphasis),
          width: AppTokens.componentSize.dividerThick,
        ),
      ),
      child: Icon(
        icon,
        color: tintColor,
        size: AppTokens.iconSize.xl,
      ),
    );
  }
}
