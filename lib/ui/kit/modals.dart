import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/tokens.dart';
import 'buttons.dart';
import 'responsive_provider.dart';

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
  Color get barrierColor => _barrierColor ?? _defaultBarrier;

  Color get _defaultBarrier {
    switch (transition) {
      case _ModalTransition.slideUp:
        return AppBarrier.medium; // Sheets: lighter barrier
      case _ModalTransition.scale:
        return AppBarrier.heavy; // Alerts: heavier barrier
    }
  }

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
      curve: const Interval(0.0, AppMotionSystem.intervalHalf,
          curve: AppMotionSystem.easeOut),
      reverseCurve: const Interval(AppMotionSystem.intervalHalf, 1.0,
          curve: AppMotionSystem.easeIn),
    );
    final scale = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.overshoot,
      reverseCurve: AppMotionSystem.easeIn,
    );
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(fade),
      child: ScaleTransition(
        scale:
            Tween<double>(begin: AppMotionSystem.scalePageTransition, end: 1.0)
                .animate(scale),
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
  /// Set [enableDrag] to false to disable swipe-to-dismiss.
  static Future<T?> sheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool dismissible = true,
    bool enableDrag = true,
    Color? barrierColor,
    bool useRootNavigator = true,
  }) {
    final navigator = useRootNavigator
        ? Navigator.of(context, rootNavigator: true)
        : Navigator.of(context);
    return navigator.push<T>(
      _AppModalRoute<T>(
        builder: (ctx) => _DraggableDismissSheet(
          enableDrag: enableDrag && dismissible,
          child: builder(ctx),
        ),
        barrierDismissible: dismissible,
        barrierLabel: 'Dismiss',
        transition: _ModalTransition.slideUp,
        barrierColor: barrierColor,
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
    final navigator = useRootNavigator
        ? Navigator.of(context, rootNavigator: true)
        : Navigator.of(context);
    return navigator.push<T>(
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
    IconData? icon,
  }) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return alert<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: spacing.edgeInsetsAll(spacing.xl * spacingScale),
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppLayout.dialogWidthSmall),
          decoration: BoxDecoration(
            color: isDark ? colors.surfaceContainerHigh : colors.surface,
            borderRadius: AppTokens.radius.xl,
            border: Border.all(
              color: isDark
                  ? colors.outline.withValues(alpha: AppOpacity.overlay)
                  : colors.outline.withValues(alpha: AppOpacity.faint),
              width: AppTokens.componentSize.dividerThin,
            ),
            boxShadow: isDark
                ? null
                : [
                    AppTokens.shadow.modal(
                      colors.shadow.withValues(alpha: AppOpacity.border),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: AppTokens.radius.xl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon
                Container(
                  padding: spacing.edgeInsetsAll(spacing.xl * spacingScale),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: colors.outline.withValues(alpha: AppOpacity.faint),
                        width: AppTokens.componentSize.dividerThin,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: spacing.edgeInsetsAll(spacing.sm * spacingScale),
                        decoration: BoxDecoration(
                          color: (isDanger ? palette.danger : colors.primary)
                              .withValues(alpha: AppOpacity.overlay),
                          borderRadius: AppTokens.radius.sm,
                        ),
                        child: Icon(
                          icon ?? (isDanger ? Icons.warning_rounded : Icons.help_outline_rounded),
                          color: isDanger ? palette.danger : colors.primary,
                          size: AppTokens.iconSize.md * scale,
                        ),
                      ),
                      SizedBox(width: spacing.md * spacingScale),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTokens.typography.subtitleScaled(scale).copyWith(
                            fontWeight: AppTokens.fontWeight.semiBold,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Message content
                Padding(
                  padding: spacing.edgeInsetsAll(spacing.xl * spacingScale),
                  child: Text(
                    message,
                    style: AppTokens.typography.bodyScaled(scale).copyWith(
                      color: palette.muted,
                    ),
                  ),
                ),
                // Footer with buttons
                Container(
                  padding: spacing.edgeInsetsAll(spacing.lg * spacingScale),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colors.outline.withValues(alpha: AppOpacity.faint),
                        width: AppTokens.componentSize.dividerThin,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: cancelLabel,
                          onPressed: () => Navigator.of(context).pop(false),
                          minHeight: AppTokens.componentSize.buttonSm,
                        ),
                      ),
                      SizedBox(width: spacing.md * spacingScale),
                      Expanded(
                        child: isDanger
                            ? DestructiveButton(
                                label: confirmLabel,
                                onPressed: () => Navigator.of(context).pop(true),
                                minHeight: AppTokens.componentSize.buttonSm,
                              )
                            : PrimaryButton(
                                label: confirmLabel,
                                onPressed: () => Navigator.of(context).pop(true),
                                minHeight: AppTokens.componentSize.buttonSm,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final effectiveIconColor = iconColor ?? colors.primary;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return alert<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: spacing.edgeInsetsAll(spacing.xl * spacingScale),
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppLayout.dialogWidthSmall),
          decoration: BoxDecoration(
            color: isDark ? colors.surfaceContainerHigh : colors.surface,
            borderRadius: AppTokens.radius.xl,
            border: Border.all(
              color: isDark
                  ? colors.outline.withValues(alpha: AppOpacity.overlay)
                  : colors.outline.withValues(alpha: AppOpacity.faint),
              width: AppTokens.componentSize.dividerThin,
            ),
            boxShadow: isDark
                ? null
                : [
                    AppTokens.shadow.modal(
                      colors.shadow.withValues(alpha: AppOpacity.border),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: AppTokens.radius.xl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon
                Container(
                  padding: spacing.edgeInsetsAll(spacing.xl * spacingScale),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: colors.outline.withValues(alpha: AppOpacity.faint),
                        width: AppTokens.componentSize.dividerThin,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: spacing.edgeInsetsAll(spacing.sm * spacingScale),
                        decoration: BoxDecoration(
                          color: effectiveIconColor.withValues(alpha: AppOpacity.overlay),
                          borderRadius: AppTokens.radius.sm,
                        ),
                        child: Icon(
                          icon ?? Icons.info_outline_rounded,
                          color: effectiveIconColor,
                          size: AppTokens.iconSize.md * scale,
                        ),
                      ),
                      SizedBox(width: spacing.md * spacingScale),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTokens.typography.subtitleScaled(scale).copyWith(
                            fontWeight: AppTokens.fontWeight.semiBold,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Message content
                Padding(
                  padding: spacing.edgeInsetsAll(spacing.xl * spacingScale),
                  child: Text(
                    message,
                    style: AppTokens.typography.bodyScaled(scale).copyWith(
                      color: palette.muted,
                    ),
                  ),
                ),
                // Footer with button
                Container(
                  padding: spacing.edgeInsetsAll(spacing.lg * spacingScale),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colors.outline.withValues(alpha: AppOpacity.faint),
                        width: AppTokens.componentSize.dividerThin,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: actionLabel,
                      onPressed: () => Navigator.of(context).pop(),
                      minHeight: AppTokens.componentSize.buttonSm,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final controller = TextEditingController(text: initialValue);

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    final result = await alert<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sheet),
        titlePadding: spacing.edgeInsetsOnly(
          left: spacing.xl * spacingScale,
          right: spacing.xl * spacingScale,
          top: spacing.xl * spacingScale,
          bottom: spacing.sm * spacingScale,
        ),
        contentPadding: spacing.edgeInsetsOnly(
          left: spacing.xl * spacingScale,
          right: spacing.xl * spacingScale,
          bottom: spacing.lg * spacingScale,
        ),
        actionsPadding: spacing.edgeInsetsAll(spacing.lg * spacingScale),
        title: Text(
          title,
          style: AppTokens.typography.titleScaled(scale).copyWith(
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
                style: AppTokens.typography.bodyScaled(scale).copyWith(
                  color: palette.muted,
                ),
              ),
              SizedBox(height: spacing.lg * spacingScale),
            ],
            TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              autofocus: true,
              decoration: InputDecoration(
                hintText: hintText,
                filled: true,
                fillColor: colors.surfaceContainerHighest
                    .withValues(alpha: AppOpacity.subtle),
                border: OutlineInputBorder(
                  borderRadius: AppTokens.radius.md,
                  borderSide: BorderSide(color: colors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppTokens.radius.md,
                  borderSide: BorderSide(
                      color:
                          colors.outline.withValues(alpha: AppOpacity.subtle)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppTokens.radius.md,
                  borderSide: BorderSide(
                      color: colors.primary,
                      width: AppTokens.componentSize.dividerThick),
                ),
                contentPadding: spacing.edgeInsetsAll(spacing.md * spacingScale),
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

// ═══════════════════════════════════════════════════════════════════════════
// DRAGGABLE DISMISS SHEET - Swipe down to dismiss wrapper
// ═══════════════════════════════════════════════════════════════════════════

/// Wraps sheet content to allow drag-to-dismiss gesture.
class _DraggableDismissSheet extends StatefulWidget {
  const _DraggableDismissSheet({
    required this.child,
    this.enableDrag = true,
  });

  final Widget child;
  final bool enableDrag;

  @override
  State<_DraggableDismissSheet> createState() => _DraggableDismissSheetState();
}

class _DraggableDismissSheetState extends State<_DraggableDismissSheet> {
  double _dragOffset = 0;
  bool _isDragging = false;

  static const double _dismissThreshold = 100;
  static const double _velocityThreshold = 500;

  void _handleDragStart(DragStartDetails details) {
    if (!widget.enableDrag) return;
    setState(() {
      _isDragging = true;
      _dragOffset = 0;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.enableDrag || !_isDragging) return;
    setState(() {
      // Only allow dragging down (positive offset)
      _dragOffset = (_dragOffset + details.delta.dy).clamp(0, double.infinity);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.enableDrag || !_isDragging) return;

    final velocity = details.velocity.pixelsPerSecond.dy;
    final shouldDismiss =
        _dragOffset > _dismissThreshold || velocity > _velocityThreshold;

    if (shouldDismiss) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _dragOffset = 0;
        _isDragging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: _handleDragStart,
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      child: AnimatedContainer(
        duration: _isDragging ? Duration.zero : AppMotionSystem.quick,
        curve: AppMotionSystem.easeOut,
        transform: Matrix4.translationValues(0, _dragOffset, 0),
        child: widget.child,
      ),
    );
  }
}
