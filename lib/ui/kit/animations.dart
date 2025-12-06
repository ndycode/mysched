import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/motion.dart';
import '../theme/tokens.dart';

/// Extension for applying staggered animations to lists.
/// Optimized for 90-120Hz displays with smooth timing.
extension StaggeredListAnimation on List<Widget> {
  /// Applies staggered fade and slide-up animations to each widget in the list.
  ///
  /// [delay] is the initial delay before any animation starts.
  /// [staggerDuration] is the delay between each item's animation.
  /// [itemDuration] is how long each item's animation takes.
  List<Widget> staggered({
    Duration delay = Duration.zero,
    Duration staggerDuration = AppMotionSystem.staggerStandard,
    Duration itemDuration = AppMotionSystem.medium,
    double slideOffset = 12,
    Curve curve = AppMotionSystem.easeOut,
  }) {
    return asMap().entries.map((entry) {
      final index = entry.key;
      final widget = entry.value;
      final itemDelay = delay + (staggerDuration * index);

      return widget
          .animate(delay: itemDelay)
          .fadeIn(duration: itemDuration, curve: curve)
          .slideY(
            begin: slideOffset / 100,
            end: 0,
            duration: itemDuration,
            curve: curve,
          );
    }).toList();
  }

  /// Faster stagger for dense lists (e.g., settings).
  List<Widget> staggeredFast({
    Duration delay = Duration.zero,
  }) {
    return staggered(
      delay: delay,
      staggerDuration: AppMotionSystem.staggerFast,
      itemDuration: AppMotionSystem.quick,
      slideOffset: AppTokens.durations.slideOffsetSm,
    );
  }

  /// Dramatic stagger for hero sections.
  List<Widget> staggeredDramatic({
    Duration delay = Duration.zero,
  }) {
    return staggered(
      delay: delay,
      staggerDuration: AppMotionSystem.staggerSlow,
      itemDuration: AppMotionSystem.slow,
      slideOffset: AppTokens.durations.slideOffsetMd,
      curve: AppMotionSystem.overshoot,
    );
  }

  /// Scale-in stagger for grid items.
  List<Widget> staggeredScale({
    Duration delay = Duration.zero,
    Duration staggerDuration = AppMotionSystem.staggerStandard,
    Duration itemDuration = AppMotionSystem.medium,
    Curve curve = AppMotionSystem.overshoot,
  }) {
    return asMap().entries.map((entry) {
      final index = entry.key;
      final widget = entry.value;
      final itemDelay = delay + (staggerDuration * index);

      return widget
          .animate(delay: itemDelay)
          .fadeIn(duration: itemDuration, curve: AppMotionSystem.easeOut)
          .scale(
            begin: AppMotionSystem.scaleOffsetEntryDeep,
            end: AppMotionSystem.scaleOffsetFull,
            duration: itemDuration,
            curve: curve,
          );
    }).toList();
  }
}

/// Widget that applies staggered animation to its children.
/// Optimized for 90-120Hz with smooth cascading reveals.
class StaggeredAnimatedList extends StatelessWidget {
  const StaggeredAnimatedList({
    super.key,
    required this.children,
    this.delay = Duration.zero,
    this.staggerDuration = AppMotionSystem.staggerStandard,
    this.itemDuration = AppMotionSystem.medium,
    this.slideOffset = 12,
    this.curve = AppMotionSystem.easeOut,
    this.spacing = 0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.variant = StaggerVariant.slideUp,
  });

  final List<Widget> children;
  final Duration delay;
  final Duration staggerDuration;
  final Duration itemDuration;
  final double slideOffset;
  final Curve curve;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final StaggerVariant variant;

