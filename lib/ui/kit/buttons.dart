import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/analytics_service.dart';
import '../theme/motion.dart';
import '../theme/tokens.dart';
import 'responsive_provider.dart';

typedef ButtonTap = VoidCallback?;

/// Prominent call-to-action used across high-impact flows.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.icon,
    this.expanded = true,
    this.minHeight,
    this.padding,
    this.textStyle,
    this.loading = false,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final IconData? icon;
  final bool expanded;
  final double? minHeight;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final bool loading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final baseTextStyle = textStyle ?? AppTokens.typography.label;

    final isDisabled = onPressed == null || loading;
    final displayLabel = loading ? (loadingLabel ?? label) : label;

    Widget? leadingWidget;
    if (loading) {
      leadingWidget = SizedBox(
        width: AppInteraction.loaderSize,
        height: AppInteraction.loaderSize,
        child: CircularProgressIndicator(
          strokeWidth: AppInteraction.progressStrokeWidthLarge,
          valueColor: AlwaysStoppedAnimation<Color>(
            colors.onPrimary.withValues(alpha: AppOpacity.prominent),
          ),
        ),
      );
    } else if (leading != null) {
      leadingWidget = leading;
    } else if (icon != null) {
      leadingWidget = Icon(icon);
    }

    final child = _ButtonContent(
      label: displayLabel,
      leading: leadingWidget,
      textColor: colors.onPrimary,
      textStyle: baseTextStyle,
    );

    final button = AnimatedOpacity(
      duration: AppTokens.motion.fast,
      opacity: isDisabled ? AppOpacity.disabledButton : AppMotionSystem.scaleNone,
      child: FilledButton(
        onPressed: isDisabled
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
          minimumSize: Size.fromHeight(minHeight ?? AppTokens.componentSize.buttonLg),
          padding: padding ??
              AppTokens.spacing.edgeInsetsSymmetric(
                horizontal: AppTokens.spacing.xl,
                vertical: AppTokens.spacing.md,
              ),
          textStyle: baseTextStyle,
          shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xxl),
          disabledBackgroundColor: colors.primary.withValues(alpha: AppOpacity.muted),
          disabledForegroundColor: colors.onPrimary.withValues(alpha: AppOpacity.prominent),
        ),
        child: child,
      ),
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
    this.icon,
    this.expanded = true,
    this.minHeight,
    this.textStyle,
    this.loading = false,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final IconData? icon;
  final bool expanded;
  final double? minHeight;
  final TextStyle? textStyle;
  final bool loading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final baseTextStyle = textStyle ?? AppTokens.typography.label;

    final isDisabled = onPressed == null || loading;
    final displayLabel = loading ? (loadingLabel ?? label) : label;

    Widget? leadingWidget;
    if (loading) {
      leadingWidget = SizedBox(
        width: AppInteraction.loaderSize,
        height: AppInteraction.loaderSize,
        child: CircularProgressIndicator(
          strokeWidth: AppInteraction.progressStrokeWidthLarge,
          valueColor: AlwaysStoppedAnimation<Color>(
            colors.primary.withValues(alpha: AppOpacity.muted),
          ),
        ),
      );
    } else if (leading != null) {
      leadingWidget = leading;
    } else if (icon != null) {
      leadingWidget = Icon(icon);
    }

    final child = _ButtonContent(
      label: displayLabel,
      leading: leadingWidget,
      textColor: colors.primary,
      textStyle: baseTextStyle,
    );

    final button = AnimatedOpacity(
      duration: AppTokens.motion.fast,
      opacity: isDisabled ? AppOpacity.soft : AppMotionSystem.scaleNone,
      child: OutlinedButton(
        onPressed: isDisabled
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
          minimumSize: Size(0, minHeight ?? AppTokens.componentSize.buttonLg),
          side: BorderSide(
            color: isDisabled
                ? colors.primary.withValues(alpha: AppOpacity.ghost)
                : colors.primary.withValues(alpha: AppOpacity.subtle),
          ),
          padding: AppTokens.spacing.edgeInsetsSymmetric(
            horizontal: AppTokens.spacing.xl,
            vertical: AppTokens.spacing.md,
          ),
          textStyle: baseTextStyle,
          shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xxl),
          disabledForegroundColor: colors.primary.withValues(alpha: AppOpacity.soft),
        ),
        child: child,
      ),
    );

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

/// Text-style button for tertiary/less prominent actions.
class TertiaryButton extends StatelessWidget {
  const TertiaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.minHeight,
    this.textStyle,
    this.loading = false,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final double? minHeight;
  final TextStyle? textStyle;
  final bool loading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final baseTextStyle = textStyle ?? AppTokens.typography.label;

    final isDisabled = onPressed == null || loading;
    final displayLabel = loading ? (loadingLabel ?? label) : label;

    Widget? leadingWidget;
    if (loading) {
      leadingWidget = SizedBox(
        width: AppInteraction.loaderSize,
        height: AppInteraction.loaderSize,
        child: CircularProgressIndicator(
          strokeWidth: AppInteraction.progressStrokeWidthLarge,
          valueColor: AlwaysStoppedAnimation<Color>(
            colors.primary.withValues(alpha: AppOpacity.muted),
          ),
        ),
      );
    } else if (icon != null) {
      leadingWidget = Icon(icon);
    }

    final child = _ButtonContent(
      label: displayLabel,
      leading: leadingWidget,
      textColor: colors.primary,
      textStyle: baseTextStyle,
    );

