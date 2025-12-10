import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'responsive_provider.dart';

/// A unified section header for form sections.
///
/// Used in add_class, add_reminder, and other forms to display
/// consistent section headers with title and optional subtitle.
/// Automatically adapts to screen size via [ResponsiveProvider].
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  /// Section title
  final String title;

  /// Optional description below title
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTokens.typography.subtitleScaled(scale).copyWith(
            fontWeight: AppTokens.fontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: AppTokens.spacing.xs * spacingScale),
          Text(
            subtitle!,
            style: AppTokens.typography.bodyScaled(scale).copyWith(
              color: palette.muted,
            ),
          ),
        ],
      ],
    );
  }
}
