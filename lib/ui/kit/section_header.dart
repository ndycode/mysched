import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A unified section header for form sections.
///
/// Used in add_class, add_reminder, and other forms to display
/// consistent section headers with title and optional subtitle.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: AppTokens.fontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: AppTokens.spacing.xs),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
