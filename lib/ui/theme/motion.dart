import 'package:flutter/physics.dart';
import 'package:flutter/material.dart';

/// Custom page transitions builder optimized for 120Hz displays.
/// Uses smooth fade-through animation with subtle scale.
class AppFadeThroughPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppFadeThroughPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _AppFadeThroughTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

class _AppFadeThroughTransition extends StatelessWidget {
  const _AppFadeThroughTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Primary transition (this page entering)
    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 1.0, curve: AppMotionSystem.easeOut),
    );

    final scaleIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 1.0, curve: AppMotionSystem.easeOut),
    );

    final slideIn = CurvedAnimation(
      parent: animation,
      curve: AppMotionSystem.easeOut,
    );

    // Secondary transition (this page being covered or revealed)
    final fadeOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.3, curve: AppMotionSystem.easeIn),
    );

    final scaleOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.3, curve: AppMotionSystem.easeIn),
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(fadeIn),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.96, end: 1.0).animate(scaleIn),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.02),
            end: Offset.zero,
          ).animate(slideIn),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(fadeOut),
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.04).animate(scaleOut),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium motion system optimized for 90-120Hz displays.
/// 
/// Uses physics-based springs and carefully tuned curves for
/// buttery smooth 60-120fps animations.
class AppMotionSystem {
  const AppMotionSystem._();

  // ═══════════════════════════════════════════════════════════════════════════
  // DURATION TOKENS (optimized for high refresh rate displays)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Micro-interactions: ripples, state changes (1-2 frames at 120Hz)
  static const Duration micro = Duration(milliseconds: 50);

  /// Instant feedback: button press, toggle (6 frames at 120Hz)
  static const Duration instant = Duration(milliseconds: 83);

  /// Fast transitions: tooltips, dropdowns (12 frames at 120Hz)
  static const Duration fast = Duration(milliseconds: 100);

  /// Quick animations: cards, panels (18 frames at 120Hz)
  static const Duration quick = Duration(milliseconds: 150);

  /// Standard transitions: page elements, modals (24 frames at 120Hz)
  static const Duration standard = Duration(milliseconds: 200);

  /// Medium animations: complex reveals (36 frames at 120Hz)
  static const Duration medium = Duration(milliseconds: 300);

  /// Slow animations: page transitions, hero (48 frames at 120Hz)
  static const Duration slow = Duration(milliseconds: 400);

  /// Deliberate animations: onboarding, complex sequences
  static const Duration deliberate = Duration(milliseconds: 500);

  /// Long animations: loading states, continuous feedback
  static const Duration long = Duration(milliseconds: 800);

  /// Extended animations: shimmer effects, looping indicators
  static const Duration extended = Duration(milliseconds: 1200);

  /// Prolonged animations: breathing effects, slow pulses
  static const Duration prolonged = Duration(milliseconds: 1500);

  // ═══════════════════════════════════════════════════════════════════════════
  // SPRING PHYSICS (natural, responsive feel)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Snappy spring for quick interactions (buttons, toggles)
  static SpringDescription get snappySpring => const SpringDescription(
        mass: 1.0,
        stiffness: 400.0,
        damping: 30.0,
      );

  /// Responsive spring for UI elements (cards, panels)
  static SpringDescription get responsiveSpring => const SpringDescription(
        mass: 1.0,
        stiffness: 300.0,
        damping: 25.0,
      );

  /// Smooth spring for larger movements (sheets, modals)
  static SpringDescription get smoothSpring => const SpringDescription(
        mass: 1.0,
        stiffness: 200.0,
        damping: 22.0,
      );

  /// Bouncy spring for playful elements (FAB, success states)
  static SpringDescription get bouncySpring => const SpringDescription(
        mass: 1.0,
        stiffness: 350.0,
        damping: 15.0,
      );

