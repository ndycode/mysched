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
      barrierTint: Colors.black.withValues(alpha: 0.45),
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
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Release notes'),
        content: const Text(
          'Thanks for using MySched! The full changelog lives in Settings → Updates. '
          'This quick view will link there once the hub is ready.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
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
          maxWidth: 520,
          maxHeight: maxHeight.clamp(360.0, double.infinity),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? theme.colorScheme.surfaceContainerHigh
                : Colors.white,
          borderRadius: AppTokens.radius.xl,
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.outline.withValues(alpha: 0.12)
                  : const Color(0xFFE5E5E5),
              width: theme.brightness == Brightness.dark ? 1 : 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 10),
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.08),
                            borderRadius: AppTokens.radius.xl,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
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
                      const SizedBox(width: 48),
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
                                    ? colors.surfaceContainerHighest.withValues(alpha: 0.3)
                                    : colors.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: AppTokens.radius.lg,
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Built for ICI students',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
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
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: spacing.sm),
                            Container(
                              padding: spacing.edgeInsetsAll(spacing.md),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? colors.surfaceContainerHighest.withValues(alpha: 0.3)
                                    : colors.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: AppTokens.radius.lg,
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _FeatureTile(
                                    icon: Icons.document_scanner_outlined,
                                    title: 'Scan & build in seconds',
                                    subtitle:
                                        'Fast OCR import of student cards with easy review before saving.',
                                  ),
                                  SizedBox(height: spacing.md),
                                  const _FeatureTile(
                                    icon: Icons.view_week_outlined,
                                    title: 'Clear daily overview',
                                    subtitle:
                                        'Colour-coded timetable grouped by day and class status.',
                                  ),
                                  SizedBox(height: spacing.md),
                                  const _FeatureTile(
                                    icon: Icons.notifications_active_outlined,
                                    title: 'Helpful reminders',
                                    subtitle:
                                        'Heads-up alerts with snooze, follow-ups, and simple admin reporting.',
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing.xxxl),
                            Text(
                              'HOW IT WORKS',
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: spacing.sm),
                            Container(
                              padding: spacing.edgeInsetsAll(spacing.md),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? colors.surfaceContainerHighest.withValues(alpha: 0.3)
                                    : colors.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: AppTokens.radius.lg,
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'How it works',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: spacing.sm),
                                  const _SimpleBullet(
                                    text:
                                        'Supabase keeps schedules, reminders, and reports in sync across devices.',
                                  ),
                                  const _SimpleBullet(
                                    text:
                                        'Google ML Kit Text Recognition reads student cards to build classes.',
                                  ),
                                  const _SimpleBullet(
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
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: spacing.sm),
                            Container(
                              padding: spacing.edgeInsetsAll(spacing.md),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? colors.surfaceContainerHighest.withValues(alpha: 0.3)
                                    : colors.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: AppTokens.radius.lg,
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Permissions we request',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: spacing.md),
                                  const _BulletTile(
                                    icon: Icons.camera_alt_outlined,
                                    title: 'Camera',
                                    subtitle:
                                        'Capture your student card for OCR scanning.',
                                  ),
                                  SizedBox(height: spacing.md),
                                  const _BulletTile(
                                    icon: Icons.photo_library_outlined,
                                    title: 'Photos (read only)',
                                    subtitle:
                                        'Pick an existing card image instead of rescanning.',
                                  ),
                                  SizedBox(height: spacing.md),
                                  const _BulletTile(
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
                                    ? colors.surfaceContainerHighest.withValues(alpha: 0.3)
                                    : colors.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: AppTokens.radius.lg,
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Data & privacy',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
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
                                  cardBackground.withValues(alpha: 0.0),
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
                                  cardBackground.withValues(alpha: 0.0),
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

class _BulletTile extends StatelessWidget {
  const _BulletTile({
    required this.title,
    this.subtitle,
    required this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = AppTokens.spacing;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: spacing.xs),
                Text(subtitle!, style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SimpleBullet extends StatelessWidget {
  const _SimpleBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = AppTokens.spacing;
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 4),
          Icon(Icons.circle, size: 8, color: theme.colorScheme.primary),
          SizedBox(width: spacing.sm),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = AppTokens.spacing;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: AppTokens.radius.sm,
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        SizedBox(width: spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
