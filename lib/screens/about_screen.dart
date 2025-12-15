import 'package:flutter/material.dart';

import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';

class AboutSheet extends StatelessWidget {
  const AboutSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppModal.sheet<void>(
      context: context,
      builder: (_) => const AboutSheet(),
    );
  }

  static Future<void> _showReleaseNotes(BuildContext context) {
    return AppModal.info(
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
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    // Keep cardBackground for gradient usage
    final cardBackground =
        isDark ? colors.surfaceContainerHigh : colors.surface;

    return ContentShell(
      padding: EdgeInsets.zero,
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
                    child: IconBox(
                      icon: Icons.close_rounded,
                      tint: colors.primary,
                      size: IconBoxSize.sm,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'About MySched',
                      textAlign: TextAlign.center,
                      style: AppTokens.typography.titleScaled(ResponsiveProvider.scale(context)).copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                        letterSpacing: AppLetterSpacing.snug,
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
                            SurfaceCard(
                              padding: spacing.edgeInsetsAll(spacing.md),
                              borderRadius: AppTokens.radius.lg,
                              backgroundColor: theme.brightness == Brightness.dark
                                  ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.ghost)
                                  : colors.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Built for ICI students',
                                    style: AppTokens.typography.title.copyWith(
                                      fontWeight: AppTokens.fontWeight.bold,
                                      letterSpacing: AppLetterSpacing.snug,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: spacing.sm),
                                  Text(
                                    'MySched keeps your ICI class day organised in a few taps. Scan your student card, confirm the timetable we build, and let the app handle reminders before each class.',
                                    style: AppTokens.typography.body.copyWith(
                                      color: palette.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing.xxxl),
                            Text(
                              'FEATURE HIGHLIGHTS',
                              style: AppTokens.typography.caption.copyWith(
                                letterSpacing: AppLetterSpacing.sectionHeader,
                                fontWeight: AppTokens.fontWeight.semiBold,
                                color: palette.muted,
                              ),
                            ),
                            SizedBox(height: spacing.sm),
                            SurfaceCard(
                              padding: spacing.edgeInsetsAll(spacing.md),
                              borderRadius: AppTokens.radius.lg,
                              backgroundColor: theme.brightness == Brightness.dark
                                  ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.ghost)
                                  : colors.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle),
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
                              style: AppTokens.typography.caption.copyWith(
                                letterSpacing: AppLetterSpacing.sectionHeader,
                                fontWeight: AppTokens.fontWeight.semiBold,
                                color: palette.muted,
                              ),
                            ),
                            SizedBox(height: spacing.sm),
                            SurfaceCard(
                              padding: spacing.edgeInsetsAll(spacing.md),
                              borderRadius: AppTokens.radius.lg,
                              backgroundColor: theme.brightness == Brightness.dark
                                  ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.ghost)
                                  : colors.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'How it works',
                                    style: AppTokens.typography.title.copyWith(
                                      fontWeight: AppTokens.fontWeight.bold,
                                      letterSpacing: AppLetterSpacing.snug,
                                      color: colors.onSurface,
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
                              style: AppTokens.typography.caption.copyWith(
                                letterSpacing: AppLetterSpacing.sectionHeader,
                                fontWeight: AppTokens.fontWeight.semiBold,
                                color: palette.muted,
                              ),
                            ),
                            SizedBox(height: spacing.sm),
                            SurfaceCard(
                              padding: spacing.edgeInsetsAll(spacing.md),
                              borderRadius: AppTokens.radius.lg,
                              backgroundColor: theme.brightness == Brightness.dark
                                  ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.ghost)
                                  : colors.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Permissions we request',
                                    style: AppTokens.typography.title.copyWith(
                                      fontWeight: AppTokens.fontWeight.bold,
                                      letterSpacing: AppLetterSpacing.snug,
                                      color: colors.onSurface,
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
                            SurfaceCard(
                              padding: spacing.edgeInsetsAll(spacing.md),
                              borderRadius: AppTokens.radius.lg,
                              backgroundColor: theme.brightness == Brightness.dark
                                  ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.ghost)
                                  : colors.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Data & privacy',
                                    style: AppTokens.typography.title.copyWith(
                                      fontWeight: AppTokens.fontWeight.bold,
                                      letterSpacing: AppLetterSpacing.snug,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: spacing.sm),
                                  Text(
                                    'Every schedule saves to your authenticated Supabase account. MySched follows the Data Privacy Act of 2012 (RA 10173). For more detail, open Settings > Privacy Policy.',
                                    style: AppTokens.typography.body.copyWith(
                                      color: palette.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing.xxxl),
                            Center(
                              child: Column(
                                children: [
                                  TertiaryButton(
                                    label: 'View release notes',
                                    icon: Icons.article_outlined,
                                    onPressed: () => _showReleaseNotes(context),
                                    expanded: false,
                                  ),
                                  SizedBox(height: spacing.sm),
                                  Text(
                                    'Updated October 2025',
                                    style: AppTokens.typography.caption.copyWith(
                                      color: palette.muted,
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
    );
  }
}
