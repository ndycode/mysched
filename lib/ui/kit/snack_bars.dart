import 'package:flutter/material.dart';

import '../theme/tokens.dart';

enum AppSnackBarType { info, success, error }

void showAppSnackBar(
  BuildContext context,
  String message, {
  AppSnackBarType type = AppSnackBarType.info,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 3),
  bool replaceQueue = true,
}) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final media = MediaQuery.of(context);
  final spacing = AppTokens.spacing;

  late final Color accent;
  late final IconData icon;
  late final Color background;
  late final Color borderColor;
  late final Color contentColor;
  late final Color badgeFill;

  switch (type) {
    case AppSnackBarType.success:
      accent = colors.tertiary;
      background = theme.brightness == Brightness.dark
          ? colors.surfaceContainerHigh
          : colors.surface;
      borderColor = theme.brightness == Brightness.dark
          ? colors.outline.withValues(alpha: 0.12)
          : colors.outlineVariant;
      contentColor = colors.onSurface;
      badgeFill = accent.withValues(alpha: 0.12);
      icon = Icons.check_circle_rounded;
      break;
    case AppSnackBarType.error:
      accent = colors.error;
      background = theme.brightness == Brightness.dark
          ? colors.surfaceContainerHigh
          : colors.surface;
      borderColor = theme.brightness == Brightness.dark
          ? colors.outline.withValues(alpha: 0.12)
          : colors.outlineVariant;
      contentColor = colors.onSurface;
      badgeFill = accent.withValues(alpha: 0.12);
      icon = Icons.error_outline_rounded;
      break;
    case AppSnackBarType.info:
      accent = colors.primary;
      background = theme.brightness == Brightness.dark
          ? colors.surfaceContainerHigh
          : colors.surface;
      borderColor = theme.brightness == Brightness.dark
          ? colors.outline.withValues(alpha: 0.12)
          : colors.outlineVariant;
      contentColor = colors.onSurface;
      badgeFill = accent.withValues(alpha: 0.12);
      icon = Icons.info_outline_rounded;
      break;
  }

  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    duration: duration,
    margin: EdgeInsets.fromLTRB(
      spacing.xl,
      0,
      spacing.xl,
      media.padding.bottom + 10,
    ),
    padding: EdgeInsets.symmetric(
      horizontal: spacing.xl,
      vertical: spacing.lg,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: AppTokens.radius.xl,
      side: BorderSide(
        color: borderColor,
        width: theme.brightness == Brightness.dark ? 1 : 0.5,
      ),
    ),
    backgroundColor: background,
    elevation: 0, // We will use a custom shadow via decoration if possible, but SnackBar doesn't support it easily. 
    // Actually, SnackBar elevation is the best way to get shadow. Let's keep it but maybe adjust.
    // Wait, if I want a specific shadow color/blur, I might need to wrap content in a Material, but SnackBar is special.
    // Let's stick to elevation but ensure the background and border are premium.
    // To get the "premium" shadow, we can't easily do it on SnackBar widget itself without custom painter.
    // Standard elevation 6 is okay, but let's see if we can improve.
    // For now, I will stick to standard elevation but updated border/radius/colors.
    content: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: badgeFill,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: accent, size: 18),
        ),
        SizedBox(width: spacing.md),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: contentColor,
            ),
          ),
        ),
      ],
    ),
    action: (actionLabel != null && onAction != null)
        ? SnackBarAction(
            label: actionLabel,
            onPressed: onAction,
            textColor: accent,
          )
        : null,
  );

  final messenger = ScaffoldMessenger.of(context);
  if (replaceQueue) {
    messenger
      ..clearSnackBars()
      ..hideCurrentSnackBar();
  }
  messenger.showSnackBar(snackBar);
}

void hideAppSnackBars(BuildContext context) {
  ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
}
