// coverage:ignore-file
// lib/screens/change_email_sheet.dart
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/validation_utils.dart';
import 'verify_email_sheet.dart';

class ChangeEmailSheetArgs {
  const ChangeEmailSheetArgs({required this.currentEmail});

  final String currentEmail;
}

class ChangeEmailSheet extends StatefulWidget {
  const ChangeEmailSheet({super.key, required this.currentEmail});

  final String currentEmail;

  @override
  State<ChangeEmailSheet> createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends State<ChangeEmailSheet> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _saving = false;
  bool _hidePassword = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _email.text = widget.currentEmail;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _mapError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('invalid_password')) {
      return 'Incorrect password. Try again.';
    }
    if (message.contains('email_in_use')) {
      return 'That email is already in use.';
    }
    if (message.contains('same_email')) {
      return 'New email matches current email.';
    }
    if (message.contains('invalid email')) {
      return 'Enter a valid email address.';
    }
    if (message.contains('email_change_failed') ||
        message.contains('edge_fail')) {
      return 'We could not send the verification code. Check your connection and try again in a moment.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    final newEmail = _email.text.trim().toLowerCase();
    if (newEmail == widget.currentEmail.trim().toLowerCase()) {
      setState(() => _errorText = 'New email matches current email.');
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await AuthService.instance.updateEmailWithPassword(
        currentEmail: widget.currentEmail,
        currentPassword: _password.text,
        newEmail: newEmail,
      );
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Enter the 6-digit code we sent to $newEmail to finish updating your email.',
        type: AppSnackBarType.info,
      );
      final result = await AppModal.sheet<bool>(
        context: context,
        dismissible: false,
        builder: (_) => VerifyEmailSheet(
          email: newEmail,
          intent: VerificationIntent.emailChange,
        ),
      );
      if (!mounted) return;
      if (result == true) {
        showAppSnackBar(
          context,
          'Email updated successfully.',
          type: AppSnackBarType.success,
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = _mapError(e));
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
              title: 'Update your email',
              subtitle:
                  'Use an address you check often so verification codes arrive quickly.',
              icon: Icons.mail_outline_rounded,
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
                    'Currently signed in as ${widget.currentEmail}',
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
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _email,
            autofillHints: const [],
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'New email',
              hintText: 'name@example.com',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter your new email';
              }
              if (!ValidationUtils.isValidEmail(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          SizedBox(height: spacing.md),
          TextFormField(
            controller: _password,
            obscureText: _hidePassword,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              labelText: 'Current password',
              suffixIcon: IconButton(
                onPressed: _saving
                    ? null
                    : () => setState(() => _hidePassword = !_hidePassword),
                icon: Icon(
                  _hidePassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );
  }
}
