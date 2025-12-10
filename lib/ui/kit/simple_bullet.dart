import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'responsive_provider.dart';

/// A simple bullet point item for lists.
///
/// Used in privacy, about, and other info screens for
/// bulleted text items.
/// Automatically adapts to screen size via [ResponsiveProvider].
class SimpleBullet extends StatelessWidget {
  const SimpleBullet({
    super.key,
    required this.text,
  });

  /// The bullet text content
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = AppTokens.spacing;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs * spacingScale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: spacing.xs * spacingScale),
          Icon(
            Icons.circle,
            size: AppTokens.iconSize.bullet * scale,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: spacing.sm * spacingScale),
          Expanded(
            child: Text(text, style: AppTokens.typography.bodyScaled(scale)),
          ),
        ],
      ),
    );
  }
}