  /// Gentle spring for subtle movements (hover, focus)
  static SpringDescription get gentleSpring => const SpringDescription(
        mass: 1.0,
        stiffness: 150.0,
        damping: 20.0,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // EASING CURVES (perceptually smooth at high refresh rates)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Standard ease-out for most animations (starts fast, ends slow)
  static const Curve ease = Cubic(0.25, 0.1, 0.25, 1.0);

  /// Emphasized ease-out for entrances
  static const Curve easeOut = Cubic(0.0, 0.0, 0.2, 1.0);

  /// Emphasized ease-in for exits
  static const Curve easeIn = Cubic(0.4, 0.0, 1.0, 1.0);

  /// Smooth ease-in-out for reversible animations
  static const Curve easeInOut = Cubic(0.4, 0.0, 0.2, 1.0);

  /// Quick deceleration for fast interactions
  static const Curve decelerate = Cubic(0.0, 0.0, 0.1, 1.0);

  /// Sharp acceleration for emphasis
  static const Curve accelerate = Cubic(0.4, 0.0, 0.6, 1.0);

  /// Overshoot for bouncy entrances
  static const Curve overshoot = Cubic(0.34, 1.56, 0.64, 1.0);

  /// Anticipate for exits with wind-up
  static const Curve anticipate = Cubic(0.36, 0.0, 0.66, -0.56);

  /// Snap back for elastic feel
  static const Curve snapBack = Cubic(0.175, 0.885, 0.32, 1.275);

  /// Smooth step for state transitions
  static const Curve smoothStep = Cubic(0.4, 0.0, 0.6, 1.0);

  // ═══════════════════════════════════════════════════════════════════════════
  // SCALE VALUES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Subtle press scale for large surfaces
  static const double pressScaleSubtle = 0.985;

  /// Standard press scale for buttons
  static const double pressScale = 0.96;

  /// Deep press scale for FABs and CTAs
  static const double pressScaleDeep = 0.92;

  /// Hover scale for desktop interactions
  static const double hoverScale = 1.02;

  /// Pop scale for entrances
  static const double popScale = 1.05;

  // ═══════════════════════════════════════════════════════════════════════════
  // OPACITY VALUES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Pressed state opacity
  static const double pressedOpacity = 0.85;

  /// Hover state opacity
  static const double hoverOpacity = 0.92;

  /// Disabled state opacity
  static const double disabledOpacity = 0.5;

  /// Subtle fade for backgrounds
  static const double subtleFade = 0.7;

  // ═══════════════════════════════════════════════════════════════════════════
  // STAGGER DELAYS (for list animations)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fast stagger for quick lists
  static const Duration staggerFast = Duration(milliseconds: 30);

  /// Standard stagger for most lists
  static const Duration staggerStandard = Duration(milliseconds: 50);

  /// Slow stagger for dramatic reveals
  static const Duration staggerSlow = Duration(milliseconds: 80);

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get stagger delay for a specific index
  static Duration staggerDelay(int index, [Duration base = staggerStandard]) {
    return base * index;
  }

  /// Create a spring simulation
  static SpringSimulation createSpring({
    required double start,
    required double end,
    required double velocity,
    SpringDescription? spring,
  }) {
    return SpringSimulation(
      spring ?? responsiveSpring,
      start,
      end,
      velocity,
    );
  }
}

/// Pre-configured animation presets for common use cases.
class AnimationPresets {
  const AnimationPresets._();

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTON ANIMATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static const ButtonAnimation primaryButton = ButtonAnimation(
    pressScale: 0.96,
    pressDuration: Duration(milliseconds: 80),
    releaseDuration: Duration(milliseconds: 200),
    pressCurve: AppMotionSystem.decelerate,
    releaseCurve: AppMotionSystem.overshoot,
  );

  static const ButtonAnimation subtleButton = ButtonAnimation(
    pressScale: 0.985,
    pressDuration: Duration(milliseconds: 60),
    releaseDuration: Duration(milliseconds: 150),
    pressCurve: AppMotionSystem.ease,
    releaseCurve: AppMotionSystem.snapBack,
  );

