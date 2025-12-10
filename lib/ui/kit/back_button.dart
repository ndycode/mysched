import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/tokens.dart';
import 'pressable_scale.dart';
import 'responsive_provider.dart';

/// A styled back button for navigation.
///
/// Used across detail pages and sheets for consistent back navigation.
/// Automatically adapts to screen size via [ResponsiveProvider].
class NavBackButton extends StatelessWidget {
  const NavBackButton({
    super.key,
    this.onTap,
    this.disabled = false,
  });

  /// Optional custom tap handler. If null, uses `context.pop()`.
  final VoidCallback? onTap;

  /// Whether the button is disabled.
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return PressableScale(
      onTap: disabled
          ? null
          : onTap ??
              () {
                if (context.canPop()) {
                  context.pop();
                }
              },
      child: Container(
        padding: spacing.edgeInsetsAll(spacing.sm * spacingScale),
        decoration: BoxDecoration(
          color: colors.onSurface.withValues(alpha: AppOpacity.faint),
          borderRadius: AppTokens.radius.md,
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          size: AppTokens.iconSize.md * scale,
          color: palette.muted,
        ),
      ),
    );
  }
}

