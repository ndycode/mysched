import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'buttons.dart';

/// A dismissable hint bubble for onboarding tips and guidance.
class HintBubble extends StatelessWidget {
  const HintBubble({
    super.key,
    required this.message,
    required this.onDismiss,
    this.dismissLabel = 'Got it',
  });

  final String message;
  final VoidCallback onDismiss;
  final String dismissLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTokens.spacing.xxl),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: isDark ? AppOpacity.prominent : AppOpacity.dense),
          borderRadius: AppTokens.radius.lg,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: AppOpacity.ghost),
          ),
          boxShadow: [
            AppTokens.shadow.bubble(
              colors.shadow.withValues(alpha: isDark ? AppOpacity.ghost : AppOpacity.statusBg),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.spacing.xl,
            vertical: AppTokens.spacing.lg + AppTokens.spacing.micro,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: AppTokens.fontWeight.semiBold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTokens.spacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: TertiaryButton(
                  label: dismissLabel,
                  onPressed: onDismiss,
                  expanded: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
