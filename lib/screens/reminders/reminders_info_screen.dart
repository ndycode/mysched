import 'package:flutter/material.dart';

import '../../services/reminder_scope_store.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/nav.dart';

class AlarmPage extends StatelessWidget {
  const AlarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final media = MediaQuery.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    final backButton = IconButton(
      splashRadius: AppInteraction.splashRadius,
      onPressed: () => Navigator.of(context).maybePop(),
      icon: CircleAvatar(
        radius: AppInteraction.iconButtonContainerRadius,
        backgroundColor: colors.primary.withValues(alpha: AppOpacity.overlay),
        child: Icon(
          Icons.arrow_back_rounded,
          color: colors.primary,
          size: AppTokens.iconSize.sm,
        ),
      ),
    );

    final hero = ScreenBrandHeader(
      leading: backButton,
      showChevron: false,
    );

    void showPreviewOverlay() {
      AppModal.alert<void>(
        context: context,
        barrierColor: AppSemanticColor.black.withValues(alpha: AppOpacity.muted),
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: spacing.edgeInsetsAll(spacing.lg),
          child: const AlarmPreviewMock(expanded: true),
        ),
      );
    }

    return ScreenShell(
      screenName: 'alarms',
      hero: hero,
      sections: [
        ScreenSection(
          decorated: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeroCard(
                title: 'Class reminders',
                subtitle:
                    'Learn how MySched syncs your timetable to Android alarms.',
              ),
              SizedBox(height: spacing.lg),
              Text(
                'Live preview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppTokens.fontWeight.bold,
                  color: palette.muted,
                ),
              ),
              SizedBox(height: spacing.sm),
              const AlarmPreviewMock(),
              SizedBox(height: spacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: TertiaryButton(
                  label: 'Open fullscreen mock',
                  onPressed: showPreviewOverlay,
                  expanded: false,
                ),
              ),
            ],
          ),
        ),
        ScreenSection(
          title: 'How reminders work',
          subtitle: 'Alarm scheduling overview',
          decorated: false,
          child: Container(
            padding: spacing.edgeInsetsAll(spacing.xxl),
            decoration: BoxDecoration(
              color: isDark ? colors.surfaceContainerHigh : colors.surface,
              borderRadius: AppTokens.radius.xl,
              border: Border.all(
                color: isDark
                    ? colors.outline.withValues(alpha: AppOpacity.overlay)
                    : colors.outline,
                width: isDark
                    ? AppTokens.componentSize.divider
                    : AppTokens.componentSize.dividerThin,
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
            child: Text(
              'MySched syncs your timetable to Android\'s exact alarm API. '
              'You can manage the lead time, snooze length, and quiet week from Settings > Notifications.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.muted,
              ),
            ),
          ),
        ),
        ScreenSection(
          title: 'Heads-up tips',
          subtitle: 'Keep your alarms reliable.',
          decorated: false,
          child: Container(
            padding: spacing.edgeInsetsAll(spacing.xxl),
            decoration: BoxDecoration(
              color: isDark ? colors.surfaceContainerHigh : colors.surface,
              borderRadius: AppTokens.radius.xl,
              border: Border.all(
                color: isDark
                    ? colors.outline.withValues(alpha: AppOpacity.overlay)
                    : colors.outline,
                width: isDark
                    ? AppTokens.componentSize.divider
                    : AppTokens.componentSize.dividerThin,
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
              children: const [
                SimpleBullet(text: 'Keep notifications enabled so alarms can fire on time.'),
                SimpleBullet(text: 'Use Quiet week when you want to pause reminders temporarily.'),
                SimpleBullet(text: 'Re-run "Resync class reminders" in Settings after editing your schedule.'),
              ],
            ),
          ),
        ),
        ScreenSection(
          title: 'Need to change something?',
          subtitle: 'Open notifications settings to adjust preferences.',
          decorated: false,
          child: Container(
            padding: spacing.edgeInsetsAll(spacing.xxl),
            decoration: BoxDecoration(
              color: isDark ? colors.surfaceContainerHigh : colors.surface,
              borderRadius: AppTokens.radius.xl,
              border: Border.all(
                color: isDark
                    ? colors.outline.withValues(alpha: AppOpacity.overlay)
                    : colors.outline,
                width: isDark
                    ? AppTokens.componentSize.divider
                    : AppTokens.componentSize.dividerThin,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryButton(
                  label: 'Open notification settings',
                  onPressed: () => openReminders(
                    scope: ReminderScopeStore.instance.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      padding: EdgeInsets.fromLTRB(
        spacing.xl,
        media.padding.top + spacing.xxxl,
        spacing.xl,
        spacing.quad + AppLayout.bottomNavSafePadding,
      ),
      safeArea: false,
    );
  }
}
