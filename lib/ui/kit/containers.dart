import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/analytics_service.dart';
import '../theme/motion.dart';
import '../theme/tokens.dart';

/// Card style variants for unified styling across the app.
enum CardVariant {
  /// Standard elevated card with subtle shadow (default).
  elevated,

  /// Outlined card with border, no shadow.
  outlined,

  /// Filled card with solid background, no border.
  filled,

  /// Glass-morphism card with blur backdrop.
  glass,

  /// Hero card with gradient accent and prominent shadow.
  hero,
}

class CardX extends StatefulWidget {
  const CardX({
    super.key,
    required this.child,
    this.variant = CardVariant.elevated,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.accentColor,
    this.elevation,
    this.animateOnTap = true,
    this.hapticFeedback = true,
  });

  final Widget child;
  final CardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final Color? accentColor;
  final double? elevation;

  /// Whether to animate scale on tap (default: true).
  final bool animateOnTap;

  /// Whether to trigger haptic feedback on tap (default: true).
  final bool hapticFeedback;

  @override
  State<CardX> createState() => _CardXState();
}

class _CardXState extends State<CardX> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotionSystem.instant,
      reverseDuration: AppMotionSystem.quick,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.975).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null && widget.animateOnTap) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    if (widget.hapticFeedback) {
      HapticFeedback.selectionClick();
    }
    AnalyticsService.instance.logEvent(
      'ui_tap_cardx',
      params: {'route': ModalRoute.of(context)?.settings.name},
    );
    widget.onTap!();
  }

  void _handleLongPress() {
    if (widget.onLongPress == null) return;
    if (widget.hapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    widget.onLongPress!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final radius = widget.borderRadius ?? AppTokens.radius.xl;

    // Resolve colors based on variant
    final CardStyle style = _resolveStyle(
      variant: widget.variant,
      colors: colors,
      isDark: isDark,
      backgroundOverride: widget.backgroundColor,
      borderOverride: widget.borderColor,
      accentColor: widget.accentColor,
      elevationOverride: widget.elevation,
      hovered: _hovered && widget.onTap != null,
    );

    final defaultPadding = AppTokens.spacing.edgeInsetsSymmetric(
      horizontal: AppTokens.spacing.xl,
      vertical: AppTokens.spacing.lg + 2,
    );

    Widget cardContent = Padding(
      padding: widget.padding ?? defaultPadding,
      child: SizedBox(width: double.infinity, child: widget.child),
    );

    // Glass variant needs backdrop filter
    if (widget.variant == CardVariant.glass) {
      cardContent = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(
            duration: AppTokens.motion.fast,
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: radius,
              border: style.border,
              boxShadow: style.shadows,
            ),
            child: cardContent,
          ),
        ),
      );
    } else {
      cardContent = AnimatedContainer(
        duration: AppTokens.motion.fast,
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: radius,
          border: style.border,
          boxShadow: style.shadows,
          gradient: style.gradient,
        ),
        child: cardContent,
      );
    }

    final Widget card = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap != null ? _handleTap : null,
        onLongPress: widget.onLongPress != null ? _handleLongPress : null,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: widget.animateOnTap && widget.onTap != null
            ? AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  );
                },
                child: cardContent,
              )
            : cardContent,
      ),
    );

    if (widget.margin == null) return card;
    return Padding(padding: widget.margin!, child: card);
  }

  CardStyle _resolveStyle({
    required CardVariant variant,
    required ColorScheme colors,
    required bool isDark,
    Color? backgroundOverride,
    Color? borderOverride,
    Color? accentColor,
    double? elevationOverride,
    bool hovered = false,
  }) {
    // Hover adjustments

    final hoverShadowBoost = hovered ? 4.0 : 0.0;

    switch (variant) {
      case CardVariant.elevated:
        return CardStyle(
          background: backgroundOverride ??
              (isDark ? colors.surfaceContainerHigh : colors.surface),
          border: Border.all(
            color: borderOverride ??
                (hovered
                    ? colors.primary.withValues(alpha: AppOpacity.ghost)
                    : (isDark
                        ? colors.outline.withValues(alpha: AppOpacity.overlay)
                        : colors.outlineVariant)),
            width: isDark ? 1 : 0.5,
          ),
          shadows: isDark
              ? []
              : [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: hovered ? AppOpacity.highlight : AppOpacity.faint),
                    blurRadius: hovered ? 16 : 12,
                    offset: hovered ? const Offset(0, 6) : const Offset(0, 4),
                  ),
                ],
        );

      case CardVariant.outlined:
        return CardStyle(
          background: backgroundOverride ??
              (hovered
                  ? colors.primary.withValues(alpha: isDark ? AppOpacity.faint : AppOpacity.faint)
                  : Colors.transparent),
          border: Border.all(
            color: borderOverride ??
                (hovered
                    ? colors.primary.withValues(alpha: isDark ? AppOpacity.subtle : AppOpacity.barrier)
                    : colors.outline.withValues(alpha: isDark ? AppOpacity.barrier : AppOpacity.ghost)),
            width: 1.5,
          ),
          shadows: const [],
        );

      case CardVariant.filled:
        return CardStyle(
          background: backgroundOverride ??
              (hovered
                  ? (isDark
                      ? colors.primary.withValues(alpha: AppOpacity.overlay)
                      : colors.primary.withValues(alpha: AppOpacity.faint))
                  : (isDark
                      ? colors.surfaceContainerHighest
                      : colors.surfaceContainerHigh)),
          border: null,
          shadows: const [],
        );

      case CardVariant.glass:
        return CardStyle(
          background: backgroundOverride ??
              (isDark
                  ? colors.surface.withValues(alpha: hovered ? AppOpacity.muted : AppOpacity.glass)
                  : colors.surface.withValues(alpha: hovered ? AppOpacity.prominent : AppOpacity.prominent)),
          border: Border.all(
            color: borderOverride ??
                (hovered
                    ? colors.primary.withValues(alpha: AppOpacity.ghost)
                    : (isDark
                        ? colors.outline.withValues(alpha: AppOpacity.darkTint)
                        : colors.outline.withValues(alpha: AppOpacity.statusBg))),
          ),
          shadows: [
            BoxShadow(
              color: hovered
                  ? colors.primary.withValues(alpha: isDark ? AppOpacity.darkTint : AppOpacity.overlay)
                  : colors.shadow.withValues(alpha: isDark ? AppOpacity.ghost : AppOpacity.overlay),
              blurRadius: 24 + hoverShadowBoost,
              offset: const Offset(0, 8),
            ),
          ],
        );

      case CardVariant.hero:
        final accent = accentColor ?? colors.primary;
        return CardStyle(
          background: backgroundOverride,
          border: null,
          shadows: [
            BoxShadow(
              color: accent.withValues(alpha: isDark ? (hovered ? AppOpacity.barrier : AppOpacity.ghost) : (hovered ? AppOpacity.ghost : AppOpacity.darkTint)),
              blurRadius: 24 + hoverShadowBoost,
              offset: Offset(0, 16 + (hovered ? 2 : 0)),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: isDark ? AppOpacity.prominent : AppOpacity.prominent),
              accent.withValues(alpha: isDark ? AppOpacity.muted : AppOpacity.muted),
            ],
          ),
        );
    }
  }
}

