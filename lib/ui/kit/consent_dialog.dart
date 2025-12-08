import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'buttons.dart';
import 'modals.dart';
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

  final agreed = await AppModal.alert<bool>(
    context: context,
    dismissible: false,
    builder: (dialogContext) {
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
                Icons.document_scanner_outlined,
                color: accent,
                size: AppTokens.iconSize.xl,
              ),
            ),
            SizedBox(height: spacing.xl),

            // Title (matching _PermissionDialog)
            Text(
              'Before you scan',
              style: AppTokens.typography.title.copyWith(
                color: colors.onSurface,
                fontWeight: AppTokens.fontWeight.bold,
              ),
            ),
            SizedBox(height: spacing.sm),

            // Description
            Text(
              'By continuing, you agree that MySched may collect data from your scan for research and scheduling purposes only.',
              style: AppTokens.typography.bodySecondary.copyWith(
                color: palette.muted,
              ),
            ),
            SizedBox(height: spacing.md),
            Text(
              'All data will be kept private, anonymized, and securely stored under the Data Privacy Act of 2012.',
              style: AppTokens.typography.bodySecondary.copyWith(
                color: palette.muted,
              ),
            ),
            SizedBox(height: spacing.md),
            Text(
              'Your participation is voluntary, and you can stop anytime. No personal info will be shared.',
              style: AppTokens.typography.bodySecondary.copyWith(
                color: palette.muted,
              ),
            ),
            SizedBox(height: spacing.xxl),

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
                SizedBox(width: spacing.md),
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
