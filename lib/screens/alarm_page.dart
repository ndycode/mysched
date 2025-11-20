import 'package:flutter/material.dart';

import '../services/reminder_scope_store.dart';
import '../ui/kit/kit.dart';
import '../utils/nav.dart';

class AlarmPage extends StatelessWidget {
  const AlarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return AppScaffold(
      screenName: 'alarms',
      appBar: const AppBarX(title: 'Class reminders'),
      body: AppBackground(
        child: PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardX(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How reminders work',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'MySched syncs your timetable to Android\'s exact alarm API. '
                      'You can manage the lead time, snooze length, and quiet week from Settings > Notifications.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CardX(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Heads-up tips',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    const _Bullet(
                        'Keep notifications enabled so alarms can fire on time.'),
                    const _Bullet(
                        'Use Quiet week when you want to pause reminders temporarily.'),
                    const _Bullet(
                        'Re-run "Resync class reminders" in Settings after editing your schedule.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CardX(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Need to change something?',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => openReminders(
                        scope: ReminderScopeStore.instance.value,
                      ),
                      child: const Text('Open notification settings'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline,
              size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
