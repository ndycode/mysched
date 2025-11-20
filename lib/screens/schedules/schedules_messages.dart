part of 'schedules_screen.dart';

class _ScheduleMessageCard extends StatelessWidget {
  const _ScheduleMessageCard({
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
    final cardBackground = elevatedCardBackground(theme);
    final borderColor = elevatedCardBorder(theme);

    return CardX(
      backgroundColor: cardBackground,
      borderColor: borderColor,
      padding: const EdgeInsets.all(20),
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (primaryLabel != null || secondaryLabel != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (primaryLabel != null) ...[
                  FilledButton(
                    onPressed: onPrimary,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTokens.radius.lg,
                      ),
                    ),
                    child: Text(primaryLabel!),
                  ),
                ],
                if (secondaryLabel != null) ...[
                  if (primaryLabel != null) const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: onSecondary,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTokens.radius.lg,
                      ),
                    ),
                    child: Text(secondaryLabel!),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({super.key, required this.lastSynced});

  final DateTime? lastSynced;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = lastSynced == null
        ? 'You are viewing your saved schedule offline.'
        : 'You are viewing your saved schedule from '
            '${DateFormat('MMM d - h:mm a').format(lastSynced!)}.';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: colors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$text We\'ll refresh automatically when you\'re back online.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
