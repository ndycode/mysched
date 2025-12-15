// ignore_for_file: unused_local_variable, unused_import
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../ui/kit/kit.dart';
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
    return MessageCard(
      variant: MessageCardVariant.surface,
      icon: icon,
      title: title,
      message: message,
      primaryLabel: primaryLabel,
      onPrimary: onPrimary,
      secondaryLabel: secondaryLabel,
      onSecondary: onSecondary,
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
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final text = lastSynced == null
        ? 'You are viewing your saved schedule offline.'
        : 'You are viewing your saved schedule from '
            '${DateFormat('MMM d - h:mm a').format(lastSynced!)}.';
    return SurfaceCard(
      padding: AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.lg + AppTokens.spacing.micro),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: colors.secondary),
          SizedBox(width: AppTokens.spacing.md),
          Expanded(
            child: Text(
              '$text We\'ll refresh automatically when you\'re back online.',
              style: AppTokens.typography.body.copyWith(
                color: palette.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
