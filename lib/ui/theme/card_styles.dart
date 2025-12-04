import 'package:flutter/material.dart';

Color elevatedCardBackground(ThemeData theme, {bool solid = false}) {
  final colors = theme.colorScheme;
  if (solid) {
    return theme.brightness == Brightness.dark
        ? colors.surfaceContainerHighest
        : colors.surface;
  }
  if (theme.brightness == Brightness.dark) {
    return colors.surfaceContainerHighest.withValues(alpha: 0.78);
  }
  return Color.alphaBlend(
    colors.primary.withValues(alpha: 0.06),
    colors.surface,
  );
}

Color elevatedCardBorder(ThemeData theme, {bool solid = false}) {
  final colors = theme.colorScheme;
  final double alpha = theme.brightness == Brightness.dark ? 0.28 : 0.16;
  if (solid) {
    return colors.outlineVariant.withValues(alpha: alpha);
  }
  return colors.primary.withValues(alpha: alpha);
}
