import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'icon_box.dart';

// =============================================================================
// POPUP MENU - Global dropdown menu components
// =============================================================================
// Unified popup menu styling matching dashboard design patterns.
// Uses design tokens for consistent spacing, typography, and colors.
// =============================================================================

/// A styled popup menu button with consistent appearance across the app.
///
/// Usage:
/// ```dart
/// AppPopupMenuButton<MyAction>(
///   onSelected: (action) => handleAction(action),
///   itemBuilder: (context) => [
///     AppPopupMenuItem(value: MyAction.export, icon: Icons.export, label: 'Export'),
///     AppPopupMenuDivider(),
///     AppPopupMenuItem(value: MyAction.reset, icon: Icons.restart, label: 'Reset', tint: palette.danger),
///   ],
/// )
/// ```
class AppPopupMenuButton<T> extends StatelessWidget {
  const AppPopupMenuButton({
    super.key,
    required this.onSelected,
    required this.itemBuilder,
    this.icon,
    this.iconWidget,
    this.enabled = true,
  });

  /// Called when a menu item is selected.
  final PopupMenuItemSelected<T> onSelected;

  /// Builder for the menu items.
  final List<PopupMenuEntry<T>> Function(BuildContext context) itemBuilder;

  /// Custom icon to display. Defaults to more_vert_rounded.
  final IconData? icon;

  /// Custom icon widget (takes precedence over [icon]).
  final Widget? iconWidget;

  /// Whether the button is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    return PopupMenuButton<T>(
      onSelected: onSelected,
      enabled: enabled,
      shape: RoundedRectangleBorder(
        borderRadius: AppTokens.radius.lg,
      ),
      elevation: isDark
          ? AppTokens.shadow.elevationDark
          : AppTokens.shadow.elevationLight,
      color: isDark ? colors.surfaceContainerHigh : colors.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: colors.shadow.withValues(
        alpha: isDark ? AppOpacity.divider : AppOpacity.medium,
      ),
      padding: EdgeInsets.zero,
      icon: iconWidget ??
          SizedBox(
            width: AppTokens.componentSize.buttonXs,
            height: AppTokens.componentSize.buttonXs,
            child: Center(
              child: Icon(
                icon ?? Icons.more_vert_rounded,
                size: AppTokens.iconSize.md,
                color: palette.muted,
              ),
            ),
          ),
      itemBuilder: itemBuilder,
    );
  }
}

/// A styled popup menu item with icon and label.
///
/// Follows dashboard design patterns with proper spacing and typography.
class AppPopupMenuItem<T> extends PopupMenuEntry<T> {
  const AppPopupMenuItem({
    super.key,
    required this.value,
    required this.icon,
    required this.label,
    this.tint,
    this.enabled = true,
  });

  /// The value returned when this item is selected.
  final T value;

  /// The icon to display.
  final IconData icon;

  /// The label text.
  final String label;

  /// Optional tint color for the icon. Defaults to primary.
  final Color? tint;

  /// Whether this item is enabled.
  final bool enabled;

  @override
  double get height => AppTokens.componentSize.menuItemHeight;

  @override
  bool represents(T? value) => value == this.value;

  @override
  State<AppPopupMenuItem<T>> createState() => _AppPopupMenuItemState<T>();
}

class _AppPopupMenuItemState<T> extends State<AppPopupMenuItem<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    final iconTint = widget.tint ?? colors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.enabled
            ? () => Navigator.pop(context, widget.value)
            : null,
        splashColor: colors.primary.withValues(alpha: AppOpacity.highlight),
        highlightColor: colors.primary.withValues(alpha: AppOpacity.micro),
        child: Opacity(
          opacity: widget.enabled ? 1.0 : AppOpacity.soft,
          child: Padding(
            padding: spacing.edgeInsetsSymmetric(
              horizontal: spacing.lg,
              vertical: spacing.md,
            ),
            child: Row(
              children: [
                IconBox(
                  icon: widget.icon,
                  tint: iconTint,
                ),
                SizedBox(width: spacing.md + spacing.micro),
                Flexible(
                  child: Text(
                    widget.label,
                    style: AppTokens.typography.bodySecondary.copyWith(
                      fontWeight: AppTokens.fontWeight.medium,
                      color: colors.onSurface,
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
}

/// A gradient divider for separating menu sections.
class AppPopupMenuDivider<T> extends PopupMenuEntry<T> {
  const AppPopupMenuDivider({super.key});

  @override
  double get height => AppTokens.componentSize.divider + AppTokens.spacing.md;

  @override
  bool represents(T? value) => false;

  @override
  State<AppPopupMenuDivider<T>> createState() => _AppPopupMenuDividerState<T>();
}

class _AppPopupMenuDividerState<T> extends State<AppPopupMenuDivider<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    return Padding(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      child: Container(
        height: AppTokens.componentSize.divider,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.outline.withValues(alpha: AppOpacity.transparent),
              colors.outline.withValues(
                alpha: isDark ? AppOpacity.accent : AppOpacity.divider,
              ),
              colors.outline.withValues(alpha: AppOpacity.transparent),
            ],
          ),
        ),
      ),
    );
  }
}
