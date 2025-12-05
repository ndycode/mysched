import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/tokens.dart';
import 'pressable_scale.dart';

class GlassNavigationBar extends StatelessWidget {
  const GlassNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    this.onQuickAction,
    this.quickActionOpen = false,
    this.quickActionLabel = 'Quick actions',
    this.solid = false,
    this.solidBackground,
    this.inlineQuickAction = false,
  });

  final int selectedIndex;
  final List<NavigationDestination> destinations;
  final void Function(int index) onDestinationSelected;
  final VoidCallback? onQuickAction;
  final bool quickActionOpen;
  final String quickActionLabel;
  final bool solid;
  final Color? solidBackground;
  final bool inlineQuickAction;

  bool get _showQuickAction => onQuickAction != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final lightBase =
        solid ? colors.surface : colors.surface.withValues(alpha: 0.9);
    final darkBase = solid
        ? colors.surface
        : colors.surfaceContainerHighest.withValues(alpha: 0.96);
    final background = solidBackground ?? (isDark ? darkBase : lightBase);
    final shadowColor =
        colors.shadow.withValues(alpha: isDark ? 0.42 : 0.12);
    final blurSigma = solid ? 0.0 : 18.0;

    final media = MediaQuery.of(context);
    final bottomInset = media.padding.bottom;
    final shouldFloatFab = _showQuickAction && !inlineQuickAction;
    final basePadding = AppTokens.spacing.edgeInsetsSymmetric(
      horizontal: AppTokens.spacing.lg,
      vertical: AppTokens.spacing.md,
    );
    final double baseBottomPadding = shouldFloatFab ? 12.0 : 8.0;
    final double bottomPadding = baseBottomPadding + bottomInset;
    const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);

    Widget navSurface(Widget child) {
      final padding = basePadding + EdgeInsets.only(bottom: bottomPadding);
      return ClipRRect(
        borderRadius: AppTokens.radius.xxl,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma,
          ),
          child: AnimatedContainer(
            duration: AppMotionSystem.quick,
            curve: AppMotionSystem.easeOut,
            padding: padding,
            decoration: BoxDecoration(
              color: background,
              borderRadius: AppTokens.radius.xxl,
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: child,
          ),
        ),
      );
    }

    final navRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: _buildDestinations(context),
    );

    Widget bar;
    if (!shouldFloatFab) {
      bar = Padding(
        padding: horizontalPadding,
        child: navSurface(navRow),
      );
    } else {
      bar = Padding(
        padding: horizontalPadding,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            navSurface(
              navRow,
            ),
            Positioned(
              top: -22,
              child: _FloatingQuickActionButton(
                onTap: onQuickAction!,
                active: quickActionOpen,
                label: quickActionLabel,
              ),
            ),
          ],
        ),
      );
    }

    // Solid surface fill behind the glass to prevent black gaps on translucent backgrounds.
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.surface),
      child: bar,
    );
  }

  List<Widget> _buildDestinations(BuildContext context) {
    final widgets = <Widget>[];
    final count = destinations.length;
    final showInline = _showQuickAction && inlineQuickAction;
    final insertAfter = (count / 2).floor() - 1;

    for (var i = 0; i < count; i++) {
      widgets.add(
        Expanded(
          child: _GlassNavItem(
            icon: destinations[i].icon,
            selectedIcon: destinations[i].selectedIcon,
            label: destinations[i].label,
            selected: i == selectedIndex,
            onTap: () => onDestinationSelected(i),
          ),
        ),
      );

      final insertQuick = showInline && i == insertAfter;
      if (insertQuick) {
        widgets.add(SizedBox(width: AppTokens.spacing.md));
        widgets.add(
          _InlineQuickActionButton(
            active: quickActionOpen,
            onTap: onQuickAction!,
          ),
        );
        widgets.add(SizedBox(width: AppTokens.spacing.md));
      }

      final addGapAfter = i != count - 1;
      if (addGapAfter) {
        widgets.add(SizedBox(width: AppTokens.spacing.xs));
      }
    }

    return widgets;
  }
}

class _GlassNavItem extends StatefulWidget {
  const _GlassNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Widget icon;
  final Widget? selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_GlassNavItem> createState() => _GlassNavItemState();
}