  static const ButtonAnimation fabButton = ButtonAnimation(
    pressScale: 0.90,
    pressDuration: Duration(milliseconds: 100),
    releaseDuration: Duration(milliseconds: 300),
    pressCurve: AppMotionSystem.decelerate,
    releaseCurve: Curves.elasticOut,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD ANIMATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static const CardAnimation standardCard = CardAnimation(
    hoverScale: 1.015,
    pressScale: 0.98,
    hoverDuration: Duration(milliseconds: 150),
    pressDuration: Duration(milliseconds: 100),
    hoverCurve: AppMotionSystem.ease,
    pressCurve: AppMotionSystem.decelerate,
  );

  static const CardAnimation interactiveCard = CardAnimation(
    hoverScale: 1.02,
    pressScale: 0.97,
    hoverDuration: Duration(milliseconds: 200),
    pressDuration: Duration(milliseconds: 80),
    hoverCurve: AppMotionSystem.easeOut,
    pressCurve: AppMotionSystem.decelerate,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGE TRANSITIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static const PageAnimation fadeSlide = PageAnimation(
    duration: Duration(milliseconds: 350),
    curve: AppMotionSystem.easeOut,
    slideOffset: Offset(0.0, 0.05),
  );

  static const PageAnimation slideUp = PageAnimation(
    duration: Duration(milliseconds: 400),
    curve: AppMotionSystem.easeOut,
    slideOffset: Offset(0.0, 0.1),
  );

  static const PageAnimation slideRight = PageAnimation(
    duration: Duration(milliseconds: 350),
    curve: AppMotionSystem.easeOut,
    slideOffset: Offset(0.08, 0.0),
  );

  static const PageAnimation scaleUp = PageAnimation(
    duration: Duration(milliseconds: 400),
    curve: AppMotionSystem.overshoot,
    slideOffset: Offset.zero,
    scaleStart: 0.95,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // MODAL ANIMATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static const ModalAnimation bottomSheet = ModalAnimation(
    enterDuration: Duration(milliseconds: 350),
    exitDuration: Duration(milliseconds: 250),
    enterCurve: AppMotionSystem.easeOut,
    exitCurve: AppMotionSystem.easeIn,
    slideOffset: Offset(0.0, 1.0),
  );

  static const ModalAnimation centerModal = ModalAnimation(
    enterDuration: Duration(milliseconds: 300),
    exitDuration: Duration(milliseconds: 200),
    enterCurve: AppMotionSystem.overshoot,
    exitCurve: AppMotionSystem.easeIn,
    slideOffset: Offset.zero,
    scaleStart: 0.9,
  );

  static const ModalAnimation fullscreenSheet = ModalAnimation(
    enterDuration: Duration(milliseconds: 400),
    exitDuration: Duration(milliseconds: 300),
    enterCurve: AppMotionSystem.easeOut,
    exitCurve: AppMotionSystem.accelerate,
    slideOffset: Offset(0.0, 1.0),
  );
}

/// Configuration for button press animations.
class ButtonAnimation {
  const ButtonAnimation({
    required this.pressScale,
    required this.pressDuration,
    required this.releaseDuration,
    required this.pressCurve,
    required this.releaseCurve,
  });

  final double pressScale;
  final Duration pressDuration;
  final Duration releaseDuration;
  final Curve pressCurve;
  final Curve releaseCurve;
}

/// Configuration for card hover/press animations.
class CardAnimation {
  const CardAnimation({
    required this.hoverScale,
    required this.pressScale,
    required this.hoverDuration,
    required this.pressDuration,
    required this.hoverCurve,
    required this.pressCurve,
  });

  final double hoverScale;
  final double pressScale;
  final Duration hoverDuration;
  final Duration pressDuration;
  final Curve hoverCurve;
  final Curve pressCurve;
}

/// Configuration for page transition animations.
class PageAnimation {
  const PageAnimation({
    required this.duration,
    required this.curve,
    required this.slideOffset,
    this.scaleStart = 1.0,
  });

  final Duration duration;
  final Curve curve;
  final Offset slideOffset;
  final double scaleStart;
}

/// Configuration for modal/sheet animations.
class ModalAnimation {
  const ModalAnimation({
    required this.enterDuration,
    required this.exitDuration,
    required this.enterCurve,
    required this.exitCurve,
    required this.slideOffset,
    this.scaleStart = 1.0,
  });

  final Duration enterDuration;
  final Duration exitDuration;
  final Curve enterCurve;
  final Curve exitCurve;
  final Offset slideOffset;
  final double scaleStart;
}
