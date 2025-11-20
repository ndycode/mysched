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
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height -
        (AppTokens.spacing.xxxl * 2 + media.padding.top + media.padding.bottom);

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: maxHeight.clamp(360.0, double.infinity),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppTokens.radius.xl,
            border: Border.all(color: colors.outline.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: colors.outline.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 24),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Privacy policy',
                        style: AppTokens.typography.title.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
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
                            CardX(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: colors.primary
                                          .withValues(alpha: 0.12),
                                      borderRadius: AppTokens.radius.sm,
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Icon(
                                      Icons.lock_outline,
                                      color: colors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: spacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Your schedule stays yours',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  _PrivacyTile(
                                    icon: Icons.camera_alt_outlined,
                                    title: 'Camera',
                                    description:
                                        'Capture your student card for OCR scanning. Images stay on device—only extracted schedule data is saved.',
                                  ),
                                  SizedBox(height: 16),
                                  _PrivacyTile(
                                    icon: Icons.photo_library_outlined,
                                    title: 'Photos (read only)',
                                    description:
                                        'Let you pick an existing card image instead of rescanning. Required only on older Android versions.',
                                  ),
                                  SizedBox(height: 16),
                                  _PrivacyTile(
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
                                  colors.surface,
                                  colors.surface.withValues(alpha: 0.0),
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
                                  colors.surface,
                                  colors.surface.withValues(alpha: 0.0),
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

  static Future<void> _openFullPolicy(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Full privacy policy'),
        content: const Text(
          'A downloadable PDF is coming soon. For now, the full policy is mirrored in Settings → Updates.',
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
          const SizedBox(width: 4),
          Icon(Icons.circle, size: 8, color: theme.colorScheme.primary),
          SizedBox(width: spacing.sm),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
