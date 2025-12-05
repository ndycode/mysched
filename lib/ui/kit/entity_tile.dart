import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'status_badge.dart';

/// Metadata item to display in an entity tile (time, location, instructor, etc.)
class MetadataItem {
  const MetadataItem({
    required this.icon,
    required this.label,
    this.expanded = false,
  });

  /// Icon to display before the label
  final IconData icon;

  /// Text content
  final String label;

  /// If true, this item expands to fill remaining space
  final bool expanded;
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

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: colors.primary.withValues(alpha: AppOpacity.faint),
        highlightColor: colors.primary.withValues(alpha: AppOpacity.ultraMicro),
        child: Container(
          padding: spacing.edgeInsetsAll(spacing.lg),
          decoration: BoxDecoration(
            color: isDark ? colors.surfaceContainerHigh : colors.surface,
            borderRadius: radius,
            border: Border.all(
              color: isHighlighted
                  ? colors.primary.withValues(alpha: AppOpacity.ghost)
                  : colors.outline.withValues(alpha: isDark ? AppOpacity.overlay : AppOpacity.subtle),
              width: isHighlighted ? AppTokens.componentSize.dividerThick : AppTokens.componentSize.dividerThin,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: colors.shadow.withValues(
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
                          style: AppTokens.typography.subtitle.copyWith(
                            fontWeight: AppTokens.fontWeight.bold,
                            letterSpacing: AppLetterSpacing.compact,
                            color: isActive
                                ? colors.onSurface
                                : colors.onSurfaceVariant,
                            decoration:
                                isStrikethrough ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (tags.isNotEmpty) ...[
                          SizedBox(height: spacing.xsPlus),
                          Wrap(
                            spacing: spacing.xsPlus,
                            runSpacing: spacing.xsPlus,
                            children: tags,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (badge != null || trailing != null) SizedBox(width: spacing.md),
                  if (badge != null) badge!,
                  if (badge != null && trailing != null) SizedBox(width: spacing.sm),
                  if (trailing != null) trailing!,
                ],
              ),

              // Subtitle if present
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                SizedBox(height: spacing.xsPlus),
                Text(
                  subtitle!,
                  style: AppTokens.typography.bodySecondary.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: AppOpacity.glass),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Metadata row
              if (metadata.isNotEmpty) ...[
                SizedBox(height: spacing.md),
                Row(
                  children: [
                    for (var i = 0; i < metadata.length; i++) ...[
                      if (i > 0) SizedBox(width: spacing.lg),
                      if (metadata[i].expanded)
                        Expanded(child: _buildMetadataItem(colors, spacing, metadata[i]))
                      else
                        _buildMetadataItem(colors, spacing, metadata[i]),
                    ],
                  ],
                ),
              ],

              // Bottom content (e.g., instructor row)
              if (bottomContent != null) ...[
                SizedBox(height: spacing.smMd),
                bottomContent!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataItem(
    ColorScheme colors,
    AppSpacing spacing,
    MetadataItem item,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          item.icon,
          size: AppTokens.iconSize.sm,
          color: colors.onSurfaceVariant,
        ),
        SizedBox(width: spacing.xsPlus),
        if (item.expanded)
          Expanded(
            child: Text(
              item.label,
              style: AppTokens.typography.bodySecondary.copyWith(
                fontWeight: AppTokens.fontWeight.medium,
                color: colors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(
            item.label,
            style: AppTokens.typography.bodySecondary.copyWith(
              fontWeight: AppTokens.fontWeight.medium,
              color: colors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
