import 'dart:ui';

import 'package:flutter/material.dart';

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
        solid ? Colors.white : Colors.white.withValues(alpha: 0.9);
    final darkBase = solid
        ? colors.surface
        : colors.surfaceContainerHighest.withValues(alpha: 0.96);
    final background = solidBackground ?? (isDark ? darkBase : lightBase);
    final shadowColor =
        isDark ? Colors.black.withValues(alpha: 0.42) : const Color(0x1F274362);
    final blurSigma = solid ? 0.0 : 18.0;

    final media = MediaQuery.of(context);
    final bottomInset = media.padding.bottom;
    final shouldFloatFab = _showQuickAction && !inlineQuickAction;

    Widget navSurface(Widget child) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(28),
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

    if (!shouldFloatFab) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 8),
        child: navSurface(navRow),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 12),
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
        widgets.add(const SizedBox(width: 10));
        widgets.add(
          _InlineQuickActionButton(
            active: quickActionOpen,
            onTap: onQuickAction!,
          ),
        );
        widgets.add(const SizedBox(width: 10));
      }

      final addGapAfter = i != count - 1;
      if (addGapAfter) {
        widgets.add(const SizedBox(width: 6));
      }
    }

    return widgets;
  }
}

class _GlassNavItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = colors.primary;
    final inactiveColor =
        isDark ? colors.onSurface.withValues(alpha: 0.75) : Colors.black54;
    final highlightColor = activeColor.withValues(alpha: isDark ? 0.24 : 0.12);
    final activeIconColor = colors.onPrimary;
    final displayIcon = selected ? selectedIcon ?? icon : icon;
    return PressableScale(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected ? highlightColor : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconTheme(
              data: IconThemeData(
                size: 22,
                color: selected ? activeIconColor : inactiveColor,
              ),
              child: displayIcon,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 4,
            width: selected ? 18 : 0,
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
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
        : Colors.white.withValues(alpha: 0.96);
    final labelShadowBase =
        isDark ? Colors.black : Colors.black.withValues(alpha: 0.08);
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
                  borderRadius: BorderRadius.circular(30),
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
                  borderRadius: BorderRadius.circular(22),
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
              scale: 0.92,
              onTap: onTap,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: [
                    BoxShadow(
                      color: bubbleShadow,
                      blurRadius: 30,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Icon(
                  active ? Icons.close : Icons.add,
                  color: onAccent,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.xs,
          ),
          decoration: BoxDecoration(
            color: labelBackground,
            borderRadius: BorderRadius.circular(999),
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
            scale: 0.92,
            onTap: onTap,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                active ? Icons.close : Icons.add,
                color: onColor,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
