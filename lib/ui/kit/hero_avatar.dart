import 'package:flutter/material.dart';

/// Rounded avatar used in the dashboard and top-level screens.
class HeroAvatar extends StatelessWidget {
  const HeroAvatar({
    super.key,
    required this.fallbackLetter,
    this.avatarUrl,
    this.onTap,
    this.radius = 24,
  });

  final String fallbackLetter;
  final String? avatarUrl;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = avatarUrl != null && avatarUrl!.isNotEmpty;
    final diameter = radius * 2;
    final decoration = BoxDecoration(
      shape: BoxShape.circle,
      gradient: hasImage
          ? null
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF95BAFF),
                Color(0xFF6FB7FF),
              ],
            ),
      color:
          hasImage ? theme.colorScheme.primary.withValues(alpha: 0.12) : null,
      image: hasImage
          ? DecorationImage(
              image: NetworkImage(avatarUrl!),
              fit: BoxFit.cover,
            )
          : null,
      border: Border.all(
        color: theme.colorScheme.primary.withValues(alpha: 0.45),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.primary.withValues(alpha: 0.16),
          blurRadius: 20,
          offset: const Offset(0, 12),
        ),
      ],
    );

    final avatar = Container(
      height: diameter,
      width: diameter,
      decoration: decoration,
      alignment: Alignment.center,
      child: hasImage
          ? null
          : Text(
              fallbackLetter,
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: radius,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
    );

    if (onTap == null) return avatar;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: avatar,
      ),
    );
  }
}
