part of 'dashboard_screen.dart';

class _DashboardMessageCard extends StatelessWidget {
  const _DashboardMessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.onPrimary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final background = colors.surfaceContainerHigh;
    final border = colors.outline.withValues(alpha: 0.12);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'SFProRounded',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: kMuted),
          ),
          if (primaryLabel != null && onPrimary != null) ...[
            const SizedBox(height: 12),
            PrimaryButton(
              label: primaryLabel!,
              onPressed: onPrimary,
            ),
          ],
        ],
      ),
    );
  }
}
