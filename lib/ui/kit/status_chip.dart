import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.md - 2,
        vertical: compact ? spacing.xs + 1 : spacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTokens.radius.pill,
        border: Border.all(color: foreground.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTokens.iconSize.xs, color: foreground),
          SizedBox(width: AppTokens.spacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: AppTokens.typography.caption.fontSize,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
          ),
        ],
      ),
    );
  }
}
