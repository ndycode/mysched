import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A shared instructor row widget for displaying instructor info in entity tiles.
/// 
/// Used as bottomContent in EntityTile for schedule rows across dashboard and schedules screens.
class InstructorRow extends StatelessWidget {
  const InstructorRow({
    super.key,
    required this.name,
    this.avatarUrl,
    this.avatarSize,
    this.showSectionIcon = false,
  });

  /// Instructor name
  final String name;

  /// Optional avatar URL
  final String? avatarUrl;

  /// Custom avatar size (defaults to badgeLg = 24)
  final double? avatarSize;

  /// Show section icon instead of avatar (for instructors viewing their own classes)
  final bool showSectionIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final size = avatarSize ?? AppTokens.componentSize.badgeLg;

    return Row(
      children: [
        // Show section icon for instructors instead of avatar
        if (showSectionIcon)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: AppOpacity.medium),
              borderRadius: BorderRadius.circular(AppTokens.radius.sm.topLeft.x),
            ),
            child: Icon(
              Icons.class_outlined,
              size: size * 0.6,
              color: colors.primary,
            ),
          )
        else if (avatarUrl != null && avatarUrl!.isNotEmpty)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(avatarUrl!),
                fit: BoxFit.cover,
              ),
            ),
          )
        else
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: AppOpacity.medium),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: AppTokens.typography.caption.copyWith(
                  fontWeight: AppTokens.fontWeight.semiBold,
                  color: colors.primary,
                ),
              ),
            ),
          ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Text(
            name,
            style: AppTokens.typography.caption.copyWith(
              fontWeight: AppTokens.fontWeight.medium,
              color: palette.muted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
