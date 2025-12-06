import 'package:flutter/material.dart';

import 'tokens.dart';

Color elevatedCardBackground(ThemeData theme, {bool solid = false}) {
  final colors = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;
  if (solid) {
    return isDark ? colors.surfaceContainerHigh : colors.surface;
  }
  if (isDark) {
    return colors.surfaceContainerHigh.withValues(alpha: AppOpacity.glassCard);
  }
  return Color.alphaBlend(
    colors.primary.withValues(alpha: AppOpacity.veryFaint),
    colors.surface,
  );
}

Color elevatedCardBorder(ThemeData theme, {bool solid = false}) {
  final colors = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;
  if (solid) {
    return isDark
        ? colors.outline.withValues(alpha: AppOpacity.overlay)
        : colors.outline;
  }
  final double alpha = isDark ? AppOpacity.shadowAction : AppOpacity.statusBg;
  return colors.primary.withValues(alpha: alpha);
}

double elevatedCardBorderWidth(ThemeData theme) {
  return theme.brightness == Brightness.dark
      ? AppTokens.componentSize.divider
      : AppTokens.componentSize.dividerThin;
}
