import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/tokens.dart';
import 'buttons.dart';

// ═══════════════════════════════════════════════════════════════════════════
// UNIFIED MODAL ROUTE - Single animation system for all modals
// ═══════════════════════════════════════════════════════════════════════════

/// Base modal route with smooth barrier fade animation.
class _AppModalRoute<T> extends PopupRoute<T> {
  _AppModalRoute({
    required this.builder,
    required this.barrierDismissible,
    required this.transition,
    this.barrierLabel,
    Color? barrierColor,
  }) : _barrierColor = barrierColor;

  final WidgetBuilder builder;
  @override
  final bool barrierDismissible;
  @override
  final String? barrierLabel;
  final _ModalTransition transition;
  final Color? _barrierColor;

  @override
  Color get barrierColor => _barrierColor ?? AppBarrier.heavy;

  @override
  Duration get transitionDuration => AppMotionSystem.medium;

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
    switch (transition) {
      case _ModalTransition.slideUp:
        return _buildSlideTransition(animation, child);
      case _ModalTransition.scale:
        return _buildScaleTransition(animation, child);
    }
  }

  Widget _buildSlideTransition(Animation<double> animation, Widget child) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.easeOut,
      reverseCurve: AppMotionSystem.easeIn,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  }

  Widget _buildScaleTransition(Animation<double> animation, Widget child) {
    final fade = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, AppMotionSystem.intervalHalf, curve: AppMotionSystem.easeOut),
      reverseCurve: const Interval(AppMotionSystem.intervalHalf, 1.0, curve: AppMotionSystem.easeIn),
    );
    final scale = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.overshoot,
      reverseCurve: AppMotionSystem.easeIn,
    );
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(fade),
      child: ScaleTransition(
        scale: Tween<double>(begin: AppMotionSystem.scalePageTransition, end: 1.0).animate(scale),
        child: child,
      ),
    );
  }
}

enum _ModalTransition { slideUp, scale }

// ═══════════════════════════════════════════════════════════════════════════
// APP MODAL - Unified modal API
// ═══════════════════════════════════════════════════════════════════════════

/// Global modal system with consistent animations.
///
/// Use [AppModal.sheet] for content panels (details, forms, pickers).
/// Use [AppModal.alert] for dialogs (confirmations, prompts).
class AppModal {
  const AppModal._();

  /// Shows a sheet sliding up from bottom.
  ///
  /// Use for: details views, forms, pickers, previews.
  static Future<T?> sheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool dismissible = true,
  }) {
    return Navigator.of(context).push<T>(
      _AppModalRoute<T>(
        builder: builder,
        barrierDismissible: dismissible,
        barrierLabel: 'Dismiss',
        transition: _ModalTransition.slideUp,
      ),
    );
  }

  /// Shows a dialog scaling from center.
  ///
  /// Use for: confirmations, alerts, prompts.
  static Future<T?> alert<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool dismissible = true,
    bool useRootNavigator = true,
    Color? barrierColor,
  }) {
    return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
      _AppModalRoute<T>(
        builder: builder,
        barrierDismissible: dismissible,
        barrierLabel: 'Dismiss',
        transition: _ModalTransition.scale,
        barrierColor: barrierColor,
      ),
    );
  }

  /// Shows a confirmation dialog with confirm/cancel actions.
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDanger = false,
  }) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    return alert<bool>(
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
            fontWeight: AppTokens.fontWeight.bold,
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
            onPressed: () => Navigator.of(context).pop(false),
            minHeight: AppTokens.componentSize.buttonSm,
            expanded: false,
          ),
          if (isDanger)
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
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
              onPressed: () => Navigator.of(context).pop(true),
              minHeight: AppTokens.componentSize.buttonSm,
              expanded: false,
            ),
        ],
      ),
    );
  }

  /// Shows an info alert with single action.
  static Future<void> info({
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

    return alert<void>(
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
                  fontWeight: AppTokens.fontWeight.bold,
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

  /// Shows an input dialog.
  static Future<String?> input({
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

    final result = await alert<String>(
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
            fontWeight: AppTokens.fontWeight.bold,
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
                  borderSide: BorderSide(color: colors.primary, width: AppTokens.componentSize.dividerThick),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // LEGACY API - Deprecated, use new methods above
  // ═══════════════════════════════════════════════════════════════════════════

  /// @deprecated Use [AppModal.confirm] instead.
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDanger = false,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return confirm(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDanger: isDanger,
    );
  }

  /// @deprecated Use [AppModal.info] instead.
  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    String actionLabel = 'OK',
    IconData? icon,
    Color? iconColor,
  }) {
    return info(
      context: context,
      title: title,
      message: message,
      actionLabel: actionLabel,
      icon: icon,
      iconColor: iconColor,
    );
  }

  /// @deprecated Use [AppModal.input] instead.
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
  }) {
    return input(
      context: context,
      title: title,
      message: message,
      initialValue: initialValue,
      hintText: hintText,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LEGACY FUNCTIONS - Deprecated, use AppModal instead
// ═══════════════════════════════════════════════════════════════════════════

/// @deprecated Use [AppModal.alert] instead.
Future<T?> showSmoothDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String? barrierLabel = 'Dismiss',
  Color? barrierColor,
  Duration? transitionDuration,
  bool useRootNavigator = true,
}) {
  return AppModal.alert<T>(
    context: context,
    builder: builder,
    dismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
  );
}
