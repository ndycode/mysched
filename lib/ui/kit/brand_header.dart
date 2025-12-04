import 'package:flutter/material.dart';

import '../../app/constants.dart';
import '../theme/tokens.dart';
import 'hero_avatar.dart';
import 'pressable_scale.dart';
import 'skeletons.dart';

/// Displays the centered MySched brand title with an account avatar button.
class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    this.title = AppConstants.appName,
    this.name,
    this.email,
    this.avatarUrl,
    this.fallbackLetter,
    this.onAccountTap,
    this.textStyle,
    this.height = 56,
    this.showChevron = true,
    this.leading,
    this.trailing,
    this.avatarRadius = 24,
  });

  final String title;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final String? fallbackLetter;
  final VoidCallback? onAccountTap;
  final TextStyle? textStyle;
  final double height;
  final bool showChevron;
  final Widget? leading;
  final Widget? trailing;
  final double avatarRadius;

  String _initial() {
    final prefer = fallbackLetter?.trim();
    if (prefer != null && prefer.isNotEmpty) {
      return prefer.substring(0, 1).toUpperCase();
    }
    String base;
    if (name != null && name!.trim().isNotEmpty) {
      base = name!.trim().split(' ').first;
    } else if (email != null && email!.trim().isNotEmpty) {
      base = email!.trim().split('@').first;
    } else {
      base = 'M';
    }
    final trimmed = base.trim();
    if (trimmed.isEmpty) return 'M';
    return trimmed.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = textStyle ??
        theme.textTheme.titleLarge?.copyWith(
          fontFamily: 'SFProRounded',
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
          fontSize: AppTokens.typography.title.fontSize,
        ) ??
        TextStyle(
          fontFamily: 'SFProRounded',
          fontWeight: FontWeight.w700,
          fontSize: AppTokens.typography.title.fontSize,
          color: theme.colorScheme.primary,
        );

    final trailingWidget = trailing ??
        (onAccountTap == null
            ? null
            : Material(
                color: Colors.transparent,
                child: PressableScale(
                  onTap: onAccountTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HeroAvatar(
                          fallbackLetter: _initial(),
                          avatarUrl: avatarUrl,
                          radius: avatarRadius,
                        ),
                        if (showChevron) ...[
                          SizedBox(width: AppTokens.spacing.xs),
                          Icon(
                            Icons.expand_more_rounded,
                            size: 24,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ));

    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (leading != null)
            Align(
              alignment: Alignment.centerLeft,
              child: leading!,
            ),
          Text(title, style: style),
          if (trailingWidget != null)
            Align(
              alignment: Alignment.centerRight,
              child: trailingWidget,
            ),
        ],
      ),
    );
  }
}

/// Preconfigured variant used by primary screens for consistent spacing.
class ScreenBrandHeader extends StatelessWidget {
  const ScreenBrandHeader({
    super.key,
    this.name,
    this.email,
    this.avatarUrl,
    this.fallbackLetter,
    this.onAccountTap,
    this.showChevron = false,
    this.leading,
    this.trailing,
    this.loading = false,
    this.animateSwap = true,
    this.animationDuration = const Duration(milliseconds: 220),
    this.showSkeletonAvatar = true,
    this.height,
    this.avatarRadius,
    this.textStyle,
  });

  final String? name;
  final String? email;
  final String? avatarUrl;
  final String? fallbackLetter;
  final VoidCallback? onAccountTap;
  final bool showChevron;
  final Widget? leading;
  final Widget? trailing;
  final bool loading;
  final bool animateSwap;
  final Duration animationDuration;
  final bool showSkeletonAvatar;
  final double? height;
  final double? avatarRadius;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ready = BrandHeader(
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      fallbackLetter: fallbackLetter,
      onAccountTap: onAccountTap,
      showChevron: showChevron,
      leading: leading,
      trailing: trailing,
      height: height ?? 52,
      avatarRadius: avatarRadius ?? 20,
      textStyle: textStyle ??
          AppTokens.typography.title.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w700,
          ),
    );

    if (!animateSwap && !loading) {
      return ready;
    }

    final Widget current = loading
        ? ScreenBrandHeaderSkeleton(
            key: const ValueKey('screen_brand_header_skeleton'),
            showAvatar: showSkeletonAvatar,
          )
        : KeyedSubtree(
            key: const ValueKey('screen_brand_header_ready'),
            child: ready,
          );

    if (!animateSwap) {
      return current;
    }

    return AnimatedSwitcher(
      duration: animationDuration,
      child: current,
    );
  }
}

/// Lightweight placeholder used while profile data hydrates.
class ScreenBrandHeaderSkeleton extends StatelessWidget {
  const ScreenBrandHeaderSkeleton({
    super.key,
    this.showAvatar = true,
  });

  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBlock(height: 20, width: 140),
                SizedBox(height: AppTokens.spacing.sm),
                const SkeletonBlock(height: 14, width: 200),
              ],
            ),
          ),
          if (showAvatar) ...[
            SizedBox(width: spacing.md),
            const SkeletonCircle(size: 40),
          ],
        ],
      ),
    );
  }
}
