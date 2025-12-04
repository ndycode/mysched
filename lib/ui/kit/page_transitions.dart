import 'package:flutter/material.dart';

import '../theme/motion.dart';

/// Smooth page route with customizable transitions optimized for 120Hz.
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  SmoothPageRoute({
    required this.page,
    this.transitionType = PageTransitionType.fadeSlideUp,
    super.settings,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    super.barrierDismissible = false,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              context,
              animation,
              secondaryAnimation,
              child,
              transitionType,
            );
          },
          transitionDuration: _getDuration(transitionType),
          reverseTransitionDuration: _getReverseDuration(transitionType),
        );

  final Widget page;
  final PageTransitionType transitionType;

  static Duration _getDuration(PageTransitionType type) {
    switch (type) {
      case PageTransitionType.fadeSlideUp:
        return AppMotionSystem.medium + AppMotionSystem.staggerStandard; // 350ms
      case PageTransitionType.slideUp:
        return AppMotionSystem.slow; // 400ms
      case PageTransitionType.slideRight:
        return AppMotionSystem.medium + AppMotionSystem.staggerStandard; // 350ms
      case PageTransitionType.scaleUp:
        return AppMotionSystem.slow; // 400ms
      case PageTransitionType.fade:
        return AppMotionSystem.standard + AppMotionSystem.staggerStandard; // 250ms
      case PageTransitionType.sharedAxis:
        return AppMotionSystem.slow; // 400ms
      case PageTransitionType.fadeThrough:
        return AppMotionSystem.deliberate; // 500ms
    }
  }

  static Duration _getReverseDuration(PageTransitionType type) {
    switch (type) {
      case PageTransitionType.fadeSlideUp:
        return AppMotionSystem.medium; // 300ms
      case PageTransitionType.slideUp:
        return AppMotionSystem.medium + AppMotionSystem.staggerStandard; // 350ms
      case PageTransitionType.slideRight:
        return AppMotionSystem.medium; // 300ms
      case PageTransitionType.scaleUp:
        return AppMotionSystem.medium; // 300ms
      case PageTransitionType.fade:
        return AppMotionSystem.standard; // 200ms
      case PageTransitionType.sharedAxis:
        return AppMotionSystem.medium + AppMotionSystem.staggerStandard; // 350ms
      case PageTransitionType.fadeThrough:
        return AppMotionSystem.slow; // 400ms
    }
  }

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionType type,
  ) {
    switch (type) {
      case PageTransitionType.fadeSlideUp:
        return _FadeSlideUpTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      case PageTransitionType.slideUp:
        return _SlideUpTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      case PageTransitionType.slideRight:
        return _SlideRightTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      case PageTransitionType.scaleUp:
        return _ScaleUpTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      case PageTransitionType.fade:
        return _FadeTransition(
          animation: animation,
          child: child,
        );
      case PageTransitionType.sharedAxis:
        return _SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      case PageTransitionType.fadeThrough:
        return _FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
    }
  }
}

enum PageTransitionType {
  /// Fade in while sliding up slightly - default for most pages
  fadeSlideUp,

  /// Slide up from bottom - for modal-like pages
  slideUp,

  /// Slide in from right - for horizontal navigation
  slideRight,

  /// Scale up with fade - for detail pages
  scaleUp,

  /// Simple fade - for tab switches
  fade,

  /// Shared axis horizontal - for wizard flows
  sharedAxis,

  /// Fade through - for unrelated content
  fadeThrough,
}

// ═══════════════════════════════════════════════════════════════════════════
// TRANSITION IMPLEMENTATIONS
// ═══════════════════════════════════════════════════════════════════════════

class _FadeSlideUpTransition extends StatelessWidget {
  const _FadeSlideUpTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.6, curve: AppMotionSystem.easeOut),
    );

    final slideIn = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.easeOut,
    );

    final fadeOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.3, curve: AppMotionSystem.easeIn),
    );

    final scaleOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppMotionSystem.easeIn,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(fadeIn),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.04),
          end: Offset.zero,
        ).animate(slideIn),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.92).animate(fadeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.96).animate(scaleOut),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SlideUpTransition extends StatelessWidget {
  const _SlideUpTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final slideIn = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.easeOut,
    );

    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(slideIn),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(fadeIn),
        child: child,
      ),
    );
  }
}

