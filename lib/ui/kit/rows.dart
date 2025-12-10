import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'responsive_provider.dart';
import 'switch.dart';

/// A reusable row widget with an icon badge, title, description, and trailing widget.
/// 
/// Use [ToggleRow] for toggle switches or [NavigationRow] for tap actions.
/// Automatically adapts to screen size via [ResponsiveProvider].
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.accentColor,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? description;
  final Color? accentColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final accent = accentColor ?? colors.primary;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon badge
        Container(
          height: AppTokens.componentSize.avatarLg * scale,
          width: AppTokens.componentSize.avatarLg * scale,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: AppOpacity.medium),
            borderRadius: AppTokens.radius.md,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: accent, size: AppTokens.iconSize.lg * scale),
        ),
        SizedBox(width: spacing.md * spacingScale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTokens.typography.subtitleScaled(scale).copyWith(
                  color: colors.onSurface,
                  fontWeight: AppTokens.fontWeight.semiBold,
                ),
              ),
              if (description != null) ...[
                SizedBox(height: spacing.xs * spacingScale),
                Text(
                  description!,
                  style: AppTokens.typography.captionScaled(scale).copyWith(
                    color: palette.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: spacing.md * spacingScale),
          trailing!,
        ],
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: spacing.edgeInsetsSymmetric(vertical: spacing.sm * spacingScale),
          child: content,
        ),
      );
    }

    return Padding(
      padding: spacing.edgeInsetsSymmetric(vertical: spacing.sm * spacingScale),
      child: content,
    );
  }
}


/// A settings row with a toggle switch.
class ToggleRow extends StatelessWidget {
  const ToggleRow({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    this.accentColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = accentColor ?? colors.primary;

    return SettingsRow(
      icon: icon,
      title: title,
      description: description,
      accentColor: accent,
      onTap: () => onChanged(!value),
      trailing: AppSwitch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

/// A settings row with a chevron for navigation.
class NavigationRow extends StatelessWidget {
  const NavigationRow({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    required this.onTap,
    this.accentColor,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? description;
  final VoidCallback onTap;
  final Color? accentColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    return SettingsRow(
      icon: icon,
      title: title,
      description: description,
      accentColor: accentColor,
      onTap: onTap,
      trailing: trailing ?? Icon(
        Icons.chevron_right_rounded,
        color: palette.muted,
      ),
    );
  }
}
