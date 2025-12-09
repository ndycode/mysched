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
        solid ? colors.surface : colors.surface.withValues(alpha: AppOpacity.high);
    final darkBase = solid
        ? colors.surface
        : colors.surfaceContainerHighest.withValues(alpha: AppOpacity.dense);
    final background = solidBackground ?? (isDark ? darkBase : lightBase);
    final shadowColor =
        colors.shadow.withValues(alpha: isDark ? AppOpacity.shadowDark : AppOpacity.shadowStrong);
    final blurSigma = solid ? 0.0 : AppTokens.shadow.action;

    final media = MediaQuery.of(context);
    final bottomInset = media.padding.bottom;
    final shouldFloatFab = _showQuickAction && !inlineQuickAction;
    final basePadding = AppTokens.spacing.edgeInsetsSymmetric(
      horizontal: AppTokens.spacing.lg,
      vertical: AppTokens.spacing.md,
    );
    final double baseBottomPadding = shouldFloatFab ? AppTokens.spacing.md : AppTokens.spacing.sm;
    final double bottomPadding = baseBottomPadding + bottomInset;
    final horizontalPadding = AppTokens.spacing.edgeInsetsSymmetric(horizontal: AppTokens.spacing.lg);

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
                AppTokens.shadow.navBar(shadowColor),
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
              top: AppTokens.componentSize.navFabOffset,
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

    _scaleAnimation = Tween<double>(begin: AppMotionSystem.scaleNone, end: AppMotionSystem.scaleEmphasis).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotionSystem.easeOut,
        reverseCurve: AppMotionSystem.easeIn,
      ),
    );

    _indicatorWidthAnimation = Tween<double>(begin: 0.0, end: AppMotionSystem.indicatorWidth).animate(
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
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final activeColor = colors.primary;
    final inactiveColor = palette.muted;
    final highlightColor = activeColor.withValues(alpha: isDark ? AppOpacity.shadowBubble : AppOpacity.overlay);
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
                        ? activeColor.withValues(alpha: isDark ? AppOpacity.highlight : AppOpacity.faint)
                        : Colors.transparent),
                borderRadius: AppTokens.radius.lg,
              ),
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.selected ? _scaleAnimation.value : AppMotionSystem.scaleNone,
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
                  height: AppTokens.componentSize.progressHeight,
                  width: _indicatorWidthAnimation.value,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: AppTokens.radius.pill,
                    boxShadow: widget.selected
                        ? [
                            AppTokens.shadow.elevation1(
                              activeColor.withValues(alpha: AppOpacity.divider),
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
    final bubbleShadow = accent.withValues(alpha: isDark ? AppOpacity.shadowAction : AppOpacity.darkTint);
    final labelBackground = isDark
        ? colors.surfaceContainerHighest
        : colors.surface.withValues(alpha: AppOpacity.dense);
    final labelShadowBase = colors.shadow;
    final labelShadow = labelShadowBase.withValues(alpha: isDark ? AppOpacity.subtle : AppOpacity.border);
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: AppTokens.componentSize.navBubbleOuterOffset,
              child: Container(
                width: AppTokens.componentSize.navBubbleLabelWidth,
                height: AppTokens.componentSize.navBubbleLabelHeight,
                decoration: BoxDecoration(
                  borderRadius: AppTokens.radius.xxxl,
                  border: Border.all(
                    color: accent.withValues(alpha: AppOpacity.border),
                    width: AppTokens.componentSize.dividerBold,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      accent.withValues(alpha: AppOpacity.highlight),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: AppTokens.componentSize.navBubbleInnerOffset,
              child: Container(
                width: AppTokens.componentSize.navBubbleInnerWidth,
                height: AppTokens.componentSize.navBubbleInnerHeight,
                decoration: BoxDecoration(
                  borderRadius: AppTokens.radius.xl,
                  border: Border.all(
                    color: accent.withValues(alpha: AppOpacity.darkTint),
                    width: AppTokens.componentSize.dividerNav,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      labelBackground.withValues(alpha: isDark ? AppOpacity.high : AppOpacity.solid),
                      labelBackground.withValues(alpha: isDark ? AppOpacity.skeletonLight : AppOpacity.labelGradient),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: labelShadow,
                      blurRadius: AppTokens.shadow.lg,
                      offset: AppShadowOffset.lg,
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
                width: AppTokens.componentSize.navBubbleSize,
                height: AppTokens.componentSize.navBubbleSize,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: AppTokens.radius.pill,
                  boxShadow: [
                    BoxShadow(
                      color: bubbleShadow,
                      blurRadius: active ? AppTokens.shadow.navBubbleActive : AppTokens.shadow.navBubbleInactive,
                      offset: active ? AppShadowOffset.navBubbleActive : AppShadowOffset.navBubbleInactive,
                      spreadRadius: active ? AppTokens.shadow.spreadMd : 0,
                    ),
                  ],
                ),
                child: AnimatedRotation(
                  turns: active ? AppMotionSystem.rotationToggle : 0.0,
                  duration: AppMotionSystem.medium,
                  curve: AppMotionSystem.easeOut,
                  child: Icon(
                    active ? Icons.close : Icons.add,
                    color: onAccent,
                    size: AppTokens.iconSize.fab,
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
                blurRadius: AppTokens.shadow.md,
                offset: AppShadowOffset.md,
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTokens.typography.caption.copyWith(
              fontWeight: AppTokens.fontWeight.semiBold,
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
      width: AppTokens.componentSize.navItemWidth,
      height: AppTokens.componentSize.navItemHeight,
      child: Align(
        alignment: Alignment.topCenter,
        child: Transform.translate(
          offset: AppShadowOffset.navFabLift,
          child: PressableScale(
            variant: PressableVariant.deep,
            onTap: onTap,
            hapticFeedback: true,
            child: AnimatedContainer(
              duration: AppMotionSystem.quick,
              curve: AppMotionSystem.easeOut,
              width: AppTokens.componentSize.navFabSize,
              height: AppTokens.componentSize.navFabSize,
              decoration: BoxDecoration(
                color: color,
                borderRadius: AppTokens.radius.xxl,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: active ? AppOpacity.shadowBubble : AppOpacity.border),
                    blurRadius: active ? AppTokens.shadow.glow : AppTokens.shadow.action,
                    offset: active ? AppShadowOffset.navFabActive : AppShadowOffset.navFabInactive,
                    spreadRadius: active ? AppTokens.shadow.spreadSm : 0,
                  ),
                ],
              ),
              child: AnimatedRotation(
                turns: active ? AppMotionSystem.rotationToggle : 0.0,
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