class _SlideRightTransition extends StatelessWidget {
  const _SlideRightTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final slideIn = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.easeOut,
    );

    final slideOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppMotionSystem.easeIn,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(slideIn),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.3, 0.0),
        ).animate(slideOut),
        child: child,
      ),
    );
  }
}

class _ScaleUpTransition extends StatelessWidget {
  const _ScaleUpTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scaleIn = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.overshoot,
    );

    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(fadeIn),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(scaleIn),
        child: child,
      ),
    );
  }
}

class _FadeTransition extends StatelessWidget {
  const _FadeTransition({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.ease,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(fade),
      child: child,
    );
  }
}

class _SharedAxisTransition extends StatelessWidget {
  const _SharedAxisTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Entering page
    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 1.0, curve: AppMotionSystem.easeOut),
    );

    final slideIn = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.easeOut,
    );

    // Exiting page (when this page is being covered)
    final fadeOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.3, curve: AppMotionSystem.easeIn),
    );

    final slideOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppMotionSystem.easeIn,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(fadeIn),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.3, 0.0),
          end: Offset.zero,
        ).animate(slideIn),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(fadeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.3, 0.0),
            ).animate(slideOut),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _FadeThroughTransition extends StatelessWidget {
  const _FadeThroughTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Entering: fade in with scale up
    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.35, 1.0, curve: AppMotionSystem.easeOut),
    );

    final scaleIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.35, 1.0, curve: AppMotionSystem.easeOut),
    );

    // Exiting: fade out with scale down
    final fadeOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.35, curve: AppMotionSystem.easeIn),
    );

    final scaleOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.35, curve: AppMotionSystem.easeIn),
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(fadeIn),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(scaleIn),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(fadeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.1).animate(scaleOut),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HERO ENHANCEMENTS
// ═══════════════════════════════════════════════════════════════════════════

/// Smooth hero with custom flight shuttle.
class SmoothHero extends StatelessWidget {
  const SmoothHero({
    super.key,
    required this.tag,
    required this.child,
    this.flightShuttleBuilder,
    this.placeholderBuilder,
  });

  final Object tag;
  final Widget child;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  final HeroPlaceholderBuilder? placeholderBuilder;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: flightShuttleBuilder ?? _defaultFlightShuttle,
      placeholderBuilder: placeholderBuilder,
      child: child,
    );
  }

  static Widget _defaultFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.easeInOut,
    );

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        return DefaultTextStyle(
          style: DefaultTextStyle.of(toHeroContext).style,
          child: toHeroContext.widget as Hero,
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION HELPERS
// ═══════════════════════════════════════════════════════════════════════════

extension SmoothNavigator on NavigatorState {
  /// Push with smooth fade-slide transition.
  Future<T?> pushSmooth<T extends Object?>(
    Widget page, {
    PageTransitionType transition = PageTransitionType.fadeSlideUp,
    RouteSettings? settings,
  }) {
    return push(SmoothPageRoute<T>(
      page: page,
      transitionType: transition,
      settings: settings,
    ));
  }

  /// Push replacement with smooth transition.
  Future<T?> pushReplacementSmooth<T extends Object?, TO extends Object?>(
    Widget page, {
    PageTransitionType transition = PageTransitionType.fadeSlideUp,
    RouteSettings? settings,
    TO? result,
  }) {
    return pushReplacement(
      SmoothPageRoute<T>(
        page: page,
        transitionType: transition,
        settings: settings,
      ),
      result: result,
    );
  }
}

extension SmoothNavigatorContext on BuildContext {
  /// Push with smooth fade-slide transition.
  Future<T?> pushSmooth<T extends Object?>(
    Widget page, {
    PageTransitionType transition = PageTransitionType.fadeSlideUp,
    RouteSettings? settings,
  }) {
    return Navigator.of(this).pushSmooth<T>(
      page,
      transition: transition,
      settings: settings,
    );
  }
}


