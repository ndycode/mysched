import 'package:flutter/material.dart';

import '../theme/tokens.dart';

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
    final colors = theme.brightness == Brightness.dark
        ? AppTokens.darkColors
        : AppTokens.lightColors;
    final decoration = BoxDecoration(
      shape: BoxShape.circle,
      gradient: hasImage
          ? null
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.avatarGradientStart,
                colors.avatarGradientEnd,
              ],
            ),
      color:
          hasImage ? theme.colorScheme.primary.withValues(alpha: AppOpacity.overlay) : null,
      image: hasImage
          ? DecorationImage(
              image: NetworkImage(avatarUrl!),
              fit: BoxFit.cover,
            )
          : null,
      border: Border.all(
        color: theme.colorScheme.primary.withValues(alpha: AppOpacity.barrier),
        width: AppTokens.componentSize.dividerThick,
      ),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.primary.withValues(alpha: AppOpacity.statusBg),
          blurRadius: AppTokens.shadow.xl,
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
                fontFamily: AppTypography.primaryFont,
                fontSize: radius,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onPrimary,
                letterSpacing: AppLetterSpacing.wide,
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
