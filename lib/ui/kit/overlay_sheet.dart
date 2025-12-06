import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/tokens.dart';

/// Overlay sheet route with smooth 120Hz-optimized animations.
class OverlaySheetRoute<T> extends PageRoute<T> {
  OverlaySheetRoute({
    required this.builder,
    bool barrierDismissible = false,
    Color barrierTint = AppBarrier.light,
    EdgeInsets padding = const EdgeInsets.symmetric(
        horizontal: AppLayout.pagePaddingHorizontal,
        vertical: AppLayout.pagePaddingVertical),
    Alignment alignment = Alignment.bottomCenter,
    this.transitionDuration = AppMotionSystem.medium,
    this.reverseTransitionDuration = AppMotionSystem.quick,
    this.variant = SheetTransitionVariant.slideUp,
  })  : _barrierDismissible = barrierDismissible,
        _barrierTint = barrierTint,
        _padding = padding,
        _alignment = alignment;

  final WidgetBuilder builder;
  final bool _barrierDismissible;
  final Color _barrierTint;
  final EdgeInsets _padding;
  final Alignment _alignment;
  final SheetTransitionVariant variant;
  @override
  final Duration transitionDuration;
  @override
  final Duration reverseTransitionDuration;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => _barrierDismissible;

  @override
  Color? get barrierColor => _barrierTint;

  @override
  String? get barrierLabel => 'overlay-sheet';

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Align(
      alignment: _alignment,
      child: Padding(
        padding: _padding,
        child: builder(context),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    switch (variant) {
      case SheetTransitionVariant.slideUp:
        return _buildSlideUpTransition(animation, child);
      case SheetTransitionVariant.scale:
        return _buildScaleTransition(animation, child);
      case SheetTransitionVariant.fade:
        return _buildFadeTransition(animation, child);
      case SheetTransitionVariant.slideFromBottom:
        return _buildSlideFromBottomTransition(animation, child);
    }
  }

  Widget _buildSlideUpTransition(Animation<double> animation, Widget child) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, AppMotionSystem.intervalHalf, curve: AppMotionSystem.easeOut),
      reverseCurve: const Interval(AppMotionSystem.intervalHalf, 1.0, curve: AppMotionSystem.easeIn),
    );

    final slideAnimation = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.easeOut,
      reverseCurve: AppMotionSystem.easeIn,
    );

    final scaleAnimation = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.easeOut,
      reverseCurve: AppMotionSystem.easeIn,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: AppMotionSystem.scaleNone).animate(fadeAnimation),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, AppMotionSystem.slideOffsetSm),
          end: Offset.zero,
        ).animate(slideAnimation),
        child: ScaleTransition(
          scale: Tween<double>(begin: AppMotionSystem.scalePressInteractive, end: AppMotionSystem.scaleNone).animate(scaleAnimation),
          child: child,
        ),
      ),
    );
  }

  Widget _buildScaleTransition(Animation<double> animation, Widget child) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, AppMotionSystem.intervalMid, curve: AppMotionSystem.easeOut),
    );

    final scaleAnimation = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.overshoot,
      reverseCurve: AppMotionSystem.easeIn,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: AppMotionSystem.scaleNone).animate(fadeAnimation),
      child: ScaleTransition(
        scale: Tween<double>(begin: AppMotionSystem.scalePress, end: AppMotionSystem.scaleNone).animate(scaleAnimation),
        child: child,
      ),
    );
  }

  Widget _buildFadeTransition(Animation<double> animation, Widget child) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.ease,
      reverseCurve: AppMotionSystem.ease,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: AppMotionSystem.scaleNone).animate(fadeAnimation),
      child: child,
    );
  }

  Widget _buildSlideFromBottomTransition(
      Animation<double> animation, Widget child) {
    final slideAnimation = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.easeOut,
      reverseCurve: AppMotionSystem.accelerate,
    );

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, AppMotionSystem.intervalEarly, curve: AppMotionSystem.easeOut),
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, AppMotionSystem.slideOffsetFull),
        end: Offset.zero,
      ).animate(slideAnimation),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: AppMotionSystem.scaleNone).animate(fadeAnimation),
        child: child,
      ),
    );
  }
}

enum SheetTransitionVariant {
  /// Slide up with fade and subtle scale - default.
  slideUp,

  /// Pop scale with fade - for dialogs.
  scale,

  /// Simple fade - for quick overlays.
  fade,

  /// Full slide from bottom - for bottom sheets.
  slideFromBottom,
}

// ═══════════════════════════════════════════════════════════════════════════
// LEGACY FUNCTIONS - Deprecated, use AppModal instead
// ═══════════════════════════════════════════════════════════════════════════

/// @deprecated Use [AppModal.sheet] instead.
Future<T?> showOverlaySheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = false,
  Color barrierTint = AppBarrier.light,
  EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: AppLayout.pagePaddingHorizontal,
      vertical: AppLayout.pagePaddingVertical),
  Alignment alignment = Alignment.bottomCenter,
  bool dimBackground = false,
  SheetTransitionVariant variant = SheetTransitionVariant.slideUp,
  Duration? transitionDuration,
  Duration? reverseTransitionDuration,
}) {
  final effectiveTint =
      (barrierDismissible || dimBackground) ? barrierTint : Colors.transparent;
  return Navigator.of(context).push<T>(
    OverlaySheetRoute<T>(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Builder(builder: builder),
      ),
      barrierDismissible: barrierDismissible,
      barrierTint: effectiveTint,
      padding: padding,
      alignment: alignment,
      variant: variant,
      transitionDuration: transitionDuration ?? AppMotionSystem.medium,
      reverseTransitionDuration:
          reverseTransitionDuration ?? AppMotionSystem.quick,
    ),
  );
}

/// @deprecated Use [AppModal.sheet] instead.
Future<T?> showSmoothBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  return Navigator.of(context).push<T>(
    _SmoothSheetRoute<T>(
      builder: builder,
      isDismissible: isDismissible,
    ),
  );
}

/// Internal route for legacy showSmoothBottomSheet.
class _SmoothSheetRoute<T> extends PopupRoute<T> {
  _SmoothSheetRoute({
    required this.builder,
    this.isDismissible = true,
  });

  final WidgetBuilder builder;
  final bool isDismissible;

  @override
  Color? get barrierColor => AppBarrier.heavy;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  String? get barrierLabel => 'Dismiss';

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
}
