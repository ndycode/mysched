import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/local_notifs.dart';
import '../theme/tokens.dart';
import 'buttons.dart';

/// Battery optimization guidance dialog.
/// Refactored to match _PermissionDialog styling from bootstrap_gate.dart.
class BatteryOptimizationDialog extends StatelessWidget {
  const BatteryOptimizationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final accent = colors.primary;
    final badgeColor = accent.withValues(alpha: isDark ? AppOpacity.shadowAction : AppOpacity.statusBg);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sheet),
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: spacing.edgeInsetsSymmetric(horizontal: spacing.xxl),
      contentPadding: spacing.edgeInsetsAll(spacing.xxl),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero icon badge (matching _PermissionDialog)
          Container(
            height: AppTokens.componentSize.avatarXl,
            width: AppTokens.componentSize.avatarXl,
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: AppTokens.radius.lg,
            ),
            child: Icon(
              Icons.battery_saver_rounded,
              color: accent,
              size: AppTokens.iconSize.xl,
            ),
          ),
          SizedBox(height: spacing.xl),

          // Title (matching _PermissionDialog)
          Text(
            'Allow background usage',
            style: AppTokens.typography.title.copyWith(
              color: colors.onSurface,
              fontWeight: AppTokens.fontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.sm),

          // Subtitle
          Text(
            'Follow these steps to keep reminders running reliably.',
            style: AppTokens.typography.bodySecondary.copyWith(
              color: palette.muted,
            ),
          ),
          SizedBox(height: spacing.xl),

          // Step 1
          _buildStepCard(
            context: context,
            stepNumber: '1',
            title: 'App battery usage',
            description: 'Tap to open battery settings',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: palette.muted,
              size: AppTokens.iconSize.lg,
            ),
          ),
          SizedBox(height: spacing.md),

          // Step 2
          _buildStepCard(
            context: context,
            stepNumber: '2',
            title: 'Allow background usage',
            description: 'Enable for real-time updates',
            trailing: _buildFakeToggle(context),
          ),
          SizedBox(height: spacing.md),

          // Step 3
          _buildStepCard(
            context: context,
            stepNumber: '3',
            title: 'Unrestricted',
            description: 'Choose if available',
            leading: _buildFakeRadio(context),
          ),
          SizedBox(height: spacing.xxl),

          // Buttons (matching _PermissionDialog layout)
          Row(
            children: [
              TertiaryButton(
                label: 'Skip',
                onPressed: () => context.pop(),
                expanded: false,
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: PrimaryButton(
                  label: 'Open settings',
                  expanded: false,
                  minHeight: AppTokens.componentSize.buttonMd,
                  onPressed: () {
                    context.pop();
                    LocalNotifs.openBatteryOptimizationSettings();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required BuildContext context,
    required String stepNumber,
    required String title,
    required String description,
    Widget? leading,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.lg),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surfaceContainerLowest,
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: AppOpacity.border),
          width: AppTokens.componentSize.divider,
        ),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading,
            SizedBox(width: spacing.md),
          ] else ...[
            // Step number badge
            Container(
              height: AppTokens.componentSize.avatarSm,
              width: AppTokens.componentSize.avatarSm,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: AppOpacity.statusBg),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  stepNumber,
                  style: AppTokens.typography.caption.copyWith(
                    color: colors.primary,
                    fontWeight: AppTokens.fontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: spacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTokens.typography.body.copyWith(
                    color: colors.onSurface,
                    fontWeight: AppTokens.fontWeight.medium,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  description,
                  style: AppTokens.typography.caption.copyWith(
                    color: palette.muted,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: spacing.md),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _buildFakeToggle(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spacing = AppTokens.spacing;

    return Container(
      width: AppTokens.componentSize.switchWidth,
      height: AppTokens.componentSize.switchHeight,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: AppTokens.radius.lg,
      ),
      child: Stack(
        children: [
          Positioned(
            right: spacing.micro,
            top: spacing.micro,
            bottom: spacing.micro,
            child: Container(
              width: AppTokens.componentSize.switchThumbSize,
              height: AppTokens.componentSize.switchThumbSize,
              decoration: BoxDecoration(
                color: colors.onPrimary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFakeRadio(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
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
    );
  }
}
