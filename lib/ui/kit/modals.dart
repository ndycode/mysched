import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'buttons.dart';

/// Global modal configuration for consistent dialogs across the app.
class AppModal {
  /// Shows a standardized confirmation dialog.
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDanger = false,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sheet),
        titlePadding: spacing.edgeInsetsOnly(
          left: spacing.xl,
          right: spacing.xl,
          top: spacing.xl,
          bottom: spacing.sm,
        ),
        contentPadding: spacing.edgeInsetsOnly(
          left: spacing.xl,
          right: spacing.xl,
          bottom: spacing.lg,
        ),
        actionsPadding: spacing.edgeInsetsAll(spacing.lg),
        title: Text(
          title,
          style: AppTokens.typography.title.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        content: Text(
          message,
          style: AppTokens.typography.body.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        actions: [
          SecondaryButton(
            label: cancelLabel,
            onPressed: () {
              onCancel?.call();
              Navigator.of(context).pop(false);
            },
            minHeight: AppTokens.componentSize.buttonSm,
            expanded: false,
          ),
          PrimaryButton(
            label: confirmLabel,
            onPressed: () {
              onConfirm?.call();
              Navigator.of(context).pop(true);
            },
            minHeight: AppTokens.componentSize.buttonSm,
            expanded: false,
            backgroundColor: isDanger ? colors.error : null,
          ),
        ],
      ),
    );
  }

  /// Shows a standardized alert dialog (single action).
  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    String actionLabel = 'OK',
    IconData? icon,
    Color? iconColor,
  }) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sheet),
        titlePadding: spacing.edgeInsetsOnly(
          left: spacing.xl,
          right: spacing.xl,
          top: spacing.xl,
          bottom: spacing.sm,
        ),
        contentPadding: spacing.edgeInsetsOnly(
          left: spacing.xl,
          right: spacing.xl,
          bottom: spacing.lg,
        ),
        actionsPadding: spacing.edgeInsetsAll(spacing.lg),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? colors.primary, size: AppTokens.iconSize.lg),
              SizedBox(width: spacing.md),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTokens.typography.title.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTokens.typography.body.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        actions: [
          PrimaryButton(
            label: actionLabel,
            onPressed: () => Navigator.of(context).pop(),
            minHeight: AppTokens.componentSize.buttonSm,
            expanded: false,
          ),
        ],
      ),
    );
  }

  /// Shows a standardized input dialog.
  static Future<String?> showInputDialog({
    required BuildContext context,
    required String title,
    String? message,
    String? initialValue,
    String? hintText,
    String confirmLabel = 'Save',
    String cancelLabel = 'Cancel',
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final controller = TextEditingController(text: initialValue);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sheet),
        titlePadding: spacing.edgeInsetsOnly(
          left: spacing.xl,
          right: spacing.xl,
          top: spacing.xl,
          bottom: spacing.sm,
        ),
        contentPadding: spacing.edgeInsetsOnly(
          left: spacing.xl,
          right: spacing.xl,
          bottom: spacing.lg,
        ),
        actionsPadding: spacing.edgeInsetsAll(spacing.lg),
        title: Text(
          title,
          style: AppTokens.typography.title.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message != null) ...[
              Text(
                message,
                style: AppTokens.typography.body.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: spacing.lg),
            ],
            TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              autofocus: true,
              decoration: InputDecoration(
                hintText: hintText,
                filled: true,
                fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: AppTokens.radius.md,
                  borderSide: BorderSide(color: colors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppTokens.radius.md,
                  borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppTokens.radius.md,
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
                contentPadding: spacing.edgeInsetsAll(spacing.md),
              ),
            ),
          ],
        ),
        actions: [
          SecondaryButton(
            label: cancelLabel,
            onPressed: () => Navigator.of(context).pop(null),
            minHeight: AppTokens.componentSize.buttonSm,
            expanded: false,
          ),
          PrimaryButton(
            label: confirmLabel,
            onPressed: () => Navigator.of(context).pop(controller.text),
            minHeight: AppTokens.componentSize.buttonSm,
            expanded: false,
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }
}