  @override
  Widget build(BuildContext context) {
    final animatedChildren = children.asMap().entries.map((entry) {
      final index = entry.key;
      final widget = entry.value;
      final itemDelay = delay + (staggerDuration * index);

      switch (variant) {
        case StaggerVariant.slideUp:
          return widget
              .animate(delay: itemDelay)
              .fadeIn(duration: itemDuration, curve: curve)
              .slideY(
                begin: slideOffset / 100,
                end: 0,
                duration: itemDuration,
                curve: curve,
              );

        case StaggerVariant.slideRight:
          return widget
              .animate(delay: itemDelay)
              .fadeIn(duration: itemDuration, curve: curve)
              .slideX(
                begin: -slideOffset / 100,
                end: 0,
                duration: itemDuration,
                curve: curve,
              );

        case StaggerVariant.scale:
          return widget
              .animate(delay: itemDelay)
              .fadeIn(duration: itemDuration, curve: curve)
              .scale(
                begin: AppMotionSystem.scaleOffsetDense,
                end: AppMotionSystem.scaleOffsetFull,
                duration: itemDuration,
                curve: AppMotionSystem.overshoot,
              );

        case StaggerVariant.fade:
          return widget
              .animate(delay: itemDelay)
              .fadeIn(duration: itemDuration, curve: curve);
      }
    }).toList();

    if (spacing > 0) {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          for (var i = 0; i < animatedChildren.length; i++) ...[
            animatedChildren[i],
            if (i < animatedChildren.length - 1) SizedBox(height: spacing),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: animatedChildren,
    );
  }
}

enum StaggerVariant { slideUp, slideRight, scale, fade }

/// Animated sliver list for smooth scrollable content.
class AnimatedSliverList extends StatelessWidget {
  const AnimatedSliverList({
    super.key,
    required this.children,
    this.delay = Duration.zero,
    this.staggerDuration = AppMotionSystem.staggerFast,
  });

  final List<Widget> children;
  final Duration delay;
  final Duration staggerDuration;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= children.length) return null;
          final itemDelay = delay + (staggerDuration * index);

          return children[index]
              .animate(delay: itemDelay)
              .fadeIn(
                duration: AppMotionSystem.quick,
                curve: AppMotionSystem.easeOut,
              )
              .slideY(
                begin: AppMotionSystem.slideOffsetSm,
                end: 0,
                duration: AppMotionSystem.quick,
                curve: AppMotionSystem.easeOut,
              );
        },
        childCount: children.length,
      ),
    );
  }
}

/// Shimmer effect for loading states using flutter_animate.
/// Enhanced with smooth 120Hz timing.
class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration = AppMotionSystem.extended,
  });

  final Widget child;
  final bool enabled;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return child
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: duration,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppOpacity.veryFaint),
        );
  }
}

/// Smooth breathing/pulse effect for live indicators.
class BreathingEffect extends StatelessWidget {
  const BreathingEffect({
    super.key,
    required this.child,
    this.enabled = true,
    this.minScale = 0.96,
    this.maxScale = 1.0,
    this.minOpacity = 0.7,
    this.maxOpacity = 1.0,
    this.duration = AppMotionSystem.prolonged,
  });

  final Widget child;
  final bool enabled;
  final double minScale;
  final double maxScale;
  final double minOpacity;
  final double maxOpacity;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return child
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: minScale,
          end: maxScale,
          duration: duration,
          curve: AppMotionSystem.easeInOut,
        )
        .fadeIn(
          begin: minOpacity,
          duration: duration,
          curve: AppMotionSystem.easeInOut,
        );
  }
}

