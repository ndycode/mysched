import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/analytics_service.dart';
import '../theme/tokens.dart';

typedef ButtonTap = VoidCallback?;

/// Prominent call-to-action used across high-impact flows.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.expanded = true,
    this.minHeight,
    this.padding,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool expanded;
  final double? minHeight;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final baseTextStyle = textStyle ?? AppTokens.typography.label;
    final child = _ButtonContent(
      label: label,
      leading: leading,
      textColor: colors.onPrimary,
      textStyle: baseTextStyle,
    );

    final button = FilledButton(
      onPressed: onPressed == null
          ? null
          : () {
              _emitHaptic(source: 'primary_button');
              AnalyticsService.instance.logEvent(
                'ui_tap_primary_button',
                params: {'label': label},
              );
              onPressed?.call();
            },
      style: FilledButton.styleFrom(
        minimumSize: Size.fromHeight(minHeight ?? 52),
        padding: padding ??
            AppTokens.spacing.edgeInsetsSymmetric(
              horizontal: AppTokens.spacing.xl,
              vertical: AppTokens.spacing.md,
            ),
        textStyle: baseTextStyle,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xl),
      ),
      child: child,
    );

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.expanded = true,
    this.minHeight,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool expanded;
  final double? minHeight;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final baseTextStyle = textStyle ?? AppTokens.typography.label;
    final child = _ButtonContent(
      label: label,
      leading: leading,
      textColor: colors.primary,
      textStyle: baseTextStyle,
    );

    final button = OutlinedButton(
      onPressed: onPressed == null
          ? null
          : () {
              _emitHaptic(source: 'secondary_button');
              AnalyticsService.instance.logEvent(
                'ui_tap_secondary_button',
                params: {'label': label},
              );
              onPressed?.call();
            },
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, minHeight ?? 52),
        side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
        padding: AppTokens.spacing.edgeInsetsSymmetric(
          horizontal: AppTokens.spacing.xl,
          vertical: AppTokens.spacing.md,
        ),
        textStyle: baseTextStyle,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xl),
      ),
      child: child,
    );

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

void _emitHaptic({required String source}) {
  HapticFeedback.lightImpact();
  AnalyticsService.instance.logEvent(
    'ui_haptic_feedback',
    params: {'source': source, 'pattern': 'light_impact'},
  );
}

class IconTonalButton extends StatelessWidget {
  const IconTonalButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.expanded = false,
    this.textStyle,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool expanded;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseTextStyle = textStyle ?? AppTokens.typography.label;
    final style = FilledButton.styleFrom(
      minimumSize: const Size(0, 52),
      backgroundColor: isDark
          ? colors.surface.withValues(alpha: 0.55)
          : colors.surfaceContainerHighest,
      foregroundColor: colors.onSurface,
      shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xl),
      padding: AppTokens.spacing.edgeInsetsSymmetric(
        horizontal: AppTokens.spacing.lg,
        vertical: AppTokens.spacing.md,
      ),
      textStyle: baseTextStyle,
    );

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20),
        SizedBox(width: AppTokens.spacing.sm),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: baseTextStyle.copyWith(color: colors.onSurface),
          ),
        ),
      ],
    );

    final button = FilledButton.tonal(
      onPressed: onPressed == null
          ? null
          : () {
              AnalyticsService.instance.logEvent(
                'ui_tap_icon_tonal_button',
                params: {'label': label},
              );
              onPressed?.call();
            },
      style: style,
      child: child,
    );

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    this.leading,
    this.textColor,
    this.textStyle,
  });

  final String label;
  final Widget? leading;
  final Color? textColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final baseStyle = textStyle ??
        Theme.of(context).textTheme.labelLarge ??
        AppTokens.typography.label;
    final resolvedStyle =
        textColor == null ? baseStyle : baseStyle.copyWith(color: textColor);
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: resolvedStyle,
    );

    if (leading == null) return text;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(right: AppTokens.spacing.sm),
          child: IconTheme.merge(
            data: IconThemeData(
              size: 20,
              color: textColor,
            ),
            child: leading!,
          ),
        ),
        Flexible(child: text),
      ],
    );
  }
}