/// Internal style configuration for CardX variants.
class CardStyle {
  const CardStyle({
    required this.background,
    required this.border,
    required this.shadows,
    this.gradient,
  });

  final Color? background;
  final BoxBorder? border;
  final List<BoxShadow> shadows;
  final Gradient? gradient;
}

class Section extends StatelessWidget {
  const Section({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.children,
    this.spacing,
    this.padding,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final double? spacing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final header = (title == null && subtitle == null && trailing == null)
        ? null
        : Padding(
            padding: AppTokens.spacing.edgeInsetsOnly(
              bottom: AppTokens.spacing.lg,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: theme.textTheme.titleMedium,
                        ),
                      if (subtitle != null)
                        Padding(
                          padding: AppTokens.spacing.edgeInsetsOnly(
                            top: AppTokens.spacing.sm,
                          ),
                          child: Text(
                            subtitle!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          );

    return Padding(
      padding: padding ??
          AppTokens.spacing.edgeInsetsSymmetric(
            vertical: AppTokens.spacing.xl,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) header,
          ..._spaced(children, spacing ?? AppTokens.spacing.md),
        ],
      ),
    );
  }

  List<Widget> _spaced(List<Widget> items, double spacing) {
    if (items.isEmpty) return const [];
    return [
      for (int i = 0; i < items.length; i++) ...[
        items[i],
        if (i != items.length - 1) SizedBox(height: spacing),
      ],
    ];
  }
}

class DividerX extends StatelessWidget {
  const DividerX({super.key, this.inset = 0});

  final double inset;

  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      height: AppTokens.spacing.xl,
      thickness: 1,
      indent: inset,
      endIndent: inset,
    );
    return divider;
  }
}
