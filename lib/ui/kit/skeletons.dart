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
    duration: AppMotionSystem.long +
        AppMotionSystem.deliberate +
        AppMotionSystem.fast, // ~1400ms
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
        : colors.surfaceContainerHighest
            .withValues(alpha: AppOpacity.skeletonLight);
    final highlight = isDark
        ? colors.onSurfaceVariant.withValues(alpha: AppOpacity.border)
        : colors.onSurfaceVariant.withValues(alpha: AppOpacity.highlight);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = AppMotionSystem.easeInOut.transform(_controller.value);
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
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: isDark
            ? colors.surfaceContainerHigh.withValues(alpha: AppOpacity.subtle)
            : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: colors.outline
              .withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.dim),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (showAvatar) ...[
                SkeletonCircle(size: AppTokens.componentSize.avatarXl),
                SizedBox(width: spacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBlock(
                      height: AppTokens.componentSize.skeletonTextLg,
                      width: showAvatar
                          ? AppTokens.componentSize.skeletonWidthXxl
                          : AppTokens.componentSize.skeletonWidthFull,
                      borderRadius: AppTokens.radius.sm,
                    ),
                    SizedBox(height: spacing.sm),
                    SkeletonBlock(
                      height: AppTokens.componentSize.skeletonTextSm,
                      width: showAvatar
                          ? AppTokens.componentSize.skeletonWidthLg
                          : AppTokens.componentSize.skeletonWidthXl,
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
                height: AppTokens.componentSize.skeletonTextSm,
                width: i == lineCount - 1
                    ? AppTokens.componentSize.skeletonWidthHero
                    : double.infinity,
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

/// Skeleton for summary cards (Schedules/Reminders overview).
/// Matches the structure: title row, hero tile, metrics row, buttons row.
class SkeletonSummaryCard extends StatelessWidget {
  const SkeletonSummaryCard({
    super.key,
    this.metricCount = 3,
  });

  final int metricCount;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: colors.outline
              .withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.dim),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          SkeletonBlock(
            height: AppTokens.componentSize.skeletonTextLg,
            width: AppTokens.componentSize.skeletonWidthXl,
            borderRadius: AppTokens.radius.sm,
          ),
          SizedBox(height: spacing.xl),

          // Hero tile skeleton
          Container(
            height: AppTokens.componentSize.previewSmd,
            decoration: BoxDecoration(
              color: colors.primary.withValues(
                  alpha: isDark ? AppOpacity.medium : AppOpacity.highlight),
              borderRadius: AppTokens.radius.lg,
            ),
            padding: spacing.edgeInsetsAll(spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(
                  height: AppTokens.componentSize.skeletonTextSm,
                  width: AppTokens.componentSize.skeletonWidthMd,
                  borderRadius: AppTokens.radius.pill,
                ),
                SizedBox(height: spacing.md),
                SkeletonBlock(
                  height: AppTokens.componentSize.skeletonTextLg,
                  width: AppTokens.componentSize.skeletonWidthFull,
                  borderRadius: AppTokens.radius.sm,
                ),
                SizedBox(height: spacing.sm),
                SkeletonBlock(
                  height: AppTokens.componentSize.skeletonTextMd,
                  width: AppTokens.componentSize.skeletonWidthXl,
                  borderRadius: AppTokens.radius.sm,
                ),
                const Spacer(),
                Row(
                  children: [
                    SkeletonCircle(size: AppTokens.componentSize.avatarSmDense),
                    SizedBox(width: spacing.sm),
                    SkeletonBlock(
                      height: AppTokens.componentSize.skeletonTextSm,
                      width: AppTokens.componentSize.skeletonWidthLg,
                      borderRadius: AppTokens.radius.sm,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.xl),

          // Metrics row skeleton
          Row(
            children: [
              for (int i = 0; i < metricCount; i++) ...[
                if (i > 0) SizedBox(width: spacing.md),
                Expanded(child: _SkeletonMetric()),
              ],
            ],
          ),
          SizedBox(height: spacing.xl),

          // Buttons row skeleton
          Row(
            children: [
              Expanded(
                child: SkeletonBlock(
                  height: AppTokens.componentSize.buttonMd,
                  borderRadius: AppTokens.radius.pill,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: SkeletonBlock(
                  height: AppTokens.componentSize.buttonMd,
                  borderRadius: AppTokens.radius.pill,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton for a list card section (e.g. class list, reminder list).
/// Matches the structure: header with icon + title, filter chips, list items.
class SkeletonListCard extends StatelessWidget {
  const SkeletonListCard({
    super.key,
    this.itemCount = 3,
    this.showFilterChips = true,
  });

  final int itemCount;
  final bool showFilterChips;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: colors.outline
              .withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.dim),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SkeletonBlock(
                height: AppTokens.componentSize.avatarXl,
                width: AppTokens.componentSize.avatarXl,
                borderRadius: AppTokens.radius.md,
              ),
              SizedBox(width: spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBlock(
                      height: AppTokens.componentSize.skeletonTextLg,
                      width: AppTokens.componentSize.skeletonWidthXl,
                      borderRadius: AppTokens.radius.sm,
                    ),
                    SizedBox(height: spacing.sm),
                    SkeletonBlock(
                      height: AppTokens.componentSize.skeletonTextSm,
                      width: AppTokens.componentSize.skeletonWidthLg,
                      borderRadius: AppTokens.radius.sm,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          // Description skeleton
          SkeletonBlock(
            height: AppTokens.componentSize.skeletonTextSm,
            width: AppTokens.componentSize.skeletonWidthHero,
            borderRadius: AppTokens.radius.sm,
          ),
          if (showFilterChips) ...[
            SizedBox(height: spacing.xl),
            // Filter chips row
            Row(
              children: [
                SkeletonBlock(
                  height: AppTokens.componentSize.buttonSm,
                  width: AppTokens.componentSize.skeletonWidthSm,
                  borderRadius: AppTokens.radius.pill,
                ),
                SizedBox(width: spacing.sm),
                SkeletonBlock(
                  height: AppTokens.componentSize.buttonSm,
                  width: AppTokens.componentSize.skeletonWidthMd,
                  borderRadius: AppTokens.radius.pill,
                ),
                SizedBox(width: spacing.sm),
                SkeletonBlock(
                  height: AppTokens.componentSize.buttonSm,
                  width: AppTokens.componentSize.skeletonWidthXs,
                  borderRadius: AppTokens.radius.pill,
                ),
              ],
            ),
          ],
          SizedBox(height: spacing.lg),
          // List items
          for (int i = 0; i < itemCount; i++) ...[
            const SkeletonListTile(showTrailing: true),
            if (i < itemCount - 1) SizedBox(height: spacing.md),
          ],
        ],
      ),
    );
  }
}

/// Skeleton for a settings toggle row (icon + title/description + toggle).
class _SkeletonToggleRow extends StatelessWidget {
  const _SkeletonToggleRow();

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;

    return Row(
      children: [
        // Icon placeholder
        SkeletonBlock(
          height: AppTokens.componentSize.avatarSm,
          width: AppTokens.componentSize.avatarSm,
          borderRadius: AppTokens.radius.sm,
        ),
        SizedBox(width: spacing.lg),
        // Title and description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBlock(
                height: AppTokens.componentSize.skeletonTextMd,
                width: AppTokens.componentSize.skeletonWidthXl,
                borderRadius: AppTokens.radius.sm,
              ),
              SizedBox(height: spacing.xs),
              SkeletonBlock(
                height: AppTokens.componentSize.skeletonTextSm,
                width: AppTokens.componentSize.skeletonWidthHero,
                borderRadius: AppTokens.radius.sm,
              ),
            ],
          ),
        ),
        SizedBox(width: spacing.md),
        // Toggle placeholder
        SkeletonBlock(
          height: AppTokens.componentSize.badgeLg,
          width: AppTokens.componentSize.skeletonWidthSm,
          borderRadius: AppTokens.radius.pill,
        ),
      ],
    );
  }
}

/// Skeleton for settings cards with toggle rows.
class SkeletonSettingsCard extends StatelessWidget {
  const SkeletonSettingsCard({
    super.key,
    this.rowCount = 4,
  });

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: colors.outline
              .withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.dim),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < rowCount; i++) ...[
            const _SkeletonToggleRow(),
            if (i < rowCount - 1) SizedBox(height: spacing.lg),
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
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: isDark
            ? colors.surfaceContainerHigh.withValues(alpha: AppOpacity.subtle)
            : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: colors.outline
              .withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.dim),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting skeleton
          SkeletonBlock(
            height: AppTokens.componentSize.skeletonTextLg,
            width: AppTokens.componentSize.skeletonWidthMax,
            borderRadius: AppTokens.radius.sm,
          ),
          SizedBox(height: spacing.xl),

          // Hero tile skeleton
          Container(
            height: AppTokens.componentSize.previewSmd,
            decoration: BoxDecoration(
              color: colors.primary.withValues(
                  alpha: isDark ? AppOpacity.medium : AppOpacity.highlight),
              borderRadius: AppTokens.radius.lg,
            ),
            padding: spacing.edgeInsetsAll(spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(
                  height: AppTokens.componentSize.skeletonTextSm,
                  width: AppTokens.componentSize.skeletonWidthMd,
                  borderRadius: AppTokens.radius.pill,
                ),
                SizedBox(height: spacing.md),
                SkeletonBlock(
                  height: AppTokens.componentSize.skeletonTextLg,
                  width: AppTokens.componentSize.skeletonWidthFull,
                  borderRadius: AppTokens.radius.sm,
                ),
                SizedBox(height: spacing.sm),
                SkeletonBlock(
                  height: AppTokens.componentSize.skeletonTextMd,
                  width: AppTokens.componentSize.skeletonWidthXl,
                  borderRadius: AppTokens.radius.sm,
                ),
                const Spacer(),
                Row(
                  children: [
                    SkeletonCircle(size: AppTokens.componentSize.avatarSmDense),
                    SizedBox(width: spacing.sm),
                    SkeletonBlock(
                      height: AppTokens.componentSize.skeletonTextSm,
                      width: AppTokens.componentSize.skeletonWidthLg,
                      borderRadius: AppTokens.radius.sm,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.xl),

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
          SizedBox(height: spacing.xl),

          // Buttons row skeleton
          Row(
            children: [
              Expanded(
                child: SkeletonBlock(
                  height: AppTokens.componentSize.buttonMd,
                  borderRadius: AppTokens.radius.pill,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: SkeletonBlock(
                  height: AppTokens.componentSize.buttonMd,
                  borderRadius: AppTokens.radius.pill,
                ),
              ),
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
      padding: spacing.edgeInsetsAll(spacing.mdLg),
      decoration: BoxDecoration(
        color: colors.primary.withValues(
            alpha: isDark ? AppOpacity.overlay : AppOpacity.veryFaint),
        borderRadius: AppTokens.radius.md,
        border: Border.all(
          color: colors.primary.withValues(
              alpha: isDark ? AppOpacity.accent : AppOpacity.medium),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Square icon container (matches MetricChip)
          SkeletonBlock(
            height: AppTokens.componentSize.avatarSm,
            width: AppTokens.componentSize.avatarSm,
            borderRadius: AppTokens.radius.sm,
          ),
          SizedBox(height: spacing.smMd),
          SkeletonBlock(
            height: AppTokens.componentSize.skeletonTextXl,
            width: AppTokens.componentSize.skeletonWidthXxs,
            borderRadius: AppTokens.radius.sm,
          ),
          SizedBox(height: spacing.xs),
          SkeletonBlock(
            height: AppTokens.componentSize.skeletonTextSm,
            width: AppTokens.componentSize.skeletonWidthSm,
            borderRadius: AppTokens.radius.sm,
          ),
        ],
      ),
    );
  }
}

/// Skeleton for the dashboard schedule section.
class SkeletonScheduleSection extends StatelessWidget {
  const SkeletonScheduleSection({
    super.key,
    this.itemCount = 3,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: colors.outline
              .withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.dim),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SkeletonBlock(
                height: AppTokens.componentSize.avatarXl,
                width: AppTokens.componentSize.avatarXl,
                borderRadius: AppTokens.radius.md,
              ),
              SizedBox(width: spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBlock(
                      height: AppTokens.componentSize.skeletonTextLg,
                      width: AppTokens.componentSize.skeletonWidthXl,
                      borderRadius: AppTokens.radius.sm,
                    ),
                    SizedBox(height: spacing.sm),
                    SkeletonBlock(
                      height: AppTokens.componentSize.skeletonTextSm,
                      width: AppTokens.componentSize.skeletonWidthLg,
                      borderRadius: AppTokens.radius.sm,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          // Description skeleton
          SkeletonBlock(
            height: AppTokens.componentSize.skeletonTextSm,
            width: AppTokens.componentSize.skeletonWidthHero,
            borderRadius: AppTokens.radius.sm,
          ),
          SizedBox(height: spacing.xl),
          // Scope chips row
          Row(
            children: [
              SkeletonBlock(
                height: AppTokens.componentSize.buttonSm,
                width: AppTokens.componentSize.skeletonWidthSm,
                borderRadius: AppTokens.radius.pill,
              ),
              SizedBox(width: spacing.sm),
              SkeletonBlock(
                height: AppTokens.componentSize.buttonSm,
                width: AppTokens.componentSize.skeletonWidthMd,
                borderRadius: AppTokens.radius.pill,
              ),
              SizedBox(width: spacing.sm),
              SkeletonBlock(
                height: AppTokens.componentSize.buttonSm,
                width: AppTokens.componentSize.skeletonWidthXs,
                borderRadius: AppTokens.radius.pill,
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          // Schedule list items
          for (int i = 0; i < itemCount; i++) ...[
            const SkeletonListTile(showTrailing: true),
            if (i < itemCount - 1) SizedBox(height: spacing.md),
          ],
        ],
      ),
    );
  }
}

/// Skeleton for a list item / tile (matches EntityTile structure).
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({
    super.key,
    this.showTrailing = false,
    this.showBottomRow = true,
  });

  final bool showTrailing;
  final bool showBottomRow;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.lg),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.md,
        border: Border.all(
          color: colors.outline.withValues(
              alpha: isDark ? AppOpacity.overlay : AppOpacity.subtle),
          width: AppTokens.componentSize.dividerThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with optional badge
          Row(
            children: [
              Expanded(
                child: SkeletonBlock(
                  height: AppTokens.componentSize.skeletonTextMd,
                  width: AppTokens.componentSize.skeletonWidthXl,
                  borderRadius: AppTokens.radius.sm,
                ),
              ),
              if (showTrailing) ...[
                SizedBox(width: spacing.md),
                SkeletonBlock(
                  height: AppTokens.componentSize.badgeMd,
                  width: AppTokens.componentSize.skeletonWidthSm,
                  borderRadius: AppTokens.radius.pill,
                ),
              ],
            ],
          ),
          SizedBox(height: spacing.sm),
          // Metadata row (time + location chips)
          Row(
            children: [
              SkeletonBlock(
                height: AppTokens.componentSize.skeletonTextSm,
                width: AppTokens.componentSize.skeletonWidthLg,
                borderRadius: AppTokens.radius.sm,
              ),
              SizedBox(width: spacing.md),
              SkeletonBlock(
                height: AppTokens.componentSize.skeletonTextSm,
                width: AppTokens.componentSize.skeletonWidthMd,
                borderRadius: AppTokens.radius.sm,
              ),
            ],
          ),
          if (showBottomRow) ...[
            SizedBox(height: spacing.md),
            // Instructor row (small avatar + name)
            Row(
              children: [
                SkeletonCircle(size: AppTokens.componentSize.avatarSmDense),
                SizedBox(width: spacing.sm),
                SkeletonBlock(
                  height: AppTokens.componentSize.skeletonTextSm,
                  width: AppTokens.componentSize.skeletonWidthLg,
                  borderRadius: AppTokens.radius.sm,
                ),
              ],
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
                height: AppTokens.componentSize.skeletonTextLg,
                width: AppTokens.componentSize.skeletonWidthXl,
                borderRadius: AppTokens.radius.sm,
              ),
              SkeletonBlock(
                height: AppTokens.componentSize.skeletonTextSm,
                width: AppTokens.componentSize.skeletonWidthSm,
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

/// Skeleton for a detail row (icon container + label/value column).
class _SkeletonDetailRow extends StatelessWidget {
  const _SkeletonDetailRow();

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon container (matches DetailRow)
        SkeletonBlock(
          height: AppTokens.componentSize.avatarSm,
          width: AppTokens.componentSize.avatarSm,
          borderRadius: AppTokens.radius.sm,
        ),
        SizedBox(width: spacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              SkeletonBlock(
                height: AppTokens.componentSize.skeletonTextSm,
                width: AppTokens.componentSize.skeletonWidthSm,
                borderRadius: AppTokens.radius.sm,
              ),
              SizedBox(height: spacing.xs),
              // Value
              SkeletonBlock(
                height: AppTokens.componentSize.skeletonTextMd,
                width: AppTokens.componentSize.skeletonWidthXl,
                borderRadius: AppTokens.radius.sm,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Skeleton for the class details sheet content.
/// Matches the structure: header row, status chips, details container,
/// instructor section, action buttons.
class SkeletonClassDetailsContent extends StatelessWidget {
  const SkeletonClassDetailsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header row skeleton (icon + title/subtitle + close)
        Row(
          children: [
            SkeletonBlock(
              height: AppTokens.componentSize.avatarLg,
              width: AppTokens.componentSize.avatarLg,
              borderRadius: AppTokens.radius.md,
            ),
            SizedBox(width: spacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBlock(
                    height: AppTokens.componentSize.skeletonTextLg,
                    width: AppTokens.componentSize.skeletonWidthXl,
                    borderRadius: AppTokens.radius.sm,
                  ),
                  SizedBox(height: spacing.xs),
                  SkeletonBlock(
                    height: AppTokens.componentSize.skeletonTextSm,
                    width: AppTokens.componentSize.skeletonWidthMd,
                    borderRadius: AppTokens.radius.sm,
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.md),
            SkeletonBlock(
              height: AppTokens.componentSize.buttonSm,
              width: AppTokens.componentSize.buttonSm,
              borderRadius: AppTokens.radius.sm,
            ),
          ],
        ),
        SizedBox(height: spacing.xl),

        // Status chip (single chip like "Synced class")
        SkeletonBlock(
          height: AppTokens.componentSize.badgeLg,
          width: AppTokens.componentSize.skeletonWidthLg,
          borderRadius: AppTokens.radius.pill,
        ),
        SizedBox(height: spacing.lg),

        // Main details container with 5 rows
        Container(
          padding: EdgeInsets.all(spacing.xl),
          decoration: BoxDecoration(
            color: isDark
                ? colors.surfaceContainerHighest
                    .withValues(alpha: AppOpacity.ghost)
                : colors.primary.withValues(alpha: AppOpacity.micro),
            borderRadius: AppTokens.radius.lg,
            border: Border.all(
              color: isDark
                  ? colors.outline.withValues(alpha: AppOpacity.overlay)
                  : colors.primary.withValues(alpha: AppOpacity.dim),
              width: AppTokens.componentSize.divider,
            ),
          ),
          child: Column(
            children: [
              // Schedule, Room, Units, Section, Created (5 rows)
              for (int i = 0; i < 5; i++) ...[
                const _SkeletonDetailRow(),
                if (i < 4)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: spacing.lg),
                    child: Divider(
                      height: AppTokens.componentSize.divider,
                      color: isDark
                          ? colors.outline.withValues(alpha: AppOpacity.medium)
                          : colors.primary.withValues(alpha: AppOpacity.dim),
                    ),
                  ),
              ],
            ],
          ),
        ),
        SizedBox(height: spacing.lg),

        // Instructor section skeleton (inside container)
        Container(
          padding: EdgeInsets.all(spacing.lg),
          decoration: BoxDecoration(
            color: isDark
                ? colors.surfaceContainerHighest
                    .withValues(alpha: AppOpacity.ghost)
                : colors.surface,
            borderRadius: AppTokens.radius.lg,
            border: Border.all(
              color: isDark
                  ? colors.outline.withValues(alpha: AppOpacity.overlay)
                  : colors.outlineVariant,
              width: AppTokens.componentSize.divider,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Instructor" label
              SkeletonBlock(
                height: AppTokens.componentSize.skeletonTextSm,
                width: AppTokens.componentSize.skeletonWidthMd,
                borderRadius: AppTokens.radius.sm,
              ),
              SizedBox(height: spacing.md),
              // Avatar + name row
              Row(
                children: [
                  SkeletonCircle(size: AppTokens.iconSize.xxl),
                  SizedBox(width: spacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBlock(
                          height: AppTokens.componentSize.skeletonTextMd,
                          width: AppTokens.componentSize.skeletonWidthXl,
                          borderRadius: AppTokens.radius.sm,
                        ),
                        SizedBox(height: spacing.xs),
                        SkeletonBlock(
                          height: AppTokens.componentSize.skeletonTextSm,
                          width: AppTokens.componentSize.skeletonWidthLg,
                          borderRadius: AppTokens.radius.sm,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.xl),

        // Action button (single full-width)
        SkeletonBlock(
          height: AppTokens.componentSize.buttonMd,
          borderRadius: AppTokens.radius.md,
        ),
        SizedBox(height: spacing.md),

        // Text link skeleton (centered)
        Center(
          child: SkeletonBlock(
            height: AppTokens.componentSize.skeletonTextMd,
            width: AppTokens.componentSize.skeletonWidthXl,
            borderRadius: AppTokens.radius.sm,
          ),
        ),
      ],
    );
  }
}

/// Skeleton tile matching InfoTile with iconInContainer.
/// Structure: icon container + title column + optional chevron.
class _SkeletonInfoTile extends StatelessWidget {
  const _SkeletonInfoTile({this.showChevron = true});

  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon container (matches InfoTile iconInContainer style)
        SkeletonBlock(
          height: AppTokens.componentSize.avatarLg,
          width: AppTokens.componentSize.avatarLg,
          borderRadius: AppTokens.radius.sm,
        ),
        SizedBox(width: spacing.md),
        Expanded(
          child: SkeletonBlock(
            height: AppTokens.componentSize.skeletonTextMd,
            width: AppTokens.componentSize.skeletonWidthXl,
            borderRadius: AppTokens.radius.sm,
          ),
        ),
        if (showChevron) ...[
          SizedBox(width: spacing.sm),
          SkeletonBlock(
            height: AppTokens.iconSize.md,
            width: AppTokens.iconSize.md,
            borderRadius: AppTokens.radius.sm,
          ),
        ],
      ],
    );
  }
}

/// Skeleton for the account overview screen content.
/// Matches the structure: account summary card (title, subtitle, profile section
/// with avatar + info), security card (title, subtitle, info tiles), sign out button.
class SkeletonAccountOverview extends StatelessWidget {
  const SkeletonAccountOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Account summary card
        _SkeletonAccountSummaryCard(),
        SizedBox(height: spacing.lg),

        // Security card
        _SkeletonSecurityCard(),
        SizedBox(height: spacing.lg),

        // Sign out button skeleton
        SkeletonBlock(
          height: AppTokens.componentSize.buttonMd,
          borderRadius: AppTokens.radius.pill,
        ),
      ],
    );
  }
}

/// Skeleton for the account summary card.
/// Structure: section header + subtitle, profile section header + subtitle,
/// avatar + name/student ID/email column.
class _SkeletonAccountSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: colors.outline
              .withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.dim),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header: "Account overview"
          SkeletonBlock(
            height: AppTokens.componentSize.skeletonTextLg,
            width: AppTokens.componentSize.skeletonWidthMax,
            borderRadius: AppTokens.radius.sm,
          ),
          SizedBox(height: spacing.xs),
          // Subtitle description
          SkeletonBlock(
            height: AppTokens.componentSize.skeletonTextSm,
            width: AppTokens.componentSize.skeletonWidthHero,
            borderRadius: AppTokens.radius.sm,
          ),
          SizedBox(height: spacing.xl),

          // Profile section header
          SkeletonBlock(
            height: AppTokens.componentSize.skeletonTextMd,
            width: AppTokens.componentSize.skeletonWidthSm,
            borderRadius: AppTokens.radius.sm,
          ),
          SizedBox(height: spacing.xs),
          // Profile subtitle
          SkeletonBlock(
            height: AppTokens.componentSize.skeletonTextSm,
            width: AppTokens.componentSize.skeletonWidthXl,
            borderRadius: AppTokens.radius.sm,
          ),
          SizedBox(height: spacing.lg),

          // Profile content row: avatar + info column
          Row(
            children: [
              // Avatar with edit badge overlay
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SkeletonCircle(size: AppTokens.componentSize.avatarXl * 2),
                  Positioned(
                    right: -spacing.xs,
                    bottom: -spacing.xs,
                    child: SkeletonCircle(
                      size: AppTokens.componentSize.avatarSm,
                    ),
                  ),
                ],
              ),
              SizedBox(width: spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    SkeletonBlock(
                      height: AppTokens.componentSize.skeletonTextMd,
                      width: AppTokens.componentSize.skeletonWidthLg,
                      borderRadius: AppTokens.radius.sm,
                    ),
                    SizedBox(height: spacing.xs),
                    // Student ID
                    SkeletonBlock(
                      height: AppTokens.componentSize.skeletonTextSm,
                      width: AppTokens.componentSize.skeletonWidthMd,
                      borderRadius: AppTokens.radius.sm,
                    ),
                    SizedBox(height: spacing.xs),
                    // Email
                    SkeletonBlock(
                      height: AppTokens.componentSize.skeletonTextSm,
                      width: AppTokens.componentSize.skeletonWidthXl,
                      borderRadius: AppTokens.radius.sm,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton for the security actions card.
/// Structure: section header + subtitle, 3 info tiles (change email,
/// change password, delete account).
class _SkeletonSecurityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: colors.outline
              .withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.dim),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header: "Security actions"
          SkeletonBlock(
            height: AppTokens.componentSize.skeletonTextMd,
            width: AppTokens.componentSize.skeletonWidthLg,
            borderRadius: AppTokens.radius.sm,
          ),
          SizedBox(height: spacing.xs),
          // Subtitle description
          SkeletonBlock(
            height: AppTokens.componentSize.skeletonTextSm,
            width: AppTokens.componentSize.skeletonWidthXl,
            borderRadius: AppTokens.radius.sm,
          ),
          SizedBox(height: spacing.lg),

          // Info tiles (3 rows: change email, change password, delete account)
          const _SkeletonInfoTile(),
          SizedBox(height: spacing.md),
          const _SkeletonInfoTile(),
          SizedBox(height: spacing.md),
          const _SkeletonInfoTile(),
        ],
      ),
    );
  }
}
