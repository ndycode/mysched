import 'package:flutter/material.dart';

import '../../services/analytics_service.dart';
import '../theme/tokens.dart';
import 'buttons.dart';


/// Unified state display variant.
enum StateVariant {
  /// Informational empty state (no data).
  empty,

  /// Error state with retry option.
  error,

  /// Success state.
  success,

  /// Warning state.
  warning,

  /// Loading state (use skeleton instead for better UX).
  loading,
}

/// Unified state display widget for empty, error, success, and warning states.
class StateDisplay extends StatelessWidget {
  const StateDisplay({
    super.key,
    required this.variant,
    required this.title,
    required this.message,
    this.icon,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.compact = false,
  });

  /// Creates an empty state display.
  const StateDisplay.empty({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    String? actionLabel,
    VoidCallback? onAction,
    this.compact = false,
  })  : variant = StateVariant.empty,
        primaryActionLabel = actionLabel,
        onPrimaryAction = onAction,
        secondaryActionLabel = null,
        onSecondaryAction = null;

  /// Creates an error state display.
  const StateDisplay.error({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline_rounded,
    String retryLabel = 'Try again',
    VoidCallback? onRetry,
    this.compact = false,
  })  : variant = StateVariant.error,
        primaryActionLabel = retryLabel,
        onPrimaryAction = onRetry,
        secondaryActionLabel = null,
        onSecondaryAction = null;

  /// Creates a success state display.
  const StateDisplay.success({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.check_circle_outline_rounded,
    String? actionLabel,
    VoidCallback? onAction,
    this.compact = false,
  })  : variant = StateVariant.success,
        primaryActionLabel = actionLabel,
        onPrimaryAction = onAction,
        secondaryActionLabel = null,
        onSecondaryAction = null;

  final StateVariant variant;
  final String title;
  final String message;
  final IconData? icon;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    // Resolve colors based on variant
    final Color tintColor;
    final IconData displayIcon;
    switch (variant) {
      case StateVariant.empty:
        tintColor = colors.primary;
        displayIcon = icon ?? Icons.inbox_outlined;
        break;
      case StateVariant.error:
        tintColor = colors.error;
        displayIcon = icon ?? Icons.error_outline_rounded;
        break;
      case StateVariant.success:
        tintColor = colors.tertiary;
        displayIcon = icon ?? Icons.check_circle_outline_rounded;
        break;
      case StateVariant.warning:
        tintColor = colors.secondary;
        displayIcon = icon ?? Icons.warning_amber_rounded;
        break;
      case StateVariant.loading:
        tintColor = colors.primary;
        displayIcon = icon ?? Icons.hourglass_empty_rounded;
        break;
    }

    AnalyticsService.instance.logEvent(
      'ui_state_${variant.name}',
      params: {'screen': ModalRoute.of(context)?.settings.name},
    );

    final iconSize = compact ? 56.0 : 88.0;
    final iconInnerSize = compact ? 28.0 : 36.0;

