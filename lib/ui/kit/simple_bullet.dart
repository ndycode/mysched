import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A simple bullet point item for lists.
///
/// Used in privacy, about, and other info screens for
/// bulleted text items.
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
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: spacing.xs),
          Icon(
            Icons.circle,
            size: AppTokens.iconSize.sm - 8,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
