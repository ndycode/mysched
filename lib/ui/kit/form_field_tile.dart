import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A tile for displaying form field selections like date and time.
///
/// Shows an icon, label, value, and chevron. Typically used in forms
/// for tappable date/time pickers.
class FormFieldTile extends StatelessWidget {
  const FormFieldTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.fontSize,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  /// Override the value font size.
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      borderRadius: AppTokens.radius.lg,
      onTap: onTap,
      child: Container(
        padding: AppTokens.spacing.edgeInsetsSymmetric(
          horizontal: AppTokens.spacing.lg,
          vertical: AppTokens.spacing.md + AppTokens.spacing.xs / 2,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: AppTokens.radius.lg,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: AppOpacity.ghost),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: AppTokens.componentSize.avatarSm,
              height: AppTokens.componentSize.avatarSm,
              decoration: BoxDecoration(
                borderRadius: AppTokens.radius.md,
                color: colors.primary.withValues(alpha: AppOpacity.statusBg),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: colors.primary,
                size: AppTokens.iconSize.sm,
              ),
            ),
            SizedBox(width: AppTokens.spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppTokens.spacing.xs),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                        fontSize:
                            fontSize ?? AppTokens.typography.subtitle.fontSize,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppTokens.spacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              size: AppTokens.iconSize.md,
              color: colors.onSurfaceVariant.withValues(alpha: AppOpacity.subtle),
            ),
          ],
        ),
      ),
    );
  }
}
