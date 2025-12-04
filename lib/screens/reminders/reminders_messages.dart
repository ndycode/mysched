import 'package:flutter/material.dart';
import '../../services/reminders_api.dart';
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
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? colors.outline.withValues(alpha: 0.12)
              : const Color(0xFFE5E5E5),
          width: theme.brightness == Brightness.dark ? 1 : 0.5,
        ),
        boxShadow: theme.brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
                    fontWeight: FontWeight.w700,
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
            FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTokens.radius.xl,
                ),
              ),
              child: Text(primaryLabel!),
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

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewPadding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: AppTokens.radius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Snooze reminder',
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'SFProRounded',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(entry.title, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            'Current time: ${formatDue(entry.dueAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
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
