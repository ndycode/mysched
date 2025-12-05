// ignore_for_file: unused_local_variable, unused_import
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../ui/kit/kit.dart';
import '../../ui/theme/card_styles.dart';
import '../../ui/theme/tokens.dart';

class ScheduleMessageCard extends StatelessWidget {
  const ScheduleMessageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cardBackground = elevatedCardBackground(theme);
    final borderColor = elevatedCardBorder(theme);

    return Container(
      padding: AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.xl),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colors.surfaceContainerHigh
            : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: colors.outline.withValues(alpha: theme.brightness == Brightness.dark ? AppOpacity.overlay : AppOpacity.divider),
          width: theme.brightness == Brightness.dark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
        ),
        boxShadow: theme.brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: AppOpacity.faint),
                  blurRadius: AppTokens.shadow.md,
                  offset: AppShadowOffset.sm,
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
                    fontWeight: AppTokens.fontWeight.bold,
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
          if (primaryLabel != null || secondaryLabel != null) ...[
            SizedBox(height: AppTokens.spacing.lg),
            Row(
              children: [
                if (primaryLabel != null) ...[
                  PrimaryButton(
                    label: primaryLabel!,
                    onPressed: onPrimary,
                    minHeight: AppTokens.componentSize.buttonMd,
                  ),
                ],
                if (secondaryLabel != null) ...[
                  if (primaryLabel != null) SizedBox(width: AppTokens.spacing.md),
                  SecondaryButton(
                    label: secondaryLabel!,
                    onPressed: onSecondary,
                    minHeight: AppTokens.componentSize.buttonMd,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.lastSynced});

  final DateTime? lastSynced;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = lastSynced == null
        ? 'You are viewing your saved schedule offline.'
        : 'You are viewing your saved schedule from '
            '${DateFormat('MMM d - h:mm a').format(lastSynced!)}.';
    return Container(
      padding: AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.lg + AppTokens.spacing.micro),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: AppOpacity.ghost),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: colors.secondary),
          SizedBox(width: AppTokens.spacing.md),
          Expanded(
            child: Text(
              '$text We\'ll refresh automatically when you\'re back online.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
