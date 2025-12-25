import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/tokens.dart';

/// Surface card variants controlling shadow intensity.
enum SurfaceCardVariant {
  /// Standard card with subtle shadow.
  standard,

  /// Elevated card with more prominent shadow (hero sections).
  elevated,
}

/// A token-driven surface card used for section blocks (Dashboard-style).
///
/// This centralizes the repeated "surface + outline + subtle shadow" chrome
/// so screens don't duplicate BoxDecoration and drift over time.
/// Features smooth entrance animation.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.variant = SurfaceCardVariant.standard,
    this.animate = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final SurfaceCardVariant variant;
  /// Whether to animate entrance. Set to false for lists to avoid stutter.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    final shadowOffset = variant == SurfaceCardVariant.elevated
        ? AppShadowOffset.hero
        : AppShadowOffset.sm;
    final shadowAlpha = variant == SurfaceCardVariant.elevated
        ? AppOpacity.highlight
        : AppOpacity.veryFaint;
    final shadowSource = variant == SurfaceCardVariant.elevated
        ? colors.outline
        : colors.shadow;

    final card = Container(
      padding: padding ?? spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark ? colors.surfaceContainerHigh : colors.surface),
        borderRadius: borderRadius ?? AppTokens.radius.xl,
        border: Border.all(
          color: isDark
              ? colors.outline.withValues(alpha: AppOpacity.overlay)
              : colors.outline,
          width: isDark
              ? AppTokens.componentSize.divider
              : AppTokens.componentSize.dividerThin,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: shadowSource.withValues(alpha: shadowAlpha),
                  blurRadius: AppTokens.shadow.lg,
                  offset: shadowOffset,
                ),
              ],
      ),
      child: child,
    );

    Widget result = card;
    if (margin != null) {
      result = Padding(padding: margin!, child: card);
    }

    if (!animate) return result;

    return result.appFadeIn();
  }
}
