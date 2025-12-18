// coverage:ignore-file
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/validation_utils.dart';
import 'reset_password_verify_sheet.dart';

/// Bottom sheet for requesting a password reset email.
class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({super.key, this.initialEmail});

  /// Pre-fill the email field if known.
  final String? initialEmail;

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  final _auth = AuthService.instance;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  bool _sending = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!ValidationUtils.isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String _mapError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('rate') || message.contains('limit')) {
      return 'Too many requests. Please wait a moment and try again.';
    }
    if (message.contains('not found') || message.contains('no user')) {
      // Don't reveal if email exists for security
      return 'If this email exists, you\'ll receive a reset code.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _sending = true;
      _errorText = null;
    });

    final email = _emailController.text.trim();

    try {
      await _auth.resetPassword(email: email);
      if (!mounted) return;
      
      // Show info and open verification sheet
      showAppSnackBar(
        context,
        'Enter the 6-digit code we sent to $email to reset your password.',
        type: AppSnackBarType.info,
      );
      
      final result = await AppModal.sheet<bool>(
        context: context,
        dismissible: false,
        builder: (_) => ResetPasswordVerifySheet(email: email),
      );
      
      if (!mounted) return;
      if (result == true) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) return;
      // For security, show success even on certain errors
      final message = error.toString().toLowerCase();
      if (message.contains('not found') || message.contains('no user')) {
        // Still open verification sheet for security (don't reveal if email exists)
        showAppSnackBar(
          context,
          'Enter the 6-digit code we sent to $email to reset your password.',
          type: AppSnackBarType.info,
        );
        
        final result = await AppModal.sheet<bool>(
          context: context,
          dismissible: false,
          builder: (_) => ResetPasswordVerifySheet(email: email),
        );
        
        if (!mounted) return;
        if (result == true) {
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() => _errorText = _mapError(error));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final cardBackground =
        isDark ? colors.surfaceContainerHigh : colors.surface;

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
              title: 'Reset password',
              subtitle: 'Enter your email and we\'ll send you a 6-digit code.',
              icon: Icons.lock_reset_rounded,
              onClose:
                  _sending ? () {} : () => Navigator.of(context).pop(false),
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
                    'We\'ll send a 6-digit code to reset your password. The code expires in a few minutes.',
                    style: AppTokens.typography.bodySecondary.copyWith(
                      color: palette.muted,
                    ),
                  ),
                  SizedBox(height: spacing.lg),
                  _buildForm(spacing),
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
                      : colors.outlineVariant
                          .withValues(alpha: AppOpacity.ghost),
                  width: AppTokens.componentSize.dividerThin,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: _sending ? 'Sending...' : 'Send code',
                    onPressed: _sending ? null : _submit,
                    minHeight: AppTokens.componentSize.buttonMd,
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: SecondaryButton(
                    label: 'Cancel',
                    onPressed: _sending
                        ? null
                        : () => Navigator.of(context).pop(),
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

  Widget _buildForm(AppSpacing spacing) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email address',
              hintText: 'you@example.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            enabled: !_sending,
            autofillHints: const [AutofillHints.email],
            validator: _validateEmail,
            onFieldSubmitted: (_) => _submit(),
          ),
        ],
      ),
    );
  }
}
