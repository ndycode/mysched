import 'package:flutter/material.dart';

import '../ui/kit/kit.dart';
import '../ui/theme/card_styles.dart';
import '../ui/theme/tokens.dart';

class AboutSheet extends StatelessWidget {
  const AboutSheet({super.key});

  static Future<void> show(BuildContext context) {
    final media = MediaQuery.of(context);
    return showOverlaySheet<void>(
      context: context,
      alignment: Alignment.center,
      barrierDismissible: true,
      barrierTint: AppBarrier.medium,
      padding: EdgeInsets.fromLTRB(
        AppTokens.spacing.xxl,
        media.padding.top + AppTokens.spacing.xxxl,
        AppTokens.spacing.xxl,
        media.padding.bottom + AppTokens.spacing.xxxl,
      ),
      builder: (_) => const AboutSheet(),
    );
  }

  static Future<void> _showReleaseNotes(BuildContext context) {
    return AppModal.showAlertDialog(
      context: context,
      title: 'Release notes',
      message: 'Thanks for using MySched! The full changelog lives in Settings → Updates. '
          'This quick view will link there once the hub is ready.',
      icon: Icons.article_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height -
        (AppTokens.spacing.xxxl * 2 + media.padding.top + media.padding.bottom);
    final cardBackground = elevatedCardBackground(theme, solid: true);

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppLayout.sheetMaxWidth,
          maxHeight: maxHeight.clamp(AppLayout.sheetMinHeight, double.infinity),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? theme.colorScheme.surfaceContainerHigh
                : theme.colorScheme.surface,
          borderRadius: AppTokens.radius.xl,
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: theme.brightness == Brightness.dark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: AppOpacity.medium),
                blurRadius: AppTokens.shadow.xxl,
                offset: AppShadowOffset.modal,
              ),
            ],
          ),
          child: ClipRRect(
          borderRadius: AppTokens.radius.xl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.xl,
                    spacing.xl,
                    spacing.xl,
                    spacing.sm,
                  ),
                  child: Row(
                    children: [
                      PressableScale(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.all(AppTokens.spacing.sm),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: AppOpacity.highlight),
                            borderRadius: AppTokens.radius.xl,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: AppTokens.iconSize.sm,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'About MySched',
                          textAlign: TextAlign.center,
                          style: AppTokens.typography.title.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(width: AppTokens.spacing.quad),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          spacing.xl,
                          spacing.md,
                          spacing.xl,
                          spacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: spacing.edgeInsetsAll(spacing.md),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.ghost)
                                    : colors.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle),
                                borderRadius: AppTokens.radius.lg,
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(alpha: AppOpacity.accent),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Built for ICI students',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: AppTokens.fontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: spacing.sm),
                                  Text(
                                    'MySched keeps your ICI class day organised in a few taps. Scan your student card, confirm the timetable we build, and let the app handle reminders before each class.',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing.xxxl),
                            Text(
                              'FEATURE HIGHLIGHTS',
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: AppLetterSpacing.sectionHeader,
                                fontWeight: AppTokens.fontWeight.semiBold,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: spacing.sm),
                            Container(
                              padding: spacing.edgeInsetsAll(spacing.md),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.ghost)
                                    : colors.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle),
                                borderRadius: AppTokens.radius.lg,
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(alpha: AppOpacity.accent),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const InfoTile(
                                    icon: Icons.document_scanner_outlined,
                                    title: 'Scan & build in seconds',
                                    subtitle:
                                        'Fast OCR import of student cards with easy review before saving.',
                                    iconInContainer: true,
                                    compactContainer: true,
                                  ),
                                  SizedBox(height: spacing.md),
                                  const InfoTile(
                                    icon: Icons.view_week_outlined,
                                    title: 'Clear daily overview',
                                    subtitle:
                                        'Colour-coded timetable grouped by day and class status.',
                                    iconInContainer: true,
                                    compactContainer: true,
                                  ),
                                  SizedBox(height: spacing.md),
                                  const InfoTile(
                                    icon: Icons.notifications_active_outlined,
                                    title: 'Helpful reminders',
                                    subtitle:
                                        'Heads-up alerts with snooze, follow-ups, and simple admin reporting.',
                                    iconInContainer: true,
                                    compactContainer: true,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing.xxxl),
                            Text(
                              'HOW IT WORKS',
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: AppLetterSpacing.sectionHeader,
                                fontWeight: AppTokens.fontWeight.semiBold,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: spacing.sm),
                            Container(
                              padding: spacing.edgeInsetsAll(spacing.md),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.ghost)
                                    : colors.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle),
                                borderRadius: AppTokens.radius.lg,
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(alpha: AppOpacity.accent),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'How it works',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: AppTokens.fontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: spacing.sm),
                                  const SimpleBullet(
                                    text:
                                        'Supabase keeps schedules, reminders, and reports in sync across devices.',
                                  ),
                                  const SimpleBullet(
                                    text:
                                        'Google ML Kit Text Recognition reads student cards to build classes.',
                                  ),
                                  const SimpleBullet(
                                    text:
                                        'Native alarm services trigger reminders even when the app is closed.',
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing.xxxl),
                            Text(
                              'TRUST & SAFETY',
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: AppLetterSpacing.sectionHeader,
                                fontWeight: AppTokens.fontWeight.semiBold,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: spacing.sm),
                            Container(
                              padding: spacing.edgeInsetsAll(spacing.md),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.ghost)
                                    : colors.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle),
                                borderRadius: AppTokens.radius.lg,
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(alpha: AppOpacity.accent),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Permissions we request',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: AppTokens.fontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: spacing.md),
                                  const InfoTile(
                                    icon: Icons.camera_alt_outlined,
                                    title: 'Camera',
                                    subtitle:
                                        'Capture your student card for OCR scanning.',
                                  ),
                                  SizedBox(height: spacing.md),
                                  const InfoTile(
                                    icon: Icons.photo_library_outlined,
                                    title: 'Photos (read only)',
                                    subtitle:
                                        'Pick an existing card image instead of rescanning.',
                                  ),
                                  SizedBox(height: spacing.md),
                                  const InfoTile(
                                    icon: Icons.notifications_active_outlined,
                                    title: 'Notifications',
                                    subtitle:
                                        'Deliver timely class reminders and heads-up alerts.',
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing.xxxl),
                            Container(
                              padding: spacing.edgeInsetsAll(spacing.md),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.ghost)
                                    : colors.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle),
                                borderRadius: AppTokens.radius.lg,
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(alpha: AppOpacity.accent),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Data & privacy',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: AppTokens.fontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: spacing.sm),
                                  Text(
                                    'Every schedule saves to your authenticated Supabase account. MySched follows the Data Privacy Act of 2012 (RA 10173). For more detail, open Settings > Privacy Policy.',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing.xxxl),
                            Center(
                              child: Column(
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _showReleaseNotes(context),
                                    icon: const Icon(Icons.article_outlined),
                                    label: const Text('View release notes'),
                                  ),
                                  SizedBox(height: spacing.sm),
                                  Text(
                                    'Updated October 2025',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: Container(
                            height: spacing.lg,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  cardBackground,
                                  cardBackground.withValues(alpha: AppOpacity.transparent),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: Container(
                            height: spacing.lg,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  cardBackground,
                                  cardBackground.withValues(alpha: AppOpacity.transparent),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
