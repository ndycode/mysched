import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A token-driven avatar placeholder for fallback display.
///
/// Used when an avatar cannot be shown (e.g., instructor view showing
/// section icon instead of their own avatar).
class AvatarPlaceholder extends StatelessWidget {
  const AvatarPlaceholder({
    super.key,
    required this.icon,
    this.size,
    this.tint,
    this.inverse = false,
  });

  /// The icon to display.
  final IconData icon;

  /// Optional size override.
  final double? size;

  /// Optional tint color.
  final Color? tint;

  /// Whether this is on an inverse (dark) background.
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tintColor = tint ?? colors.primary;
    final avatarSize = size ?? AppTokens.componentSize.avatarSmDense;
    final alpha = inverse ? AppOpacity.border : AppOpacity.medium;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        color: tintColor.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(AppTokens.radius.sm.topLeft.x),
      ),
      child: Icon(
        icon,
        size: avatarSize * 0.6,
        color: tintColor,
      ),
    );
  }
}
