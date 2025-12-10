import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'responsive_provider.dart';
import 'status_badge.dart';

/// Metadata item to display in an entity tile (time, location, instructor, etc.)
class MetadataItem {
  const MetadataItem({
    required this.icon,
    required this.label,
    this.expanded = false,
    this.isVerticalTime = false,
    this.startTime,
    this.endTime,
  });

  /// Icon to display before the label
  final IconData icon;

  /// Text content
  final String label;

  /// If true, this item expands to fill remaining space
  final bool expanded;

  /// If true, displays start/end times vertically (end above start)
  final bool isVerticalTime;

  /// Start time for vertical display
  final String? startTime;

  /// End time for vertical display
  final String? endTime;
}

/// A unified tile component for displaying schedule rows and reminder rows.
/// 
/// This is the core shared component that ensures visual consistency between
/// dashboard, schedules, and reminders screens.
class EntityTile extends StatelessWidget {
  const EntityTile({
    super.key,
    required this.title,
    this.subtitle,
    this.metadata = const [],
    this.trailing,
    this.badge,
    this.tags = const [],
    this.bottomContent,
    this.isActive = true,
    this.isStrikethrough = false,
    this.isHighlighted = false,
    this.highlightColor,
    this.onTap,
    this.borderRadius,
  });

  /// Primary title text
  final String title;

  /// Optional subtitle below title
  final String? subtitle;

  /// List of metadata items (time, location, etc.)
  final List<MetadataItem> metadata;

  /// Trailing widget (Switch, button, etc.)
  final Widget? trailing;

  /// Optional status badge (Live, Next, Done, etc.)
  final StatusBadge? badge;

  /// Optional list of tag widgets
  final List<Widget> tags;

  /// Optional custom widget below metadata (e.g., instructor row)
  final Widget? bottomContent;

  /// Whether this item is in an active state (affects styling)
  final bool isActive;

  /// Whether the title should have strikethrough
  final bool isStrikethrough;

  /// Whether this tile is highlighted (e.g., current/next item)
  final bool isHighlighted;

  /// Optional override for highlight color (defaults to primary when highlighted)
  final Color? highlightColor;

  /// Tap handler
  final VoidCallback? onTap;

  /// Custom border radius
  final BorderRadius? borderRadius;


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;
    final radius = borderRadius ?? AppTokens.radius.md;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final isDisabled = !isActive;
    final highlightBase = highlightColor ?? colors.primary;
    final hasAccentFill = highlightColor != null && !isDisabled;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    // Resolve surface and border based on state.
    final Color containerColor = isDisabled
      ? palette.danger.withValues(alpha: AppOpacity.veryFaint)
      : hasAccentFill
        ? highlightBase.withValues(alpha: isDark ? AppOpacity.medium : AppOpacity.faint)
        : isDark
          ? colors.surfaceContainerHigh
          : colors.surface;

    final Color borderColor = isHighlighted
      ? highlightBase.withValues(alpha: AppOpacity.medium)
      : hasAccentFill
        ? highlightBase.withValues(alpha: AppOpacity.medium)
        : isDisabled
          ? palette.danger.withValues(alpha: AppOpacity.medium)
          : colors.outline.withValues(alpha: isDark ? AppOpacity.overlay : AppOpacity.subtle);

    final Color titleColor = isDisabled
      ? palette.danger.withValues(alpha: AppOpacity.secondary)
      : isActive
        ? colors.onSurface
        : palette.muted;