/// Smooth ripple effect for touch feedback.
class SmoothRipple extends StatefulWidget {
  const SmoothRipple({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.rippleColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? rippleColor;

  @override
  State<SmoothRipple> createState() => _SmoothRippleState();
}

class _SmoothRippleState extends State<SmoothRipple>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotionSystem.slow,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.rippleColor ?? theme.colorScheme.primary.withValues(alpha: AppOpacity.overlay);
    final radius = widget.borderRadius ?? AppTokens.radius.md;

    return GestureDetector(
      onTap: _handleTap,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _RipplePainter(
                      progress: _controller.value,
                      color: color,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  _RipplePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color.withValues(alpha: color.a * (1 - progress))
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width + size.height) / 2;
    final radius = maxRadius * progress;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Fade-in animation wrapper with configurable properties.
/// Uses 120Hz-optimized timing.
class FadeInWidget extends StatelessWidget {
  const FadeInWidget({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotionSystem.medium,
    this.curve = AppMotionSystem.easeOut,
    this.slideOffset,
    this.scaleFrom,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double? slideOffset;
  final double? scaleFrom;

  @override
  Widget build(BuildContext context) {
    var animated = child.animate(delay: delay).fadeIn(
          duration: duration,
          curve: curve,
        );

    if (slideOffset != null) {
      animated = animated.slideY(
        begin: slideOffset! / 100,
        end: 0,
        duration: duration,
        curve: curve,
      );
    }

    if (scaleFrom != null) {
      animated = animated.scale(
        begin: Offset(scaleFrom!, scaleFrom!),
        end: AppMotionSystem.scaleOffsetFull,
        duration: duration,
        curve: AppMotionSystem.overshoot,
      );
    }

    return animated;
  }
}

/// Scale-in animation for buttons and interactive elements.
/// Enhanced with spring physics.
class ScaleInWidget extends StatelessWidget {
  const ScaleInWidget({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotionSystem.quick,
    this.curve = AppMotionSystem.overshoot,
    this.beginScale = 0.85,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double beginScale;

  @override
  Widget build(BuildContext context) {
    return child.animate(delay: delay).scale(
          begin: Offset(beginScale, beginScale),
          end: AppMotionSystem.scaleOffsetFull,
          duration: duration,
          curve: curve,
        );
  }
}

/// Hero-style entrance animation for cards.
/// Premium feel with layered animations.
class CardEntranceAnimation extends StatelessWidget {
  const CardEntranceAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.enabled = true,
    this.variant = CardEntranceVariant.standard,
  });

  final Widget child;
  final Duration delay;
  final bool enabled;
  final CardEntranceVariant variant;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    switch (variant) {
      case CardEntranceVariant.standard:
        return child
            .animate(delay: delay)
            .fadeIn(
              duration: AppMotionSystem.medium,
              curve: AppMotionSystem.easeOut,
            )
            .slideY(
              begin: AppMotionSystem.slideOffsetSmMd,
              end: 0,
              duration: AppMotionSystem.medium,
              curve: AppMotionSystem.easeOut,
            )
            .scale(
              begin: AppMotionSystem.scaleOffsetPressInteractive,
              end: AppMotionSystem.scaleOffsetFull,
              duration: AppMotionSystem.medium,
              curve: AppMotionSystem.easeOut,
            );

      case CardEntranceVariant.hero:
        return child
            .animate(delay: delay)
            .fadeIn(
              duration: AppMotionSystem.slow,
              curve: AppMotionSystem.easeOut,
            )
            .slideY(
              begin: AppMotionSystem.slideOffsetMd,
              end: 0,
              duration: AppMotionSystem.slow,
              curve: AppMotionSystem.easeOut,
            )
            .scale(
              begin: AppMotionSystem.scaleOffsetPageTransition,
              end: AppMotionSystem.scaleOffsetFull,
              duration: AppMotionSystem.slow,
              curve: AppMotionSystem.overshoot,
            );

      case CardEntranceVariant.subtle:
        return child
            .animate(delay: delay)
            .fadeIn(
              duration: AppMotionSystem.quick,
              curve: AppMotionSystem.easeOut,
            )
            .slideY(
              begin: AppMotionSystem.slideOffsetMicro,
              end: 0,
              duration: AppMotionSystem.quick,
              curve: AppMotionSystem.easeOut,
            );
    }
  }
}

enum CardEntranceVariant { standard, hero, subtle }

/// Pulse animation for live/active indicators.
/// Smooth and subtle for professional feel.
class PulseAnimation extends StatelessWidget {
  const PulseAnimation({
    super.key,
    required this.child,
    this.enabled = true,
    this.scale = 1.06,
    this.duration = AppMotionSystem.long,
  });

  final Widget child;
  final bool enabled;
  final double scale;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: AppMotionSystem.scaleOffsetFull,
          end: Offset(scale, scale),
          duration: duration,
          curve: AppMotionSystem.easeInOut,
        );
  }
}

/// Animated counter for metrics that change value.
/// Uses smooth easing for natural counting.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.duration = AppMotionSystem.deliberate,
    this.curve = AppMotionSystem.easeOut,
    this.prefix = '',
    this.suffix = '',
  });

  final int value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, _) {
        return Text(
          '$prefix$animatedValue$suffix',
          style: style,
        );
      },
    );
  }
}

/// Animated double counter for decimal values.
class AnimatedDoubleCounter extends StatelessWidget {
  const AnimatedDoubleCounter({
    super.key,
    required this.value,
    required this.style,
    this.duration = AppMotionSystem.deliberate,
    this.curve = AppMotionSystem.easeOut,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 1,
  });

  final double value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final String prefix;
  final String suffix;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, _) {
        return Text(
          '$prefix${animatedValue.toStringAsFixed(decimals)}$suffix',
          style: style,
        );
      },
    );
  }
}

/// Entrance animation presets for consistent usage.
/// Updated for 120Hz displays.
class EntranceAnimations {
  const EntranceAnimations._();

  /// Micro interaction timing.
  static const micro = AppMotionSystem.micro;

  /// Instant feedback.
  static const instant = AppMotionSystem.instant;

  /// Fast transitions.
  static const fast = AppMotionSystem.fast;

  /// Quick animations.
  static const quick = AppMotionSystem.quick;

  /// Standard fade + slide up.
  static const standard = AppMotionSystem.standard;

  /// Medium animations.
  static const medium = AppMotionSystem.medium;

  /// Slow animations.
  static const slow = AppMotionSystem.slow;