class _GlassNavItemState extends State<_GlassNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _indicatorWidthAnimation;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotionSystem.quick,
      reverseDuration: AppMotionSystem.quick,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotionSystem.easeOut,
        reverseCurve: AppMotionSystem.easeIn,
      ),
    );

    _indicatorWidthAnimation = Tween<double>(begin: 0.0, end: 18.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotionSystem.easeOut,
        reverseCurve: AppMotionSystem.easeIn,
      ),
    );

    if (widget.selected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_GlassNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      if (widget.selected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = colors.primary;
    final inactiveColor = colors.onSurfaceVariant;
    final highlightColor = activeColor.withValues(alpha: isDark ? 0.24 : 0.12);
    final activeIconColor = colors.onPrimary;
    final displayIcon =
        widget.selected ? widget.selectedIcon ?? widget.icon : widget.icon;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: PressableScale(
        variant: PressableVariant.subtle,
        onTap: widget.onTap,
        hapticFeedback: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppMotionSystem.quick,
              curve: AppMotionSystem.easeOut,
              padding: EdgeInsets.all(AppTokens.spacing.md),
              decoration: BoxDecoration(
                color: widget.selected
                    ? highlightColor
                    : (_hovered
                        ? activeColor.withValues(alpha: isDark ? 0.08 : 0.05)
                        : Colors.transparent),
                borderRadius: AppTokens.radius.lg,
              ),
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.selected ? _scaleAnimation.value : 1.0,
                    child: child,
                  );
                },
                child: AnimatedContainer(
                  duration: AppMotionSystem.instant,
                  curve: AppMotionSystem.easeOut,
                  child: IconTheme(
                    data: IconThemeData(
                      size: AppTokens.iconSize.lg,
                      color: widget.selected ? activeIconColor : inactiveColor,
                    ),
                    child: displayIcon,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppTokens.spacing.xs),
            AnimatedBuilder(
              animation: _indicatorWidthAnimation,
              builder: (context, _) {
                return Container(
                  height: 4,
                  width: _indicatorWidthAnimation.value,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: AppTokens.radius.pill,
                    boxShadow: widget.selected
                        ? [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.4),
                              blurRadius: 4,
                              spreadRadius: 0.5,
                            ),
                          ]
                        : [],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingQuickActionButton extends StatelessWidget {
  const _FloatingQuickActionButton({
    required this.onTap,
    required this.active,
    required this.label,
  });

  final VoidCallback onTap;
  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;
    final accent = colors.primary;
    final onAccent = colors.onPrimary;
    final bubbleShadow = accent.withValues(alpha: isDark ? 0.28 : 0.22);
    final labelBackground = isDark
        ? colors.surfaceContainerHighest
        : colors.surface.withValues(alpha: 0.96);
    final labelShadowBase = colors.shadow;
    final labelShadow = labelShadowBase.withValues(alpha: isDark ? 0.5 : 0.18);
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: -18,
              child: Container(
                width: 114,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: AppTokens.radius.xxxl,
                  border: Border.all(
                    color: accent.withValues(alpha: 0.18),
                    width: 2,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      accent.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -8,
              child: Container(
                width: 88,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: AppTokens.radius.xl,
                  border: Border.all(
                    color: accent.withValues(alpha: 0.22),
                    width: 1.4,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      labelBackground.withValues(alpha: isDark ? 0.9 : 0.98),
                      labelBackground.withValues(alpha: isDark ? 0.65 : 0.86),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: labelShadow,
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
            PressableScale(
              variant: PressableVariant.deep,
              onTap: onTap,
              hapticFeedback: true,
              child: AnimatedContainer(
                duration: AppMotionSystem.quick,
                curve: AppMotionSystem.easeOut,
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: AppTokens.radius.pill,
                  boxShadow: [
                    BoxShadow(
                      color: bubbleShadow,
                      blurRadius: active ? 36 : 30,
                      offset: Offset(0, active ? 18 : 16),
                      spreadRadius: active ? 2 : 0,
                    ),
                  ],
                ),
                child: AnimatedRotation(
                  turns: active ? 0.125 : 0.0,
                  duration: AppMotionSystem.medium,
                  curve: AppMotionSystem.easeOut,
                  child: Icon(
                    active ? Icons.close : Icons.add,
                    color: onAccent,
                    size: AppTokens.iconSize.xl + 4,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTokens.spacing.sm),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.xs,
          ),
          decoration: BoxDecoration(
            color: labelBackground,
            borderRadius: AppTokens.radius.pill,
            boxShadow: [
              BoxShadow(
                color: labelShadow,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineQuickActionButton extends StatelessWidget {
  const _InlineQuickActionButton({
    required this.active,
    required this.onTap,
  });

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    final onColor = theme.colorScheme.onPrimary;
    return SizedBox(
      width: 72,
      height: 64,
      child: Align(
        alignment: Alignment.topCenter,
        child: Transform.translate(
          offset: const Offset(0, -4),
          child: PressableScale(
            variant: PressableVariant.deep,
            onTap: onTap,
            hapticFeedback: true,
            child: AnimatedContainer(
              duration: AppMotionSystem.quick,
              curve: AppMotionSystem.easeOut,
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: AppTokens.radius.xxl,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: active ? 0.24 : 0.18),
                    blurRadius: active ? 22 : 18,
                    offset: Offset(0, active ? 12 : 10),
                    spreadRadius: active ? 1 : 0,
                  ),
                ],
              ),
              child: AnimatedRotation(
                turns: active ? 0.125 : 0.0,
                duration: AppMotionSystem.medium,
                curve: AppMotionSystem.easeOut,
                child: Icon(
                  active ? Icons.close : Icons.add,
                  color: onColor,
                  size: AppTokens.iconSize.xl,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
