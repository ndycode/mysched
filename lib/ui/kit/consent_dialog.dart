import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

Future<bool> ensureScanConsent(BuildContext context) async {
  if (await ScanConsent.hasConsented()) return true;

  if (!context.mounted) return false;

  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final spacing = AppTokens.spacing;

  final agreed = await AppModal.alert<bool>(
    context: context,
    dismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sheet),
        contentPadding: spacing.edgeInsetsAll(spacing.xl),
        title: Text(
          'Before you scan',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: AppTokens.fontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By continuing, you agree that MySched may collect data from your scan for research and scheduling purposes only.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.md),
            Text(
              'All data will be kept private, anonymized, and securely stored under the Data Privacy Act of 2012.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.md),
            Text(
              'Your participation is voluntary, and you can stop anytime. No personal info will be shared.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.lg),
            Text(
              'Do you want to continue scanning?',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: AppTokens.fontWeight.semiBold,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        actionsPadding: spacing.edgeInsetsAll(spacing.md),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              minimumSize: Size(0, AppTokens.componentSize.buttonSm),
              shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xxl),
            ),
            child: const Text('Agree & Continue'),
          ),
        ],
      );
    },
  );

  if (agreed == true) {
    await ScanConsent.saveConsent();
    return true;
  }
  return false;
}
