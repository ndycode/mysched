import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/local_notifs.dart';
import '../theme/tokens.dart';
import 'buttons.dart';

class BatteryOptimizationDialog extends StatelessWidget {
  const BatteryOptimizationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xl),
      backgroundColor: colors.surface,
      insetPadding: spacing.edgeInsetsSymmetric(horizontal: spacing.xxl),
      contentPadding: spacing.edgeInsetsAll(spacing.xl),
      actionsPadding: EdgeInsets.fromLTRB(
        spacing.xl,
        spacing.md,
        spacing.xl,
        spacing.md,
      ),
      title: Text(
        'Allow background usage',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(theme, '1. Tap App battery usage'),
            SizedBox(height: spacing.sm),
            _buildFakeSettingsTile(theme),
            SizedBox(height: spacing.lg),

            _buildStepHeader(theme, '2. Enable Allow background usage'),
            SizedBox(height: spacing.sm),
            _buildFakeToggle(theme),
            SizedBox(height: spacing.lg),

            _buildStepHeader(theme, '3. Choose Unrestricted if available'),
            SizedBox(height: spacing.sm),
            _buildFakeRadio(theme),
          ],
        ),
      ),
      actions: [
        PrimaryButton(
          label: 'Open settings',
          expanded: true,
          onPressed: () {
            context.pop();
            LocalNotifs.openBatteryOptimizationSettings();
          },
        ),
      ],
    );
  }

  Widget _buildStepHeader(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildFakeSettingsTile(ThemeData theme) {
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: AppTokens.radius.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App battery usage',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: AppTokens.spacing.xs),
                Text(
                  'No battery use since last full charge',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFakeToggle(ThemeData theme) {
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: AppTokens.radius.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Allow background usage',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: AppTokens.spacing.xs),
                Text(
                  'Enable for real-time updates, disable to save battery',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppTokens.spacing.lg),
          Icon(
            Icons.chevron_right_rounded,
            color: colors.onSurfaceVariant,
            size: AppTokens.iconSize.lg,
          ),
          SizedBox(width: AppTokens.spacing.lg),
          // Fake Toggle Switch
          Container(
            width: 52,
            height: 32,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: AppTokens.radius.lg,
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 2,
                  top: 2,
                  bottom: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.onPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: AppTokens.iconSize.sm,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFakeRadio(ThemeData theme) {
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: AppTokens.radius.lg,
      ),
      child: Row(
        children: [
          // Fake Radio
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.primary,
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SizedBox(width: AppTokens.spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unrestricted',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: AppTokens.spacing.xs),
                Text(
                  'Allow battery usage in background without restrictions. May use more battery.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
