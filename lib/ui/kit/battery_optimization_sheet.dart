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
      shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sheet),
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
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
        fontWeight: AppTokens.fontWeight.semiBold,
      ),
    );
  }

  Widget _buildFakeSettingsTile(ThemeData theme) {
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    return Container(
      padding: spacing.edgeInsetsSymmetric(horizontal: spacing.lg, vertical: spacing.lg),
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
                    fontWeight: AppTokens.fontWeight.medium,
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
    final spacing = AppTokens.spacing;
    return Container(
      padding: spacing.edgeInsetsSymmetric(horizontal: spacing.lg, vertical: spacing.md),
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
                    fontWeight: AppTokens.fontWeight.medium,
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
            width: AppTokens.componentSize.switchWidth,
            height: AppTokens.componentSize.switchHeight,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: AppTokens.radius.lg,
            ),
            child: Stack(
              children: [
                Positioned(
                  right: AppTokens.spacing.micro,
                  top: AppTokens.spacing.micro,
                  bottom: AppTokens.spacing.micro,
                  child: Container(
                    width: AppTokens.componentSize.switchThumbSize,
                    height: AppTokens.componentSize.switchThumbSize,
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
    final spacing = AppTokens.spacing;
    return Container(
      padding: spacing.edgeInsetsSymmetric(horizontal: spacing.lg, vertical: spacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: AppTokens.radius.lg,
      ),
      child: Row(
        children: [
          // Fake Radio
          Container(
            width: AppTokens.componentSize.radioOuter,
            height: AppTokens.componentSize.radioOuter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.primary,
                width: AppTokens.componentSize.dividerBold,
              ),
            ),
            child: Center(
              child: Container(
                width: AppTokens.componentSize.radioInner,
                height: AppTokens.componentSize.radioInner,
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
                    fontWeight: AppTokens.fontWeight.medium,
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
