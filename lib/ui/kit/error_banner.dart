import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'responsive_provider.dart';

/// A reusable error banner for displaying form-level error messages.
///
/// Used across auth pages and forms for consistent error display.
/// Automatically adapts to screen size via [ResponsiveProvider].
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

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return Container(
      padding: spacing.edgeInsetsAll(spacing.lg * spacingScale),
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
            size: AppTokens.iconSize.md * scale,
          ),
          SizedBox(width: spacing.md * spacingScale),
          Expanded(
            child: Text(
              message,
              style: AppTokens.typography.bodyScaled(scale).copyWith(
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

