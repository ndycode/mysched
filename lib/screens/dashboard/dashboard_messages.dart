// ignore_for_file: unused_element_parameter
part of 'dashboard_screen.dart';

class _DashboardMessageCard extends StatelessWidget {
  const _DashboardMessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.xl),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: isDark ? colors.outline.withValues(alpha: AppOpacity.overlay) : colors.outline,
          width: isDark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: AppOpacity.veryFaint),
                  blurRadius: AppTokens.shadow.lg,
                  offset: AppShadowOffset.sm,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: AppTokens.componentSize.listItemSm,
                width: AppTokens.componentSize.listItemSm,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: AppOpacity.overlay),
                  borderRadius: AppTokens.radius.lg,
                ),
                child: Icon(
                  icon,
                  size: AppTokens.iconSize.lg,
                  color: colors.primary,
                ),
              ),
              SizedBox(width: spacing.md + spacing.microLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTokens.typography.title.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: AppLetterSpacing.tight,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      message,
                      style: AppTokens.typography.body.copyWith(
                        color: colors.onSurfaceVariant.withValues(alpha: AppOpacity.prominent),
                        height: AppLineHeight.relaxed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (primaryLabel != null || secondaryLabel != null) ...[
            SizedBox(height: spacing.lg),
            Row(
              children: [
                if (primaryLabel != null)
                  Expanded(
                    child: PrimaryButton(
                      label: primaryLabel!,
                      onPressed: onPrimary,
                      minHeight: AppTokens.componentSize.buttonMd,
                      expanded: true,
                    ),
                  ),
                if (primaryLabel != null && secondaryLabel != null)
                  SizedBox(width: spacing.md),
                if (secondaryLabel != null)
                  Expanded(
                    child: SecondaryButton(
                      label: secondaryLabel!,
                      onPressed: onSecondary,
                      minHeight: AppTokens.componentSize.buttonMd,
                      expanded: true,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