  /// Staggered list default timing.
  static const staggerDelay = AppMotionSystem.staggerStandard;

  /// Card entrance timing.
  static const cardEntrance = AppMotionSystem.medium;
}

/// Smooth loading indicator with subtle breathing animation.
/// Optimized for minimal visual distraction.
class AnimatedLoadingIndicator extends StatelessWidget {
  const AnimatedLoadingIndicator({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 2.5,
  });

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
        strokeCap: StrokeCap.round,
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .scaleXY(
          begin: AppMotionSystem.scaleEntrySubtle,
          end: AppMotionSystem.scaleNone,
          duration: AppMotionSystem.deliberate,
          curve: AppMotionSystem.easeInOut,
        )
        .then()
        .scaleXY(
          begin: AppMotionSystem.scaleNone,
          end: AppMotionSystem.scaleEntrySubtle,
          duration: AppMotionSystem.deliberate,
          curve: AppMotionSystem.easeInOut,
        );
  }
}

/// Smooth skeleton loading with gradient shimmer.
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: isDark ? AppOpacity.highlight : AppOpacity.veryFaint),
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: AppMotionSystem.long + AppMotionSystem.slow, // ~1200ms
          color: colors.onSurface.withValues(alpha: isDark ? AppOpacity.dim : AppOpacity.micro),
        );
  }
}

/// Animated checkmark for success states.
/// Uses elastic bounce for satisfying feedback.
class AnimatedCheckmark extends StatelessWidget {
  const AnimatedCheckmark({
    super.key,
    this.size = 48,
    this.color,
    this.delay = Duration.zero,
  });

  final double size;
  final Color? color;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkColor = color ?? theme.colorScheme.primary;

    return Icon(
      Icons.check_circle_rounded,
      size: size,
      color: checkColor,
    )
        .animate(delay: delay)
        .scale(
          begin: const Offset(0, 0),
          end: AppMotionSystem.scaleOffsetFull,
          duration: AppMotionSystem.slow,
          curve: AppMotionSystem.elasticOut,
        )
        .fadeIn(duration: AppMotionSystem.quick);
  }
}

/// Animated error indicator for failure states.
/// Uses shake for attention-grabbing feedback.
class AnimatedErrorIndicator extends StatelessWidget {
  const AnimatedErrorIndicator({
    super.key,
    this.size = 48,
    this.color,
    this.delay = Duration.zero,
  });

  final double size;
  final Color? color;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = color ?? theme.colorScheme.error;

    return Icon(
      Icons.error_rounded,
      size: size,
      color: errorColor,
    )
        .animate(delay: delay)
        .shake(
          hz: 4,
          rotation: 0.04,
          duration: AppMotionSystem.slow,
        )
        .fadeIn(duration: AppMotionSystem.quick);
  }
}

/// Animated warning indicator.
class AnimatedWarningIndicator extends StatelessWidget {
  const AnimatedWarningIndicator({
    super.key,
    this.size = 48,
    this.color,
    this.delay = Duration.zero,
  });

  final double size;
  final Color? color;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final warningColor = color ?? colors.tertiary;

    return Icon(
      Icons.warning_rounded,
      size: size,
      color: warningColor,
    )
        .animate(delay: delay)
        .scale(
          begin: AppMotionSystem.scaleOffsetHalf,
          end: AppMotionSystem.scaleOffsetFull,
          duration: AppMotionSystem.medium,
          curve: AppMotionSystem.overshoot,
        )
        .fadeIn(duration: AppMotionSystem.quick);
  }
}

/// Animated badge/dot indicator for notifications.
/// Uses bouncy animation for attention.
class AnimatedBadge extends StatelessWidget {
  const AnimatedBadge({
    super.key,
    required this.count,
    this.color,
    this.textColor,
    this.size = 20,
    this.animate = true,
  });

  final int count;
  final Color? color;
  final Color? textColor;
  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (count <= 0) return const SizedBox.shrink();

    final displayText = count > 99 ? '99+' : count.toString();

    final Widget badge = Container(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: AppTokens.spacing.edgeInsetsSymmetric(horizontal: AppTokens.spacing.xsPlus, vertical: AppTokens.spacing.micro),
      decoration: BoxDecoration(
        color: color ?? colors.error,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          displayText,
          style: AppTokens.typography.caption.copyWith(
            color: textColor ?? colors.onError,
            fontWeight: AppTokens.fontWeight.bold,
          ),
        ),
      ),
    );

    if (!animate) return badge;

    return badge
        .animate()
        .scale(
          begin: AppMotionSystem.scaleOffsetHalf,
          end: AppMotionSystem.scaleOffsetFull,
          duration: AppMotionSystem.medium,
          curve: AppMotionSystem.elasticOut,
        )
        .fadeIn(duration: AppMotionSystem.quick);
  }
}

