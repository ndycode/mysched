import 'package:flutter/material.dart';
import '../../services/reminders_api.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';

class ReminderMessageCard extends StatelessWidget {
  const ReminderMessageCard({
    super.key,
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
    return Container(
      padding: AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.xl),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colors.surfaceContainerHigh
            : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: colors.outlineVariant,
          width: theme.brightness == Brightness.dark ? 1 : 0.5,
        ),
        boxShadow: theme.brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: AppOpacity.faint),
                  blurRadius: AppTokens.shadow.md,
                  offset: AppShadowOffset.sm,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primary),
              SizedBox(width: AppTokens.spacing.md),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: AppTokens.fontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.spacing.sm),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (primaryLabel != null) ...[
            SizedBox(height: AppTokens.spacing.lg),
            PrimaryButton(
              label: primaryLabel!,
              onPressed: onPrimary,
              minHeight: AppTokens.componentSize.buttonMd,
              expanded: true,
            ),
          ],
        ],
      ),
    );
  }
}

class ReminderSnoozeSheet extends StatelessWidget {
  const ReminderSnoozeSheet({
    super.key,
    required this.entry,
    required this.formatDue,
  });

  final ReminderEntry entry;
  final String Function(DateTime due) formatDue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = <Duration, String>{
      const Duration(minutes: 5): 'In 5 minutes',
      const Duration(minutes: 15): 'In 15 minutes',
      const Duration(minutes: 30): 'In 30 minutes',
      const Duration(hours: 1): 'In 1 hour',
      const Duration(hours: 3): 'In 3 hours',
      const Duration(hours: 6): 'In 6 hours',
      const Duration(days: 1): 'Tomorrow',
    };

    final spacing = AppTokens.spacing;
    return Container(
      padding: EdgeInsets.only(
        left: spacing.xxl,
        right: spacing.xxl,
        top: spacing.xxl,
        bottom: MediaQuery.of(context).viewPadding.bottom + spacing.lg,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radius.xxl.topLeft.x)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: AppTokens.componentSize.progressWidth,
              height: AppTokens.componentSize.progressHeight,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: AppOpacity.divider),
                borderRadius: AppTokens.radius.circular(2),
              ),
            ),
          ),
          SizedBox(height: spacing.xl),
          Text(
            'Snooze reminder',
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'SFProRounded',
              fontWeight: AppTokens.fontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(entry.title, style: theme.textTheme.bodyMedium),
          SizedBox(height: AppTokens.spacing.sm),
          Text(
            'Current time: ${formatDue(entry.dueAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.lg),
          ...options.entries.map(
            (option) => ListTile(
              leading: const Icon(Icons.snooze_outlined),
              title: Text(option.value),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).pop(option.key),
            ),
          ),
        ],
      ),
    );
  }
}
