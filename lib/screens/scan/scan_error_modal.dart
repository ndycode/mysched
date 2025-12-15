import 'package:flutter/material.dart';

import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';

/// Result from the scan error modal.
enum ScanErrorAction {
  retry,
  retake,
  manualEntry,
}

/// A modal dialog shown when OCR scan fails.
/// Provides options to retry, retake photo, or enter section manually.
class ScanErrorModal extends StatelessWidget {
  const ScanErrorModal({
    super.key,
    required this.errorMessage,
    this.isLowLight = false,
  });

  final String errorMessage;
  final bool isLowLight;

  /// Shows the modal and returns the user's chosen action.
  static Future<ScanErrorAction?> show(
    BuildContext context, {
    required String errorMessage,
    bool isLowLight = false,
  }) {
    return showDialog<ScanErrorAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ScanErrorModal(
        errorMessage: errorMessage,
        isLowLight: isLowLight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: spacing.edgeInsetsAll(spacing.xl),
      child: DialogShell(
        child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hero icon
                    Container(
                      width: AppTokens.componentSize.stateIconLarge,
                      height: AppTokens.componentSize.stateIconLarge,
                      decoration: BoxDecoration(
                        color: palette.danger.withValues(alpha: AppOpacity.ghost),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: AppTokens.componentSize.stateIconInnerLarge,
                        color: palette.danger,
                      ),
                    ),
                    SizedBox(height: spacing.lg),
                    // Title
                    Text(
                      'Scan failed',
                      style: AppTokens.typography.title.copyWith(
                        fontWeight: AppTokens.fontWeight.semiBold,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: spacing.sm),
                    // Message
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: AppTokens.typography.body.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    // Low-light tip
                    if (isLowLight) ...[
                      SizedBox(height: spacing.lg),
                      Container(
                        padding: spacing.edgeInsetsSymmetric(
                          horizontal: spacing.md,
                          vertical: spacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: colors.tertiaryContainer.withValues(alpha: AppOpacity.subtle),
                          borderRadius: AppTokens.radius.sm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: AppTokens.iconSize.sm,
                              color: colors.tertiary,
                            ),
                            SizedBox(width: spacing.xs),
                            Flexible(
                              child: Text(
                                'Try using flash for better results',
                                style: AppTokens.typography.caption.copyWith(
                                  color: colors.tertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: spacing.xl),
                    // Action buttons - horizontal layout
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            onPressed: () => Navigator.of(context).pop(ScanErrorAction.retry),
                            label: 'Retry',
                            icon: Icons.refresh_rounded,
                            minHeight: AppTokens.componentSize.buttonMd,
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        Expanded(
                          child: SecondaryButton(
                            onPressed: () => Navigator.of(context).pop(ScanErrorAction.retake),
                            label: 'Retake',
                            icon: Icons.camera_alt_outlined,
                            minHeight: AppTokens.componentSize.buttonMd,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.sm),
                    // Manual entry - full width primary
                    PrimaryButton(
                      onPressed: () => Navigator.of(context).pop(ScanErrorAction.manualEntry),
                      label: 'Enter section manually',
                      icon: Icons.edit_outlined,
                      expanded: true,
                      minHeight: AppTokens.componentSize.buttonMd,
                    ),
                  ],
                ),
              ),
            );
  }
}
