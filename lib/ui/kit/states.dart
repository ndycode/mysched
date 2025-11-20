import 'package:flutter/material.dart';

import '../../services/analytics_service.dart';
import '../theme/tokens.dart';
import 'buttons.dart';
import 'containers.dart';

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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    AnalyticsService.instance.logEvent(
      'ui_state_empty',
      params: {'screen': ModalRoute.of(context)?.settings.name},
    );

    return _StateShell(
      icon: icon,
      iconColor: colors.primary,
      title: title,
      message: message,
      footer: actionLabel == null
          ? null
          : PrimaryButton(
              label: actionLabel!,
              onPressed: onAction == null
                  ? null
                  : () {
                      AnalyticsService.instance.logEvent(
                        'ui_tap_empty_state_action',
                        params: {'label': actionLabel},
                      );
                      onAction?.call();
                    },
            ),
    );
  }
}

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
    final colors = Theme.of(context).colorScheme;

    AnalyticsService.instance.logEvent(
      'ui_state_error',
      params: {'screen': ModalRoute.of(context)?.settings.name},
    );

    return _StateShell(
      icon: icon,
      iconColor: colors.error,
      title: title,
      message: message,
      footer: onRetry == null
          ? null
          : SecondaryButton(
              label: retryLabel,
              onPressed: () {
                AnalyticsService.instance.logEvent(
                  'ui_tap_error_state_retry',
                  params: {'label': retryLabel},
                );
                onRetry?.call();
              },
            ),
    );
  }
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.action,
  });

  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: CardX(
        padding: AppTokens.spacing.edgeInsetsSymmetric(
          horizontal: AppTokens.spacing.lg,
          vertical: AppTokens.spacing.md,
        ),
        backgroundColor: colors.primaryContainer.withValues(alpha: 0.35),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: colors.primary, size: 20),
            SizedBox(width: AppTokens.spacing.md),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.onSurface),
              ),
            ),
            if (action != null) ...[
              SizedBox(width: AppTokens.spacing.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class _StateShell extends StatelessWidget {
  const _StateShell({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.footer,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(44),
              ),
              child: Icon(icon, color: iconColor, size: 36),
            ),
            SizedBox(height: AppTokens.spacing.xl),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTokens.spacing.md),
            Padding(
              padding: AppTokens.spacing.edgeInsetsSymmetric(
                horizontal: AppTokens.spacing.xl,
              ),
              child: Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            if (footer != null) ...[
              SizedBox(height: AppTokens.spacing.xl),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
