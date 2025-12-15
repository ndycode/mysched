import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A token-driven list item card with optional emphasis state.
///
/// Used for list rows that need surface card styling with optional
/// highlighted border/shadow for active or selected states.
class ListItemCard extends StatelessWidget {
  const ListItemCard({
    super.key,
    required this.child,
    this.onTap,
    this.isEmphasized = false,
    this.isDisabled = false,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.showBorder = true,
  });

  /// The content to display inside the card.
  final Widget child;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Whether to show emphasized styling (highlighted border/shadow).
  final bool isEmphasized;

  /// Whether the item is disabled (muted styling).
  final bool isDisabled;

  /// Optional padding override.
  final EdgeInsetsGeometry? padding;

  /// Optional background color override.
  final Color? backgroundColor;

  /// Optional border radius override.
  final BorderRadius? borderRadius;

  /// Whether to show a border.
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;
    final radius = borderRadius ?? AppTokens.radius.md;

    final cardContent = Container(
      padding: padding ?? spacing.edgeInsetsAll(spacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark ? colors.surfaceContainerHigh : colors.surface),
        borderRadius: radius,
        border: showBorder
            ? Border.all(
                color: isEmphasized && !isDisabled
                    ? colors.primary.withValues(alpha: AppOpacity.ghost)
                    : colors.outline.withValues(
                        alpha: isDark ? AppOpacity.overlay : AppOpacity.barrier),
                width: isEmphasized && !isDisabled
                    ? AppTokens.componentSize.dividerThick
                    : AppTokens.componentSize.dividerThin,
              )
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(
                      alpha: isEmphasized && !isDisabled
                          ? AppOpacity.highlight
                          : AppOpacity.faint),
                  blurRadius: isEmphasized && !isDisabled
                      ? AppTokens.shadow.md
                      : AppTokens.shadow.sm,
                  offset: AppShadowOffset.xs,
                ),
              ],
      ),
      child: child,
    );

    if (onTap == null) return cardContent;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: colors.primary.withValues(alpha: AppOpacity.faint),
        highlightColor: colors.primary.withValues(alpha: AppOpacity.faint),
        child: cardContent,
      ),
    );
  }
}
