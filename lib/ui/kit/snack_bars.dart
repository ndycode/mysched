import 'package:flutter/material.dart';

import '../theme/tokens.dart';

enum AppSnackBarType { info, success, error }

void showAppSnackBar(
  BuildContext context,
  String message, {
  AppSnackBarType type = AppSnackBarType.info,
  String? actionLabel,
  VoidCallback? onAction,
  Duration? duration,
  bool replaceQueue = true,
  bool useRootScaffold = true,
}) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;
  final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
  final media = MediaQuery.of(context);
  final spacing = AppTokens.spacing;
  final effectiveDuration = duration ?? AppTokens.durations.snackbarDuration;

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
          ? colors.outline.withValues(alpha: AppOpacity.overlay)
          : colors.outlineVariant;
      contentColor = colors.onSurface;
      badgeFill = accent.withValues(alpha: AppOpacity.overlay);
      icon = Icons.check_circle_rounded;
      break;
    case AppSnackBarType.error:
      accent = palette.danger;
      background = theme.brightness == Brightness.dark
          ? colors.surfaceContainerHigh
          : colors.surface;
      borderColor = theme.brightness == Brightness.dark
          ? colors.outline.withValues(alpha: AppOpacity.overlay)
          : colors.outlineVariant;
      contentColor = colors.onSurface;
      badgeFill = accent.withValues(alpha: AppOpacity.overlay);
      icon = Icons.error_outline_rounded;
      break;
    case AppSnackBarType.info:
      accent = colors.primary;
      background = theme.brightness == Brightness.dark
          ? colors.surfaceContainerHigh
          : colors.surface;
      borderColor = theme.brightness == Brightness.dark
          ? colors.outline.withValues(alpha: AppOpacity.overlay)
          : colors.outlineVariant;
      contentColor = colors.onSurface;
      badgeFill = accent.withValues(alpha: AppOpacity.overlay);
      icon = Icons.info_outline_rounded;
      break;
  }

  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    duration: effectiveDuration,
    margin: EdgeInsets.fromLTRB(
      spacing.xl,
      0,
      spacing.xl,
      media.padding.bottom + spacing.sm,
    ),
    padding: EdgeInsets.symmetric(
      horizontal: spacing.xl,
      vertical: spacing.lg,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: AppTokens.radius.xl,
      side: BorderSide(
        color: borderColor,
        width: theme.brightness == Brightness.dark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
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
          width: AppTokens.componentSize.avatarMd,
          height: AppTokens.componentSize.avatarMd,
          decoration: BoxDecoration(
            color: badgeFill,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: accent, size: AppTokens.iconSize.sm),
        ),
        SizedBox(width: spacing.md),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: AppTokens.fontWeight.semiBold,
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

  ScaffoldMessengerState? messenger;
  if (useRootScaffold) {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    messenger = ScaffoldMessenger.maybeOf(rootContext);
  }
  messenger ??= ScaffoldMessenger.maybeOf(context);

  if (replaceQueue) {
    messenger
      ?..clearSnackBars()
      ..hideCurrentSnackBar();
  }
  messenger?.showSnackBar(snackBar);
}

void hideAppSnackBars(BuildContext context) {
  ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
  final rootContext = Navigator.of(context, rootNavigator: true).context;
  if (rootContext != context) {
    ScaffoldMessenger.maybeOf(rootContext)?.clearSnackBars();
  }
}
