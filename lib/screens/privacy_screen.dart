import 'package:flutter/material.dart';

import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';

class PrivacySheet extends StatelessWidget {
  const PrivacySheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppModal.sheet<void>(
      context: context,
      builder: (_) => const PrivacySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    Color filledBackground() => colors.surfaceContainerHighest.withValues(
          alpha: isDark ? AppOpacity.ghost : AppOpacity.soft,
        );

    return ContentShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: spacing.edgeInsetsSymmetric(
              horizontal: spacing.xs,
              vertical: spacing.xs,
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
                        'Privacy policy',
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
                child: SingleChildScrollView(
                  padding: spacing.edgeInsetsSymmetric(vertical: spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SurfaceCard(
                        padding: spacing.edgeInsetsAll(spacing.md),
                        borderRadius: AppTokens.radius.lg,
                        backgroundColor: filledBackground(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconBox(
                              icon: Icons.lock_outline,
                              tint: colors.primary,
                              size: IconBoxSize.md,
                            ),
                            SizedBox(width: spacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your schedule stays yours',
                                    style: AppTokens.typography.subtitle.copyWith(
                                      fontWeight: AppTokens.fontWeight.bold,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: spacing.xs),
                                  Text(
                                    'MySched stores data in your Supabase account. We encrypt in transit, never sell your data, and follow the Data Privacy Act of 2012 (RA 10173).',
                                    style: AppTokens.typography.body.copyWith(
                                      color: palette.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing.xxxl),
                      Text(
                        'DATA PRACTICES',
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
                        backgroundColor: filledBackground(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SimpleBullet(
                              text:
                                  'Schedules, reminders, and class reports live in your authenticated Supabase project.',
                            ),
                            SimpleBullet(
                              text:
                                  'We keep lightweight analytics (crash logs, feature usage) to improve stability—no personal data is stored there.',
                            ),
                            SimpleBullet(
                              text:
                                  'You can request data export or removal anytime through Settings → Support.',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing.xxxl),
                      Text(
                        'PERMISSIONS WE REQUEST',
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
                        backgroundColor: filledBackground(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const InfoTile(
                              icon: Icons.camera_alt_outlined,
                              title: 'Camera',
                              subtitle:
                                  'Capture your student card for OCR scanning. Images stay on device—only extracted schedule data is saved.',
                            ),
                            SizedBox(height: AppTokens.spacing.lg),
                            const InfoTile(
                              icon: Icons.photo_library_outlined,
                              title: 'Photos (read only)',
                              subtitle:
                                  'Let you pick an existing card image instead of rescanning. Required only on older Android versions.',
                            ),
                            SizedBox(height: AppTokens.spacing.lg),
                            const InfoTile(
                              icon: Icons.notifications_active_outlined,
                              title: 'Notifications',
                              subtitle:
                                  'Deliver reminders, snoozes, and heads-up alerts. You can toggle reminders—or their lead time—anytime.',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing.xxxl),
                      Text(
                        'YOUR CONTROLS',
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
                        backgroundColor: filledBackground(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SimpleBullet(
                              text:
                                  'Delete schedules or reminders individually, or sign out to clear local cache.',
                            ),
                            SimpleBullet(
                              text:
                                  'Need a copy or removal? Contact support through Settings → Help & feedback.',
                            ),
                            SimpleBullet(
                              text:
                                  'Alarm permissions can be revoked in system settings—MySched will surface a prompt if reminders stop working.',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing.xxxl),
                      SurfaceCard(
                        padding: spacing.edgeInsetsAll(spacing.md),
                        borderRadius: AppTokens.radius.lg,
                        backgroundColor: filledBackground(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Questions or concerns?',
                              style: AppTokens.typography.title.copyWith(
                                fontWeight: AppTokens.fontWeight.bold,
                                letterSpacing: AppLetterSpacing.snug,
                                color: colors.onSurface,
                              ),
                            ),
                            SizedBox(height: spacing.sm),
                            Text(
                              'We want you to feel safe using MySched. Reach out for clarifications, report an issue, or request changes to your stored data.',
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
                              label: 'Open full policy (PDF)',
                              icon: Icons.picture_as_pdf_outlined,
                              onPressed: () => _openFullPolicy(context),
                              expanded: false,
                            ),
                            SizedBox(height: spacing.sm),
                            Text(
                              'Last updated October 2025',
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
              ),
            ],
          ),
    );
  }

  static Future<void> _openFullPolicy(BuildContext context) {
    return AppModal.info(
      context: context,
      title: 'Full privacy policy',
      message: 'A downloadable PDF is coming soon. For now, the full policy is mirrored in Settings → Updates.',
      icon: Icons.picture_as_pdf_outlined,
    );
  }
}
