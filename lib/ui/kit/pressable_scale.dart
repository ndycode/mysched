import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/motion.dart';
import '../theme/tokens.dart';

/// Interactive press animation with scale, opacity, and optional haptics.
///
/// Provides consistent tap feedback across the app with smooth animations.
/// Optimized for 90-120Hz displays with physics-based curves.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.scale = AppMotionSystem.pressScale,
    this.pressedOpacity = AppMotionSystem.pressedOpacity,
    this.duration = AppMotionSystem.instant,
    this.releaseDuration = AppMotionSystem.quick,
    this.hapticFeedback = false,
    this.variant = PressableVariant.standard,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;

  /// Scale factor when pressed (1.0 = no scale, 0.95 = 5% smaller).
  final double scale;

  /// Opacity when pressed (1.0 = fully opaque).
  final double pressedOpacity;

  /// Duration for the press-down animation.
  final Duration duration;

  /// Duration for the release animation (slightly slower for smooth feel).
  final Duration releaseDuration;

  /// Whether to trigger haptic feedback on tap.
  final bool hapticFeedback;

  /// Animation variant preset.
  final PressableVariant variant;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

enum PressableVariant {
  /// Standard press animation for most buttons.
  standard,

  /// Subtle press for list items and large surfaces.
  subtle,

  /// Deep press for FABs and primary CTAs.
  deep,

  /// Bouncy press for playful elements.
  bouncy,
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    final config = _getVariantConfig();

    _controller = AnimationController(
      vsync: this,
      duration: config.pressDuration,
      reverseDuration: config.releaseDuration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: config.scale).animate(
      CurvedAnimation(
        parent: _controller,
        curve: config.pressCurve,
        reverseCurve: config.releaseCurve,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: config.opacity,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotionSystem.ease,
        reverseCurve: AppMotionSystem.ease,
      ),
    );
  }

  _PressableConfig _getVariantConfig() {
    switch (widget.variant) {
      case PressableVariant.standard:
        return _PressableConfig(
          scale: widget.scale,
          opacity: widget.pressedOpacity,
          pressDuration: widget.duration,
          releaseDuration: widget.releaseDuration,
          pressCurve: AppMotionSystem.decelerate,
          releaseCurve: AppMotionSystem.overshoot,
        );
      case PressableVariant.subtle:
        return _PressableConfig(
          scale: AppMotionSystem.pressScaleSubtle,
          opacity: 0.92,
          pressDuration: AppMotionSystem.micro,
          releaseDuration: AppMotionSystem.fast,
          pressCurve: AppMotionSystem.ease,
          releaseCurve: AppMotionSystem.snapBack,
        );
      case PressableVariant.deep:
        return _PressableConfig(
          scale: AppMotionSystem.pressScaleDeep,
          opacity: 0.8,
          pressDuration: AppMotionSystem.fast,
          releaseDuration: AppMotionSystem.medium,
          pressCurve: AppMotionSystem.decelerate,
          releaseCurve: Curves.elasticOut,
        );
      case PressableVariant.bouncy:
        return _PressableConfig(
          scale: 0.9,
          opacity: 0.9,
          pressDuration: AppMotionSystem.fast,
          releaseDuration: AppMotionSystem.slow,
          pressCurve: AppMotionSystem.decelerate,
          releaseCurve: Curves.elasticOut,
        );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  void _handleTap() {
    if (!widget.enabled || widget.onTap == null) return;
    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onTap!();
  }

  void _handleLongPress() {
    if (!widget.enabled || widget.onLongPress == null) return;
    if (widget.hapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    widget.onLongPress!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap != null ? _handleTap : null,
      onLongPress: widget.onLongPress != null ? _handleLongPress : null,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _PressableConfig {
  const _PressableConfig({
    required this.scale,
    required this.opacity,
    required this.pressDuration,
    required this.releaseDuration,
    required this.pressCurve,
    required this.releaseCurve,
  });

  final double scale;
  final double opacity;
  final Duration pressDuration;
  final Duration releaseDuration;
  final Curve pressCurve;
  final Curve releaseCurve;
}

/// A more subtle hover/press effect for list items and tiles.
///
/// Provides background color transition on hover (desktop) and press (mobile).
class AnimatedListTile extends StatefulWidget {
  const AnimatedListTile({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.borderRadius,
    this.backgroundColor,
    this.hoverColor,
    this.pressedColor,
    this.padding,
    this.hapticFeedback = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? hoverColor;
  final Color? pressedColor;
  final EdgeInsetsGeometry? padding;
  final bool hapticFeedback;

  @override
  State<AnimatedListTile> createState() => _AnimatedListTileState();
}

class _AnimatedListTileState extends State<AnimatedListTile> {
  bool _hovered = false;
  bool _pressed = false;

  void _handleTap() {
    if (!widget.enabled || widget.onTap == null) return;
    if (widget.hapticFeedback) {
      HapticFeedback.selectionClick();
    }
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = widget.borderRadius ?? AppTokens.radius.lg;

    final bgColor = widget.backgroundColor ?? Colors.transparent;
    final hoverBg = widget.hoverColor ??
        colors.primary.withValues(alpha: theme.brightness == Brightness.dark ? 0.08 : 0.05);
    final pressedBg = widget.pressedColor ??
        colors.primary.withValues(alpha: theme.brightness == Brightness.dark ? 0.14 : 0.10);

    Color resolvedColor;
    if (_pressed && widget.enabled) {
      resolvedColor = pressedBg;
    } else if (_hovered && widget.enabled) {
      resolvedColor = hoverBg;
    } else {
      resolvedColor = bgColor;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.enabled && widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: _handleTap,
        onLongPress: widget.onLongPress,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: AppTokens.motion.fast,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: resolvedColor,
            borderRadius: radius,
          ),
          padding: widget.padding,
          child: AnimatedScale(
            scale: _pressed && widget.enabled ? 0.985 : 1.0,
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// An icon button with smooth scale and rotation animations.
class AnimatedIconButton extends StatefulWidget {
  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 24,
    this.color,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(8), // Default matches AppTokens.spacing.sm
    this.borderRadius,
    this.tooltip,
    this.rotateOnPress = false,
    this.rotationAngle = 0.05,
    this.hapticFeedback = true,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final String? tooltip;

  /// Whether to apply a subtle rotation on press.
  final bool rotateOnPress;

  /// Rotation angle in radians (default is subtle 0.05 rad ≈ 3°).
  final double rotationAngle;

  final bool hapticFeedback;

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: widget.rotateOnPress ? widget.rotationAngle : 0.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed == null) return;
    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = widget.borderRadius ?? AppTokens.radius.xl;
    final iconColor = widget.color ?? colors.primary;

    final bgColor = widget.backgroundColor ??
        (_hovered
            ? colors.primary.withValues(alpha: 0.12)
            : colors.primary.withValues(alpha: 0.08));

    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: _handleTap,
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: child,
              ),
            );
          },
          child: AnimatedContainer(
            duration: AppTokens.motion.fast,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: radius,
            ),
            child: Icon(
              widget.icon,
              size: widget.size,
              color: iconColor,
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}

/// Bouncy tap animation for floating action buttons and prominent CTAs.
class BouncyTap extends StatefulWidget {
  const BouncyTap({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.hapticFeedback = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final bool hapticFeedback;

  @override
  State<BouncyTap> createState() => _BouncyTapState();
}

class _BouncyTapState extends State<BouncyTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
        reverseCurve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled || widget.onTap == null) return;
    if (widget.hapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) {
        if (widget.enabled) _controller.forward();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _animation,
        child: widget.child,
      ),
    );
  }
}
