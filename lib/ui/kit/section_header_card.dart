import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A unified section header card for day groups and categories.
/// 
/// Used in schedules (Mon, Tue, Wed...) and reminders (Today, Tomorrow, This Week)
/// to display consistent section headers with icon, label, and count.
class SectionHeaderCard extends StatelessWidget {
  const SectionHeaderCard({
    super.key,
    required this.label,
    required this.icon,
    required this.count,
    this.countSuffix,
    this.tint,
    this.onTap,
  });

  /// Section title (e.g., "Monday", "Today")
  final String label;

  /// Icon to display
  final IconData icon;

  /// Item count for this section
  final int count;

  /// Suffix after count (e.g., "classes", "reminders")
  final String? countSuffix;

  /// Optional accent color (defaults to primary)
  final Color? tint;

  /// Optional tap handler
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final accent = tint ?? colors.primary;

    final countText = countSuffix != null
        ? '$count ${count == 1 ? countSuffix!.replaceAll(RegExp(r'e?s$'), '') : countSuffix}'
        : count.toString();

    return Container(
      padding: spacing.edgeInsetsAll(spacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: AppOpacity.dim),
            accent.withValues(alpha: AppOpacity.veryFaint),
          ],
        ),
        borderRadius: AppTokens.radius.md,
        border: Border.all(
          color: accent.withValues(alpha: AppOpacity.accent),
          width: AppTokens.componentSize.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: spacing.edgeInsetsAll(spacing.sm),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: AppOpacity.medium),
              borderRadius: AppTokens.radius.sm,
            ),
            child: Icon(
              icon,
              size: AppTokens.iconSize.sm,
              color: accent,
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTokens.typography.subtitle.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: AppLetterSpacing.snug,
                color: colors.onSurface,
              ),
            ),
          ),
          Container(
            padding: spacing.edgeInsetsSymmetric(
              horizontal: spacing.sm + 2,
              vertical: spacing.xs + 1,
            ),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: AppOpacity.overlay),
              borderRadius: AppTokens.radius.sm,
            ),
            child: Text(
              countText,
              style: AppTokens.typography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
