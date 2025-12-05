import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/tokens.dart';

/// Lightweight animated block used to mimic loading content with shimmer effect.
class SkeletonBlock extends StatefulWidget {
  const SkeletonBlock({
    super.key,
    required this.height,
    this.width,
    this.borderRadius,
  });

  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  @override
  State<SkeletonBlock> createState() => _SkeletonBlockState();
}

class _SkeletonBlockState extends State<SkeletonBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotionSystem.long + AppMotionSystem.deliberate + AppMotionSystem.fast, // ~1400ms
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle)
        : colors.surfaceContainerHighest.withValues(alpha: AppOpacity.skeletonLight);
    final highlight = isDark
        ? colors.onSurfaceVariant.withValues(alpha: AppOpacity.border)
        : colors.onSurfaceVariant.withValues(alpha: AppOpacity.highlight);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        final color = Color.lerp(base, highlight, t)!;
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: color,
            borderRadius: widget.borderRadius ??
                BorderRadius.circular(widget.height * 0.65),
          ),
        );
      },
    );
  }
}

/// Circular variant that pairs well with avatars or icon placeholders.
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({
    super.key,
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SkeletonBlock(
      height: size,
      width: size,
      borderRadius: BorderRadius.circular(size),
    );
  }
}

/// Skeleton placeholder for a standard card layout.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    this.height,
    this.showAvatar = false,
    this.lineCount = 3,
  });

  final double? height;
  final bool showAvatar;
  final int lineCount;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      padding: spacing.edgeInsetsAll(spacing.xl),
      decoration: BoxDecoration(
        color: isDark
            ? colors.surfaceContainerHigh.withValues(alpha: AppOpacity.subtle)
            : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: colors.outline.withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.dim),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (showAvatar) ...[
                const SkeletonCircle(size: 48),
                SizedBox(width: spacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBlock(
                      height: 18,
                      width: showAvatar ? 140 : 180,
                      borderRadius: AppTokens.radius.sm,
                    ),
                    SizedBox(height: spacing.sm),
                    SkeletonBlock(
                      height: 14,
                      width: showAvatar ? 100 : 120,
                      borderRadius: AppTokens.radius.sm,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (lineCount > 0) ...[
            SizedBox(height: spacing.lg),
            for (int i = 0; i < lineCount; i++) ...[
              SkeletonBlock(
                height: 14,
                width: i == lineCount - 1 ? 200 : double.infinity,
                borderRadius: AppTokens.radius.sm,
              ),
              if (i < lineCount - 1) SizedBox(height: spacing.sm),
            ],
          ],
        ],
      ),
    );
  }
}

/// Skeleton for a dashboard summary card with metrics.
class SkeletonDashboardCard extends StatelessWidget {
  const SkeletonDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.xl),
      decoration: BoxDecoration(
        color: isDark
            ? colors.surfaceContainerHigh.withValues(alpha: AppOpacity.subtle)
            : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: colors.outline.withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.dim),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting skeleton
          SkeletonBlock(
            height: 24,
            width: 220,
            borderRadius: AppTokens.radius.sm,
          ),
          SizedBox(height: spacing.sm),
          SkeletonBlock(
            height: 16,
            width: 140,
            borderRadius: AppTokens.radius.sm,
          ),
          SizedBox(height: spacing.xl),

          // Hero tile skeleton
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: AppTokens.radius.lg,
            ),
            padding: spacing.edgeInsetsAll(spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(
                  height: 24,
                  width: 80,
                  borderRadius: AppTokens.radius.pill,
                ),
                SizedBox(height: spacing.md),
                SkeletonBlock(
                  height: 20,
                  width: 180,
                  borderRadius: AppTokens.radius.sm,
                ),
                SizedBox(height: spacing.sm),
                SkeletonBlock(
                  height: 16,
                  width: 140,
                  borderRadius: AppTokens.radius.sm,
                ),
                const Spacer(),
                Row(
                  children: [
                    const SkeletonCircle(size: 28),
                    SizedBox(width: spacing.sm),
                    SkeletonBlock(
                      height: 14,
                      width: 100,
                      borderRadius: AppTokens.radius.sm,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.lg),

          // Metrics row skeleton
          Row(
            children: [
              Expanded(child: _SkeletonMetric()),
              SizedBox(width: spacing.md),
              Expanded(child: _SkeletonMetric()),
              SizedBox(width: spacing.md),
              Expanded(child: _SkeletonMetric()),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonMetric extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.md),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: isDark ? AppOpacity.overlay : AppOpacity.veryFaint),
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: colors.primary.withValues(alpha: isDark ? AppOpacity.accent : AppOpacity.dim),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonCircle(size: 32),
          SizedBox(height: spacing.md),
          SkeletonBlock(
            height: 22,
            width: 48,
            borderRadius: AppTokens.radius.sm,
          ),
          SizedBox(height: spacing.xs),
          SkeletonBlock(
            height: 14,
            width: 60,
            borderRadius: AppTokens.radius.sm,
          ),
        ],
      ),
    );
  }
}

/// Skeleton for a list item / tile.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({
    super.key,
    this.showLeading = true,
    this.showTrailing = false,
  });

  final bool showLeading;
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.lg,
        vertical: spacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withValues(alpha: isDark ? AppOpacity.divider : 0.6),
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: colors.outline.withValues(alpha: isDark ? AppOpacity.overlay : AppOpacity.highlight),
        ),
      ),
      child: Row(
        children: [
          if (showLeading) ...[
            const SkeletonCircle(size: 44),
            SizedBox(width: spacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(
                  height: 16,
                  width: 160,
                  borderRadius: AppTokens.radius.sm,
                ),
                SizedBox(height: spacing.sm),
                SkeletonBlock(
                  height: 14,
                  width: 100,
                  borderRadius: AppTokens.radius.sm,
                ),
              ],
            ),
          ),
          if (showTrailing) ...[
            SizedBox(width: spacing.md),
            SkeletonBlock(
              height: 28,
              width: 70,
              borderRadius: AppTokens.radius.pill,
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton for schedule/reminder list with multiple items.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 4,
    this.showHeader = true,
  });

  final int itemCount;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBlock(
                height: 18,
                width: 120,
                borderRadius: AppTokens.radius.sm,
              ),
              SkeletonBlock(
                height: 14,
                width: 70,
                borderRadius: AppTokens.radius.sm,
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
        ],
        for (int i = 0; i < itemCount; i++) ...[
          const SkeletonListTile(showTrailing: true),
          if (i < itemCount - 1) SizedBox(height: spacing.md),
        ],
      ],
    );
  }
}
