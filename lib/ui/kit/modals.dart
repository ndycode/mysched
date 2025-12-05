import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/tokens.dart';
import 'buttons.dart';

/// Custom dialog route with smooth fade/scale transition.
class _SmoothDialogRoute<T> extends PopupRoute<T> {
  _SmoothDialogRoute({
    required this.builder,
    required this.barrierDismissible,
    this.barrierLabel,
    Color? barrierColor,
    Duration? transitionDuration,
  })  : _barrierColor = barrierColor ?? AppBarrier.heavy,
        _transitionDuration = transitionDuration ?? AppMotionSystem.medium;

  final WidgetBuilder builder;
  @override
  final bool barrierDismissible;
  @override
  final String? barrierLabel;
  final Color _barrierColor;
  final Duration _transitionDuration;

  @override
  Color get barrierColor => _barrierColor;

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  Duration get reverseTransitionDuration => AppMotionSystem.quick;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.5, curve: AppMotionSystem.easeOut),
      reverseCurve: const Interval(0.5, 1.0, curve: AppMotionSystem.easeIn),
    );

    final scaleAnimation = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.overshoot,
      reverseCurve: AppMotionSystem.easeIn,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(fadeAnimation),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(scaleAnimation),
        child: child,
      ),
    );
  }
}

/// Shows a smooth dialog with fade/scale transition using AppMotionSystem.
Future<T?> showSmoothDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String? barrierLabel = 'Dismiss',
  Color? barrierColor,
  Duration? transitionDuration,
}) {
  return Navigator.of(context, rootNavigator: true).push<T>(
    _SmoothDialogRoute<T>(
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      barrierColor: barrierColor,
      transitionDuration: transitionDuration,
    ),
  );
}

/// Global modal configuration for consistent dialogs across the app.
class AppModal {
  /// Shows a standardized confirmation dialog.
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDanger = false,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    return showSmoothDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sheet),
        titlePadding: spacing.edgeInsetsOnly(
          left: spacing.xl,
          right: spacing.xl,
          top: spacing.xl,
          bottom: spacing.sm,
        ),
        contentPadding: spacing.edgeInsetsOnly(
          left: spacing.xl,
          right: spacing.xl,
          bottom: spacing.lg,
        ),
        actionsPadding: spacing.edgeInsetsAll(spacing.lg),
        title: Text(
          title,
          style: AppTokens.typography.title.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        content: Text(
          message,
          style: AppTokens.typography.body.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        actions: [
          SecondaryButton(
            label: cancelLabel,
            onPressed: () {
              onCancel?.call();
              Navigator.of(context).pop(false);
            },
            minHeight: AppTokens.componentSize.buttonSm,
            expanded: false,
          ),
          if (isDanger)
            FilledButton(
              onPressed: () {
                onConfirm?.call();
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
                minimumSize: Size(0, AppTokens.componentSize.buttonSm),
                padding: spacing.edgeInsetsSymmetric(
                  horizontal: spacing.xl,
                  vertical: spacing.md,
                ),
                shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xxl),
              ),
              child: Text(confirmLabel),
            )
          else
            PrimaryButton(
              label: confirmLabel,
              onPressed: () {
                onConfirm?.call();
                Navigator.of(context).pop(true);
              },
              minHeight: AppTokens.componentSize.buttonSm,
              expanded: false,
            ),
        ],
      ),
    );
  }

  /// Shows a standardized alert dialog (single action).
  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    String actionLabel = 'OK',
    IconData? icon,
    Color? iconColor,
  }) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    return showSmoothDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sheet),
        titlePadding: spacing.edgeInsetsOnly(
          left: spacing.xl,
          right: spacing.xl,
          top: spacing.xl,
          bottom: spacing.sm,
        ),
        contentPadding: spacing.edgeInsetsOnly(
          left: spacing.xl,
          right: spacing.xl,
          bottom: spacing.lg,
        ),
        actionsPadding: spacing.edgeInsetsAll(spacing.lg),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? colors.primary, size: AppTokens.iconSize.lg),
              SizedBox(width: spacing.md),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTokens.typography.title.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTokens.typography.body.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        actions: [
          PrimaryButton(
            label: actionLabel,
            onPressed: () => Navigator.of(context).pop(),
            minHeight: AppTokens.componentSize.buttonSm,
            expanded: false,
          ),
        ],
      ),
    );
  }

  /// Shows a standardized input dialog.
  static Future<String?> showInputDialog({
    required BuildContext context,
    required String title,
    String? message,
    String? initialValue,
    String? hintText,
    String confirmLabel = 'Save',
    String cancelLabel = 'Cancel',
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final controller = TextEditingController(text: initialValue);

    final result = await showSmoothDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sheet),
        titlePadding: spacing.edgeInsetsOnly(
          left: spacing.xl,
          right: spacing.xl,
          top: spacing.xl,
          bottom: spacing.sm,
        ),
        contentPadding: spacing.edgeInsetsOnly(
          left: spacing.xl,
          right: spacing.xl,
          bottom: spacing.lg,
        ),
        actionsPadding: spacing.edgeInsetsAll(spacing.lg),
        title: Text(
          title,
          style: AppTokens.typography.title.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message != null) ...[
              Text(
                message,
                style: AppTokens.typography.body.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: spacing.lg),
            ],
            TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              autofocus: true,
              decoration: InputDecoration(
                hintText: hintText,
                filled: true,
                fillColor: colors.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle),
                border: OutlineInputBorder(
                  borderRadius: AppTokens.radius.md,
                  borderSide: BorderSide(color: colors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppTokens.radius.md,
                  borderSide: BorderSide(color: colors.outline.withValues(alpha: AppOpacity.subtle)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppTokens.radius.md,
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
                contentPadding: spacing.edgeInsetsAll(spacing.md),
              ),
            ),
          ],
        ),
        actions: [
          SecondaryButton(
            label: cancelLabel,
            onPressed: () => Navigator.of(context).pop(null),
            minHeight: AppTokens.componentSize.buttonSm,
            expanded: false,
          ),
          PrimaryButton(
            label: confirmLabel,
            onPressed: () => Navigator.of(context).pop(controller.text),
            minHeight: AppTokens.componentSize.buttonSm,
            expanded: false,
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }
}
