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
      barrierTint: Colors.black.withValues(alpha: 0.45),
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
          alpha: theme.brightness == Brightness.dark ? 0.28 : 0.5,
        );

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
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
                          color: colors.primary.withValues(alpha: 0.08),
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
                            colors.outlineVariant.withValues(alpha: 0.2),
                        borderRadius: AppTokens.radius.lg,
                        padding: spacing.edgeInsetsAll(spacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.12),
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
                                        ?.copyWith(fontWeight: FontWeight.w700),
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
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      CardX(
                        variant: CardVariant.filled,
                        backgroundColor: filledBackground(),
                        borderColor:
                            colors.outlineVariant.withValues(alpha: 0.2),
                        borderRadius: AppTokens.radius.lg,
                        padding: spacing.edgeInsetsAll(spacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _SimpleBullet(
                              text:
                                  'Schedules, reminders, and class reports live in your authenticated Supabase project.',
                            ),
                            _SimpleBullet(
                              text:
                                  'We keep lightweight analytics (crash logs, feature usage) to improve stability—no personal data is stored there.',
                            ),
                            _SimpleBullet(
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
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      CardX(
                        variant: CardVariant.filled,
                        backgroundColor: filledBackground(),
                        borderColor:
                            colors.outlineVariant.withValues(alpha: 0.2),
                        borderRadius: AppTokens.radius.lg,
                        padding: spacing.edgeInsetsAll(spacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _PrivacyTile(
                              icon: Icons.camera_alt_outlined,
                              title: 'Camera',
                              description:
                                  'Capture your student card for OCR scanning. Images stay on device—only extracted schedule data is saved.',
                            ),
                            SizedBox(height: AppTokens.spacing.lg),
                            const _PrivacyTile(
                              icon: Icons.photo_library_outlined,
                              title: 'Photos (read only)',
                              description:
                                  'Let you pick an existing card image instead of rescanning. Required only on older Android versions.',
                            ),
                            SizedBox(height: AppTokens.spacing.lg),
                            const _PrivacyTile(
                              icon: Icons.notifications_active_outlined,
                              title: 'Notifications',
                              description:
                                  'Deliver reminders, snoozes, and heads-up alerts. You can toggle reminders—or their lead time—anytime.',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing.xxxl),
                      Text(
                        'YOUR CONTROLS',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      CardX(
                        variant: CardVariant.filled,
                        backgroundColor: filledBackground(),
                        borderColor:
                            colors.outlineVariant.withValues(alpha: 0.2),
                        borderRadius: AppTokens.radius.lg,
                        padding: spacing.edgeInsetsAll(spacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _SimpleBullet(
                              text:
                                  'Delete schedules or reminders individually, or sign out to clear local cache.',
                            ),
                            _SimpleBullet(
                              text:
                                  'Need a copy or removal? Contact support through Settings → Help & feedback.',
                            ),
                            _SimpleBullet(
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
                            colors.outlineVariant.withValues(alpha: 0.2),
                        borderRadius: AppTokens.radius.lg,
                        padding: spacing.edgeInsetsAll(spacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Questions or concerns?',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
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
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Full privacy policy'),
        content: const Text(
          'A downloadable PDF is coming soon. For now, the full policy is mirrored in Settings → Updates.',
        ),
        actions: [
          SecondaryButton(
            label: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            minHeight: AppTokens.componentSize.buttonSm,
            expanded: false,
          ),
        ],
      ),
    );
  }
}

class _PrivacyTile extends StatelessWidget {
  const _PrivacyTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

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
              SizedBox(height: spacing.xs),
              Text(
                description,
                style: theme.textTheme.bodyMedium,
              ),
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
          SizedBox(width: AppTokens.spacing.xs),
          Icon(Icons.circle, size: AppTokens.iconSize.sm - 8, color: theme.colorScheme.primary),
          SizedBox(width: spacing.sm),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
