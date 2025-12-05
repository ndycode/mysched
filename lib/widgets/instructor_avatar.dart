import 'package:flutter/material.dart';

import '../ui/theme/tokens.dart';
import '../utils/instructor_utils.dart';

class InstructorAvatar extends StatelessWidget {
  const InstructorAvatar({
    super.key,
    required this.name,
    required this.tint,
    this.avatarUrl,
    this.inverse = false,
    this.size = 28,
    this.borderWidth = 1,
  });

  final String name;
  final String? avatarUrl;
  final Color tint;
  final bool inverse;
  final double size;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final initials = instructorInitials(name);

    final background = inverse
        ? colors.onPrimary.withValues(alpha: AppOpacity.darkTint)
        : tint.withValues(alpha: AppOpacity.statusBg);
    final borderColor = (inverse ? colors.onPrimary : tint)
        .withValues(alpha: inverse ? AppOpacity.accent : AppOpacity.border);

    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: inverse ? colors.onPrimary : tint.withValues(alpha: AppOpacity.prominent),
        ),
      ),
    );

    final url = avatarUrl?.trim();
    if (url == null || url.isEmpty) {
      return fallback;
    }

    // Calculate cache dimensions based on device pixel ratio
    final cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).toInt();

    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: cacheSize,
        cacheHeight: cacheSize,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}
