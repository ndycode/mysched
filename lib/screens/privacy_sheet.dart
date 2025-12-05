import 'package:flutter/material.dart';

import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';

class PrivacySheet extends StatelessWidget {
  const PrivacySheet({super.key});

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
      builder: (_) => const PrivacySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final maxHeight = MediaQuery.of(context).size.height -
        (AppTokens.spacing.xxxl * 2 +
            MediaQuery.of(context).padding.top +
            MediaQuery.of(context).padding.bottom);

    Color filledBackground() => colors.surfaceContainerHighest.withValues(
          alpha: theme.brightness == Brightness.dark ? AppOpacity.ghost : AppOpacity.soft,
        );

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppLayout.sheetMaxWidth,
          maxHeight: maxHeight.clamp(360.0, double.infinity),
        ),
        child: CardX(
          padding: spacing.edgeInsetsAll(spacing.xl),
          borderRadius: AppTokens.radius.xl,
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
                      child: Container(
                        padding: spacing.edgeInsetsAll(spacing.sm),
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
                        'Privacy policy',
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
                child: SingleChildScrollView(
                  padding: spacing.edgeInsetsSymmetric(vertical: spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CardX(
                        variant: CardVariant.filled,
                        backgroundColor: filledBackground(),
                        borderColor:
                            colors.outlineVariant.withValues(alpha: AppOpacity.accent),
                        borderRadius: AppTokens.radius.lg,
                        padding: spacing.edgeInsetsAll(spacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: AppOpacity.overlay),
                                borderRadius: AppTokens.radius.sm,
                              ),
                              padding: spacing.edgeInsetsAll(spacing.sm),
                              child: Icon(
                                Icons.lock_outline,
                                color: colors.primary,
                                size: AppTokens.iconSize.md,
                              ),
                            ),
                            SizedBox(width: spacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your schedule stays yours',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: AppTokens.fontWeight.bold),
                                  ),
                                  SizedBox(height: spacing.xs),
                                  Text(
                                    'MySched stores data in your Supabase account. We encrypt in transit, never sell your data, and follow the Data Privacy Act of 2012 (RA 10173).',
                                    style: theme.textTheme.bodyMedium,
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
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: AppLetterSpacing.sectionHeader,
                          fontWeight: AppTokens.fontWeight.semiBold,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      CardX(
                        variant: CardVariant.filled,
                        backgroundColor: filledBackground(),
                        borderColor:
                            colors.outlineVariant.withValues(alpha: AppOpacity.accent),
                        borderRadius: AppTokens.radius.lg,
                        padding: spacing.edgeInsetsAll(spacing.md),
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
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: AppLetterSpacing.sectionHeader,
                          fontWeight: AppTokens.fontWeight.semiBold,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      CardX(
                        variant: CardVariant.filled,
                        backgroundColor: filledBackground(),
                        borderColor:
                            colors.outlineVariant.withValues(alpha: AppOpacity.accent),
                        borderRadius: AppTokens.radius.lg,
                        padding: spacing.edgeInsetsAll(spacing.md),
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
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: AppLetterSpacing.sectionHeader,
                          fontWeight: AppTokens.fontWeight.semiBold,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      CardX(
                        variant: CardVariant.filled,
                        backgroundColor: filledBackground(),
                        borderColor:
                            colors.outlineVariant.withValues(alpha: AppOpacity.accent),
                        borderRadius: AppTokens.radius.lg,
                        padding: spacing.edgeInsetsAll(spacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
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
                      CardX(
                        variant: CardVariant.filled,
                        backgroundColor: filledBackground(),
                        borderColor:
                            colors.outlineVariant.withValues(alpha: AppOpacity.accent),
                        borderRadius: AppTokens.radius.lg,
                        padding: spacing.edgeInsetsAll(spacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Questions or concerns?',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: AppTokens.fontWeight.bold,
                              ),
                            ),
                            SizedBox(height: spacing.sm),
                            Text(
                              'We want you to feel safe using MySched. Reach out for clarifications, report an issue, or request changes to your stored data.',
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
                              onPressed: () => _openFullPolicy(context),
                              icon: const Icon(
                                Icons.picture_as_pdf_outlined,
                              ),
                              label: const Text('Open full policy (PDF)'),
                            ),
                            SizedBox(height: spacing.sm),
                            Text(
                              'Last updated October 2025',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _openFullPolicy(BuildContext context) {
    return AppModal.showAlertDialog(
      context: context,
      title: 'Full privacy policy',
      message: 'A downloadable PDF is coming soon. For now, the full policy is mirrored in Settings → Updates.',
      icon: Icons.picture_as_pdf_outlined,
    );
  }
}