    final Color secondaryTextColor = isDisabled
      ? palette.danger.withValues(alpha: AppOpacity.secondary)
      : palette.muted.withValues(alpha: AppOpacity.glass);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: highlightBase.withValues(alpha: AppOpacity.faint),
        highlightColor: highlightBase.withValues(alpha: AppOpacity.ultraMicro),
        child: AnimatedContainer(
          duration: AppTokens.motion.medium,
          curve: AppTokens.motion.ease,
          padding: spacing.edgeInsetsAll(spacing.lg * spacingScale),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: radius,
            border: Border.all(
              color: borderColor,
              width: isHighlighted ? AppTokens.componentSize.dividerThick : AppTokens.componentSize.dividerThin,
            ),
            boxShadow: isDark
                ? null
                : isDisabled
                    ? null
                    : [
                    BoxShadow(
                      color: highlightBase.withValues(
                        alpha: isHighlighted ? AppOpacity.highlight : AppOpacity.micro,
                      ),
                      blurRadius: isHighlighted ? AppTokens.shadow.md : AppTokens.shadow.xs,
                      offset: AppShadowOffset.xs,
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Title, badge, and trailing
              Row(
                crossAxisAlignment: tags.isNotEmpty
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTokens.typography.subtitleScaled(scale).copyWith(
                            fontWeight: AppTokens.fontWeight.bold,
                            letterSpacing: AppLetterSpacing.compact,
                            color: titleColor,
                            decoration:
                                isStrikethrough ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (tags.isNotEmpty) ...[
                          SizedBox(height: spacing.xsPlus * spacingScale),
                          Wrap(
                            spacing: spacing.xsPlus * spacingScale,
                            runSpacing: spacing.xsPlus * spacingScale,
                            children: tags,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (badge != null || trailing != null) SizedBox(width: spacing.md * spacingScale),
                  if (badge != null) badge!,
                  if (badge != null && trailing != null) SizedBox(width: spacing.sm * spacingScale),
                  if (trailing != null) trailing!,
                ],
              ),

              // Subtitle if present
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                SizedBox(height: spacing.xsPlus * spacingScale),
                Text(
                  subtitle!,
                  style: AppTokens.typography.bodyScaled(scale).copyWith(
                    color: secondaryTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Metadata row
              if (metadata.isNotEmpty) ...[
                SizedBox(height: spacing.md * spacingScale),
                Row(
                  children: [
                    for (var i = 0; i < metadata.length; i++) ...[
                      if (i > 0) SizedBox(width: spacing.lg * spacingScale),
                      if (metadata[i].expanded)
                        Expanded(child: _buildMetadataItem(palette, spacing, metadata[i], isDisabled, secondaryTextColor, scale, spacingScale))
                      else
                          _buildMetadataItem(palette, spacing, metadata[i], isDisabled, secondaryTextColor, scale, spacingScale),
                    ],
                  ],
                ),
              ],

              // Bottom content (e.g., instructor row)
              if (bottomContent != null) ...[
                SizedBox(height: spacing.smMd * spacingScale),
                bottomContent!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataItem(
    ColorPalette palette,
    AppSpacing spacing,
    MetadataItem item,
    bool isDisabled,
    Color secondaryTextColor,
    double scale,
    double spacingScale,
  ) {
    // Vertical time layout: end time above start time
    if (item.isVerticalTime && item.startTime != null && item.endTime != null) {
      final textStyle = AppTokens.typography.captionScaled(scale).copyWith(
        fontWeight: AppTokens.fontWeight.semiBold,
        color: isDisabled ? secondaryTextColor : palette.muted,
      );
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            size: AppTokens.iconSize.sm * scale,
            color: isDisabled ? secondaryTextColor : palette.muted,
          ),
          SizedBox(width: spacing.xsPlus * spacingScale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.endTime!, style: textStyle),
              SizedBox(height: spacing.micro * spacingScale),
              Text(item.startTime!, style: textStyle),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          item.icon,
          size: AppTokens.iconSize.sm * scale,
          color: isDisabled ? secondaryTextColor : palette.muted,
        ),
        SizedBox(width: spacing.xsPlus * spacingScale),
        if (item.expanded)
          Expanded(
            child: Text(
              item.label,
              style: AppTokens.typography.bodyScaled(scale).copyWith(
                fontWeight: AppTokens.fontWeight.medium,
                color: isDisabled ? secondaryTextColor : palette.muted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(
            item.label,
            style: AppTokens.typography.bodyScaled(scale).copyWith(
              fontWeight: AppTokens.fontWeight.medium,
              color: isDisabled ? secondaryTextColor : palette.muted,
            ),
          ),
      ],
    );
  }
}