    Widget? primaryButton;
    if (primaryActionLabel != null) {
      primaryButton = variant == StateVariant.error
          ? SecondaryButton(
              label: primaryActionLabel!,
              onPressed: onPrimaryAction == null
                  ? null
                  : () {
                      AnalyticsService.instance.logEvent(
                        'ui_tap_state_action',
                        params: {
                          'variant': variant.name,
                          'label': primaryActionLabel,
                        },
                      );
                      onPrimaryAction?.call();
                    },
              expanded: !compact,
            )
          : PrimaryButton(
              label: primaryActionLabel!,
              onPressed: onPrimaryAction == null
                  ? null
                  : () {
                      AnalyticsService.instance.logEvent(
                        'ui_tap_state_action',
                        params: {
                          'variant': variant.name,
                          'label': primaryActionLabel,
                        },
                      );
                      onPrimaryAction?.call();
                    },
              expanded: !compact,
            );
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: compact ? AppLayout.dialogMaxWidth : AppLayout.contentMaxWidth),
        child: Padding(
          padding: compact
              ? spacing.edgeInsetsAll(spacing.lg)
              : spacing.edgeInsetsAll(spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: tintColor.withValues(alpha: isDark ? AppOpacity.border : AppOpacity.overlay),
                  borderRadius: BorderRadius.circular(iconSize / 2),
                  border: Border.all(
                    color: tintColor.withValues(alpha: isDark ? AppOpacity.ghost : AppOpacity.accent),
                    width: AppTokens.componentSize.dividerBold,
                  ),
                ),
                child: Icon(displayIcon, color: tintColor, size: iconInnerSize),
              ),
              SizedBox(height: compact ? spacing.lg : spacing.xl),
              Text(
                title,
                style: compact
                    ? theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                      )
                    : theme.textTheme.titleLarge?.copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                      ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.md),
              Padding(
                padding: compact
                    ? EdgeInsets.zero
                    : spacing.edgeInsetsSymmetric(horizontal: spacing.xl),
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (primaryButton != null) ...[
                SizedBox(height: compact ? spacing.lg : spacing.xl),
                primaryButton,
              ],
              if (secondaryActionLabel != null) ...[
                SizedBox(height: spacing.md),
                TextButton(
                  onPressed: onSecondaryAction,
                  child: Text(secondaryActionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Legacy empty state widget - delegates to StateDisplay.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return StateDisplay.empty(
      title: title,
      message: message,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

/// Legacy error state widget - delegates to StateDisplay.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.icon = Icons.error_outline,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return StateDisplay.error(
      title: title,
      message: message,
      icon: icon,
      retryLabel: retryLabel,
      onRetry: onRetry,
    );
  }
}

/// Message card for inline state display within screens.
class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.tintColor,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Color? tintColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;
    final tint = tintColor ?? colors.primary;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.lg),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: isDark ? AppOpacity.overlay : AppOpacity.veryFaint),
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: tint.withValues(alpha: isDark ? AppOpacity.ghost : AppOpacity.statusBg),
          width: AppTokens.componentSize.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: spacing.edgeInsetsAll(spacing.md),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: isDark ? AppOpacity.accent : AppOpacity.overlay),
                  borderRadius: AppTokens.radius.md,
                ),
                child: Icon(icon, color: tint, size: AppTokens.iconSize.lg),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (primaryLabel != null || secondaryLabel != null) ...[
            SizedBox(height: spacing.lg),
            Row(
              children: [
                if (primaryLabel != null)
                  Expanded(
                    child: PrimaryButton(
                      label: primaryLabel!,
                      onPressed: onPrimary,
                      minHeight: AppTokens.componentSize.buttonSm,
                    ),
                  ),
                if (primaryLabel != null && secondaryLabel != null)
                  SizedBox(width: spacing.md),
                if (secondaryLabel != null)
                  Expanded(
                    child: SecondaryButton(
                      label: secondaryLabel!,
                      onPressed: onSecondary,
                      minHeight: AppTokens.componentSize.buttonSm,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Info banner for inline notices.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.action,
    this.variant = InfoBannerVariant.info,
  });

  final String message;
  final IconData icon;
  final Widget? action;
  final InfoBannerVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    final Color tint;
    switch (variant) {
      case InfoBannerVariant.info:
        tint = colors.primary;
        break;
      case InfoBannerVariant.warning:
        tint = colors.secondary;
        break;
      case InfoBannerVariant.error:
        tint = colors.error;
        break;
      case InfoBannerVariant.success:
        tint = colors.tertiary;
        break;
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppLayout.contentMaxWidth),
      child: Container(
        padding: spacing.edgeInsetsSymmetric(
          horizontal: spacing.lg,
          vertical: spacing.md,
        ),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: isDark ? AppOpacity.statusBg : AppOpacity.dim),
          borderRadius: AppTokens.radius.lg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: spacing.edgeInsetsAll(spacing.sm),
              decoration: BoxDecoration(
                color: tint.withValues(alpha: isDark ? AppOpacity.ghost : AppOpacity.statusBg),
                borderRadius: AppTokens.radius.sm,
              ),
              child: Icon(icon, color: tint, size: AppTokens.iconSize.sm),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: AppTokens.fontWeight.medium,
                ),
              ),
            ),
            if (action != null) ...[
              SizedBox(width: spacing.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Variants for InfoBanner styling.
enum InfoBannerVariant {
  info,
  warning,
  error,
  success,
}
