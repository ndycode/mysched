import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A reusable error banner for displaying form-level error messages.
///
/// Used across auth pages and forms for consistent error display.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
  });

  /// The error message to display.
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.lg),
      decoration: BoxDecoration(
        color: palette.danger.withValues(alpha: AppOpacity.dim),
        borderRadius: AppTokens.radius.md,
        border: Border.all(
          color: palette.danger.withValues(alpha: AppOpacity.ghost),
          width: AppTokens.componentSize.dividerThin,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: palette.danger,
            size: AppTokens.iconSize.md,
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTokens.typography.bodySecondary.copyWith(
                color: palette.danger,
                fontWeight: AppTokens.fontWeight.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
