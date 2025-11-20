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
  final radius = AppTokens.radius;

  late final Color accent;
  late final IconData icon;
  late final Color background;
  late final Color borderColor;
  late final Color contentColor;
  late final Color badgeFill;

  switch (type) {
    case AppSnackBarType.success:
      accent = colors.tertiary;
      background = colors.surfaceContainerHigh;
      borderColor = accent.withValues(alpha: 0.28);
      contentColor = colors.onSurface;
      badgeFill = accent.withValues(alpha: 0.18);
      icon = Icons.check_circle_rounded;
      break;
    case AppSnackBarType.error:
      accent = colors.error;
      background = colors.surfaceContainerHigh;
      borderColor = accent.withValues(alpha: 0.28);
      contentColor = colors.onSurface;
      badgeFill = accent.withValues(alpha: 0.18);
      icon = Icons.error_outline_rounded;
      break;
    case AppSnackBarType.info:
      accent = colors.primary;
      background = colors.surfaceContainerHigh;
      borderColor = accent.withValues(alpha: 0.24);
      contentColor = colors.onSurface;
      badgeFill = accent.withValues(alpha: 0.18);
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
      borderRadius: radius.lg,
      side: BorderSide(color: borderColor, width: 1.2),
    ),
    backgroundColor: background,
    elevation: 6,
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
