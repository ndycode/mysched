// coverage:ignore-file
// lib/screens/change_password_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/constants.dart';
import '../services/auth_service.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
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
      context.pop(true);
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

    final backButton = IconButton(
      splashRadius: AppInteraction.splashRadius,
      onPressed: _saving ? null : () => context.pop(),
      icon: CircleAvatar(
        radius: AppInteraction.iconButtonContainerRadius,
        backgroundColor: colors.primary.withValues(alpha: AppOpacity.overlay),
        child: Icon(
          Icons.arrow_back_rounded,
          color: colors.primary,
          size: AppTokens.iconSize.sm,
        ),
      ),
    );

    final helperStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurfaceVariant,
    );

    Widget passwordForm() {
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PasswordField(
              label: 'Current password',
              controller: _current,
              obscureText: _hideCurrent,
              onToggle: () => setState(() => _hideCurrent = !_hideCurrent),
            ),
            SizedBox(height: spacing.md),
            _PasswordField(
              label: 'New password',
              controller: _next,
              obscureText: _hideNext,
              helper: 'At least ${AppConstants.minPasswordLength} characters.',
              onToggle: () => setState(() => _hideNext = !_hideNext),
              validator: (value) {
                if (value == null || value.length < AppConstants.minPasswordLength) {
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
              onToggle: () => setState(() => _hideConfirm = !_hideConfirm),
              validator: (value) {
                if (value != _next.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            if (_errorText != null) ...[
              SizedBox(height: spacing.md),
              Text(
                _errorText!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.error,
                  fontWeight: AppTokens.fontWeight.semiBold,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ScreenShell(
      screenName: 'change_password',
      hero: ScreenHeroCard(
        leading: Align(
          alignment: Alignment.centerLeft,
          child: backButton,
        ),
        title: 'Change password',
        subtitle: 'Use a strong password you don\'t reuse elsewhere.',
      ),
      sections: [
        ScreenSection(
          title: 'New password',
          subtitle: 'At least ${AppConstants.minPasswordLength} characters with letters, numbers, or symbols.',
          decorated: false,
          child: Container(
            padding: spacing.edgeInsetsAll(spacing.xxl),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? colors.surfaceContainerHigh
                  : colors.surface,
              borderRadius: AppTokens.radius.xl,
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? colors.outline.withValues(alpha: AppOpacity.overlay)
                    : colors.outline,
                width: theme.brightness == Brightness.dark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
              ),
              boxShadow: theme.brightness == Brightness.dark
                  ? null
                  : [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: AppOpacity.veryFaint),
                        blurRadius: AppTokens.shadow.lg,
                        offset: AppShadowOffset.sm,
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Updating your password signs you out of old sessions and keeps reminders secure.',
                  style: helperStyle,
                ),
                SizedBox(height: spacing.lg),
                passwordForm(),
                SizedBox(height: spacing.xl),
                PrimaryButton(
                  label: _saving ? 'Saving...' : 'Save changes',
                  onPressed: _saving ? null : _submit,
                  minHeight: AppTokens.componentSize.buttonMd,
                ),
                SizedBox(height: spacing.sm),
                SecondaryButton(
                  label: 'Cancel',
                  onPressed: _saving ? null : () => context.pop(),
                  minHeight: AppTokens.componentSize.buttonMd,
                ),
              ],
            ),
          ),
        ),
      ],
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
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggle;
  final String? helper;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        suffixIcon: IconButton(
          onPressed: onToggle,
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