/// Slide transition wrapper for hero-like transitions.
/// Optimized curves for smooth 120Hz.
class SlideTransitionWrapper extends StatelessWidget {
  const SlideTransitionWrapper({
    super.key,
    required this.child,
    this.direction = SlideDirection.up,
    this.delay = Duration.zero,
    this.duration = AppMotionSystem.slow,
    this.curve = AppMotionSystem.easeOut,
  });

  final Widget child;
  final SlideDirection direction;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    double beginX = 0;
    double beginY = 0;

    switch (direction) {
      case SlideDirection.up:
        beginY = 0.12;
        break;
      case SlideDirection.down:
        beginY = -0.12;
        break;
      case SlideDirection.left:
        beginX = 0.12;
        break;
      case SlideDirection.right:
        beginX = -0.12;
        break;
    }

    return child
        .animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .slide(
          begin: Offset(beginX, beginY),
          end: Offset.zero,
          duration: duration,
          curve: curve,
        );
  }
}

enum SlideDirection { up, down, left, right }

/// Hover scale effect for desktop/web interactions.
/// Smooth and subtle for professional feel.
class HoverScale extends StatefulWidget {
  const HoverScale({
    super.key,
    required this.child,
    this.scale = 1.02,
    this.duration = AppMotionSystem.quick,
    this.onTap,
  });

  final Widget child;
  final double scale;
  final Duration duration;
  final VoidCallback? onTap;

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? widget.scale : 1.0,
          duration: widget.duration,
          curve: AppMotionSystem.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Hover lift effect with shadow for cards.
class HoverLift extends StatefulWidget {
  const HoverLift({
    super.key,
    required this.child,
    this.liftAmount = 4.0,
    this.duration = AppMotionSystem.quick,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final double liftAmount;
  final Duration duration;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: AppMotionSystem.easeOut,
          transform: Matrix4.translationValues(
            0,
            _hovered ? -widget.liftAmount : 0,
            0,
          ),
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: isDark ? AppOpacity.divider : AppOpacity.medium),
                      blurRadius: AppTokens.shadow.xl,
                      offset: Offset(0, AppShadowOffset.lg.dy + widget.liftAmount),
                    ),
                  ]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Typing indicator animation (three dots).
/// Smooth timing for natural feel.
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({
    super.key,
    this.color,
    this.size = 8,
  });

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = color ?? theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: size,
          height: size,
          margin: EdgeInsets.symmetric(horizontal: size / 4),
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(),
              delay: AppMotionSystem.staggerTyping * index,
            )
            .scaleXY(
              begin: AppMotionSystem.scaleDotsMin,
              end: AppMotionSystem.scaleNone,
              duration: AppMotionSystem.medium,
              curve: AppMotionSystem.easeInOut,
            )
            .then()
            .scaleXY(
              begin: AppMotionSystem.scaleNone,
              end: AppMotionSystem.scaleDotsMin,
              duration: AppMotionSystem.medium,
              curve: AppMotionSystem.easeInOut,
            );
      }),
    );
  }
}

/// Smooth spring-based button press animation.
class SpringButton extends StatefulWidget {
  const SpringButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.hapticFeedback = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool hapticFeedback;

  @override
  State<SpringButton> createState() => _SpringButtonState();
}

class _SpringButtonState extends State<SpringButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotionSystem.instant,
      reverseDuration: AppMotionSystem.medium,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppMotionSystem.pressScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppMotionSystem.decelerate,
      reverseCurve: AppMotionSystem.overshoot,
    ));
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
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    if (!widget.enabled || widget.onTap == null) return;
    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap != null ? _handleTap : null,
      onLongPress: widget.onLongPress,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Animated visibility toggle with smooth fade and scale.
class SmoothVisibility extends StatelessWidget {
  const SmoothVisibility({
    super.key,
    required this.visible,
    required this.child,
    this.duration = AppMotionSystem.quick,
    this.curve = AppMotionSystem.easeOut,
    this.maintainState = false,
    this.maintainSize = false,
  });

  final bool visible;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool maintainState;
  final bool maintainSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration,
      curve: curve,
      child: AnimatedScale(
        scale: visible ? 1.0 : 0.95,
        duration: duration,
        curve: curve,
        child: maintainSize || maintainState
            ? child
            : (visible ? child : const SizedBox.shrink()),
      ),
    );
  }
}
