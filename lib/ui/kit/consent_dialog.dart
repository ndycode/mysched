import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'buttons.dart';
import 'modals.dart';
import 'responsive_provider.dart';
import '../theme/tokens.dart';

class ScanConsent {
  static const _consentKey = 'scan_consent_agreed';

  static Future<bool> hasConsented() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  static Future<void> saveConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, true);
  }
}

/// Consent dialog refactored to match _PermissionDialog styling.
Future<bool> ensureScanConsent(BuildContext context) async {
  if (await ScanConsent.hasConsented()) return true;

  if (!context.mounted) return false;

  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;
  final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
  final spacing = AppTokens.spacing;
  final accent = colors.primary;
  final badgeColor = accent.withValues(alpha: isDark ? AppOpacity.shadowAction : AppOpacity.statusBg);

  // Get responsive scale factors (1.0 on standard ~390dp screens)
  final scale = ResponsiveProvider.scale(context);
  final spacingScale = ResponsiveProvider.spacing(context);

  final agreed = await AppModal.alert<bool>(
    context: context,
    dismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sheet),
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        insetPadding: spacing.edgeInsetsSymmetric(horizontal: spacing.xxl * spacingScale),
        contentPadding: spacing.edgeInsetsAll(spacing.xxl * spacingScale),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero icon badge (matching _PermissionDialog)
            Container(
              height: AppTokens.componentSize.avatarXl * scale,
              width: AppTokens.componentSize.avatarXl * scale,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: AppTokens.radius.lg,
              ),
              child: Icon(
                Icons.document_scanner_outlined,
                color: accent,
                size: AppTokens.iconSize.xl * scale,
              ),
            ),
            SizedBox(height: spacing.xl * spacingScale),

            // Title (matching _PermissionDialog)
            Text(
              'Before you scan',
              style: AppTokens.typography.titleScaled(scale).copyWith(
                color: colors.onSurface,
                fontWeight: AppTokens.fontWeight.bold,
              ),
            ),
            SizedBox(height: spacing.sm * spacingScale),

            // Description
            Text(
              'By continuing, you agree that MySched may collect data from your scan for research and scheduling purposes only.',
              style: AppTokens.typography.captionScaled(scale).copyWith(
                color: palette.muted,
              ),
            ),
            SizedBox(height: spacing.md * spacingScale),
            Text(
              'All data will be kept private, anonymized, and securely stored under the Data Privacy Act of 2012.',
              style: AppTokens.typography.captionScaled(scale).copyWith(
                color: palette.muted,
              ),
            ),
            SizedBox(height: spacing.md * spacingScale),
            Text(
              'Your participation is voluntary, and you can stop anytime. No personal info will be shared.',
              style: AppTokens.typography.captionScaled(scale).copyWith(
                color: palette.muted,
              ),
            ),
            SizedBox(height: spacing.xxl * spacingScale),

            // Buttons (1 row, 2 buttons - primary left, cancel right)
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Agree & Continue',
                    expanded: false,
                    minHeight: AppTokens.componentSize.buttonMd,
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ),
                SizedBox(width: spacing.md * spacingScale),
                TertiaryButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  expanded: false,
                ),
              ],
            ),
          ],
        ),
      );
    },
  );

  if (agreed == true) {
    await ScanConsent.saveConsent();
    return true;
  }
  return false;
}
