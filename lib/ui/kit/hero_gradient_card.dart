import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A token-driven hero gradient card (Dashboard upcoming class style).
///
/// Provides a gradient background with shadow, typically used for
/// prominent "hero" content like the next upcoming class.
class HeroGradientCard extends StatelessWidget {
  const HeroGradientCard({
    super.key,
    required this.child,
    this.onTap,
    this.tint,
    this.padding,
  });

  /// The content to display inside the card.
  final Widget child;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Optional tint color (defaults to primary).
  final Color? tint;

  /// Optional padding override.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final tintColor = tint ?? colors.primary;

    final cardContent = Container(
      padding: padding ?? spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tintColor,
            tintColor.withValues(alpha: AppOpacity.prominent),
          ],
        ),
        borderRadius: AppTokens.radius.lg,
        boxShadow: [
          BoxShadow(
            color: tintColor.withValues(alpha: AppOpacity.ghost),
            blurRadius: AppTokens.shadow.xl,
            offset: AppShadowOffset.lg,
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return cardContent;

    return Material(
      color: Colors.transparent,
      borderRadius: AppTokens.radius.lg,
      child: InkWell(
        borderRadius: AppTokens.radius.lg,
        onTap: onTap,
        child: cardContent,
      ),
    );
  }
}