    final button = AnimatedOpacity(
      duration: AppTokens.motion.fast,
      opacity: isDisabled ? AppOpacity.soft : AppMotionSystem.scaleNone,
      child: TextButton(
        onPressed: isDisabled
            ? null
            : () {
                _emitHaptic(source: 'tertiary_button');
                AnalyticsService.instance.logEvent(
                  'ui_tap_tertiary_button',
                  params: {'label': label},
                );
                onPressed?.call();
              },
        style: TextButton.styleFrom(
          minimumSize: Size(0, minHeight ?? AppTokens.componentSize.buttonLg),
          padding: AppTokens.spacing.edgeInsetsSymmetric(
            horizontal: AppTokens.spacing.xl,
            vertical: AppTokens.spacing.md,
          ),
          textStyle: baseTextStyle,
          shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xxl),
          foregroundColor: colors.primary,
          disabledForegroundColor: colors.primary.withValues(alpha: AppOpacity.soft),
        ),
        child: child,
      ),
    );

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

/// Text-style button for destructive/dangerous actions.
class DestructiveTextButton extends StatelessWidget {
  const DestructiveTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.minHeight,
    this.loading = false,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final double? minHeight;
  final bool loading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final baseTextStyle = AppTokens.typography.label;

    final isDisabled = onPressed == null || loading;
    final displayLabel = loading ? (loadingLabel ?? label) : label;

    Widget? leadingWidget;
    if (loading) {
      leadingWidget = SizedBox(
        width: AppInteraction.loaderSize,
        height: AppInteraction.loaderSize,
        child: CircularProgressIndicator(
          strokeWidth: AppInteraction.progressStrokeWidthLarge,
          valueColor: AlwaysStoppedAnimation<Color>(
            palette.danger.withValues(alpha: AppOpacity.muted),
          ),
        ),
      );
    } else if (icon != null) {
      leadingWidget = Icon(icon);
    }

    final child = _ButtonContent(
      label: displayLabel,
      leading: leadingWidget,
      textColor: palette.danger,
      textStyle: baseTextStyle,
    );

    final button = AnimatedOpacity(
      duration: AppTokens.motion.fast,
      opacity: isDisabled ? AppOpacity.soft : AppMotionSystem.scaleNone,
      child: TextButton(
        onPressed: isDisabled
            ? null
            : () {
                _emitHaptic(source: 'destructive_text_button');
                AnalyticsService.instance.logEvent(
                  'ui_tap_destructive_text_button',
                  params: {'label': label},
                );
                onPressed?.call();
              },
        style: TextButton.styleFrom(
          minimumSize: Size(0, minHeight ?? AppTokens.componentSize.buttonLg),
          padding: AppTokens.spacing.edgeInsetsSymmetric(
            horizontal: AppTokens.spacing.xl,
            vertical: AppTokens.spacing.md,
          ),
          textStyle: baseTextStyle,
          shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xxl),
          foregroundColor: palette.danger,
          disabledForegroundColor: palette.danger.withValues(alpha: AppOpacity.soft),
        ),
        child: child,
      ),
    );

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

/// Destructive action button for dangerous operations.
class DestructiveButton extends StatelessWidget {
  const DestructiveButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.minHeight,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final double? minHeight;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final baseTextStyle = AppTokens.typography.label;

    final isDisabled = onPressed == null || loading;

    Widget? leadingWidget;
    if (loading) {
      leadingWidget = SizedBox(
        width: AppInteraction.loaderSize,
        height: AppInteraction.loaderSize,
        child: CircularProgressIndicator(
          strokeWidth: AppInteraction.progressStrokeWidthLarge,
          valueColor: AlwaysStoppedAnimation<Color>(
            colors.onError.withValues(alpha: AppOpacity.prominent),
          ),
        ),
      );
    } else if (icon != null) {
      leadingWidget = Icon(icon);
    }

    final child = _ButtonContent(
      label: label,
      leading: leadingWidget,
      textColor: colors.onError,
      textStyle: baseTextStyle,
    );

    final button = AnimatedOpacity(
      duration: AppTokens.motion.fast,
      opacity: isDisabled ? AppOpacity.disabledButton : AppMotionSystem.scaleNone,
      child: FilledButton(
        onPressed: isDisabled
            ? null
            : () {
                _emitHaptic(source: 'destructive_button');
                AnalyticsService.instance.logEvent(
                  'ui_tap_destructive_button',
                  params: {'label': label},
                );
                onPressed?.call();
              },
        style: FilledButton.styleFrom(
          minimumSize: Size.fromHeight(minHeight ?? AppTokens.componentSize.buttonLg),
          backgroundColor: palette.danger,
          foregroundColor: colors.onError,
          padding: AppTokens.spacing.edgeInsetsSymmetric(
            horizontal: AppTokens.spacing.xl,
            vertical: AppTokens.spacing.md,
          ),
          textStyle: baseTextStyle,
          shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xxl),
          disabledBackgroundColor: palette.danger.withValues(alpha: AppOpacity.skeletonLight),
          disabledForegroundColor: colors.onError.withValues(alpha: AppOpacity.prominent),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return colors.onSurface.withValues(alpha: isDark ? AppOpacity.overlay : AppOpacity.highlight);
            }
            return null;
          }),
        ),
        child: child,
      ),
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
      minimumSize: Size(0, AppTokens.componentSize.buttonLg),
      backgroundColor: isDark
          ? colors.surface.withValues(alpha: AppOpacity.buttonDisabled)
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
        Icon(icon, size: AppTokens.iconSize.md),
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
    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    final baseStyle = textStyle ??
        Theme.of(context).textTheme.labelLarge ??
        AppTokens.typography.label;
    // Apply responsive scaling to font size
    final scaledStyle = baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14) * scale,
    );
    final resolvedStyle =
        textColor == null ? scaledStyle : scaledStyle.copyWith(color: textColor);
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
          padding: EdgeInsets.only(right: AppTokens.spacing.sm * spacingScale),
          child: IconTheme.merge(
            data: IconThemeData(
              size: AppTokens.iconSize.md * scale,
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
