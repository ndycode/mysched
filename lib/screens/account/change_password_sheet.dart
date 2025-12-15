// coverage:ignore-file
// lib/screens/change_password_sheet.dart
import 'package:flutter/material.dart';

import '../../app/constants.dart';
import '../../services/auth_service.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _auth = AuthService.instance;
  final _formKey = GlobalKey<FormState>();

  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  bool _saving = false;
  bool _hideCurrent = true;
  bool _hideNext = true;
  bool _hideConfirm = true;
  String? _errorText;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String _mapError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('invalid_password')) {
      return 'Incorrect current password.';
    }
    if (message.contains('same_password')) {
      return 'New password must be different.';
    }
    if (message.contains('weak_password')) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_current.text == _next.text) {
      setState(() => _errorText = 'New password must be different.');
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await _auth.changePassword(
        currentPassword: _current.text,
        newPassword: _next.text,
      );
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Password updated',
        type: AppSnackBarType.success,
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorText = _mapError(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final cardBackground = isDark ? colors.surfaceContainerHigh : colors.surface;

    return ModalShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: spacing.edgeInsetsOnly(
              left: spacing.xl,
              right: spacing.xl,
              top: spacing.xl,
              bottom: spacing.md,
            ),
            child: SheetHeaderRow(
              title: 'Change password',
              subtitle: 'Use a strong password you don\'t reuse elsewhere.',
              icon: Icons.lock_outline_rounded,
              onClose: _saving ? () {} : () => Navigator.of(context).pop(),
            ),
          ),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: spacing.edgeInsetsOnly(
                left: spacing.xl,
                right: spacing.xl,
                bottom: spacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorText != null) ...[
                    DangerCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: palette.danger,
                            size: AppTokens.iconSize.md,
                          ),
                          SizedBox(width: spacing.md),
                          Expanded(
                            child: Text(
                              _errorText!,
                              style: AppTokens.typography.body.copyWith(
                                color: colors.onErrorContainer,
                                fontWeight: AppTokens.fontWeight.semiBold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing.md),
                  ],
                  Text(
                    'Updating your password signs you out of old sessions and keeps reminders secure.',
                    style: AppTokens.typography.bodySecondary.copyWith(
                      color: palette.muted,
                    ),
                  ),
                  SizedBox(height: spacing.lg),
                  _buildForm(theme, colors, spacing),
                ],
              ),
            ),
          ),
          // Action buttons
          Container(
            padding: spacing.edgeInsetsOnly(
              left: spacing.xl,
              right: spacing.xl,
              top: spacing.md,
              bottom: spacing.xl,
            ),
            decoration: BoxDecoration(
              color: cardBackground,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? colors.outline.withValues(alpha: AppOpacity.overlay)
                      : colors.outlineVariant.withValues(alpha: AppOpacity.ghost),
                  width: AppTokens.componentSize.dividerThin,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: _saving ? 'Saving...' : 'Save changes',
                    onPressed: _saving ? null : _submit,
                    minHeight: AppTokens.componentSize.buttonMd,
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: SecondaryButton(
                    label: 'Cancel',
                    onPressed:
                        _saving ? null : () => Navigator.of(context).pop(),
                    minHeight: AppTokens.componentSize.buttonMd,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(ThemeData theme, ColorScheme colors, AppSpacing spacing) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PasswordField(
            label: 'Current password',
            controller: _current,
            obscureText: _hideCurrent,
            enabled: !_saving,
            onToggle: () => setState(() => _hideCurrent = !_hideCurrent),
          ),
          SizedBox(height: spacing.md),
          _PasswordField(
            label: 'New password',
            controller: _next,
            obscureText: _hideNext,
            enabled: !_saving,
            helper: 'At least ${AppConstants.minPasswordLength} characters.',
            onToggle: () => setState(() => _hideNext = !_hideNext),
            validator: (value) {
              if (value == null ||
                  value.length < AppConstants.minPasswordLength) {
                return 'Password must be at least ${AppConstants.minPasswordLength} characters';
              }
              return null;
            },
          ),
          SizedBox(height: spacing.md),
          _PasswordField(
            label: 'Confirm new password',
            controller: _confirm,
            obscureText: _hideConfirm,
            enabled: !_saving,
            onToggle: () => setState(() => _hideConfirm = !_hideConfirm),
            validator: (value) {
              if (value != _next.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.onToggle,
    this.helper,
    this.validator,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggle;
  final String? helper;
  final String? Function(String?)? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        suffixIcon: IconButton(
          onPressed: enabled ? onToggle : null,
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
        ),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) return 'Required';
            return null;
          },
    );
  }
}
