// coverage:ignore-file
// lib/screens/verify_email_sheet.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../services/auth_service.dart';
import '../../services/reminder_scope_store.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';

enum VerificationIntent { signup, emailChange }

class VerifyEmailSheetArgs {
  const VerifyEmailSheetArgs({
    required this.email,
    this.intent = VerificationIntent.signup,
    this.fromLogin = false,
    this.onVerified,
  });

  final String email;
  final VerificationIntent intent;
  final bool fromLogin;
  final VoidCallback? onVerified;
}

class VerifyEmailSheet extends StatefulWidget {
  const VerifyEmailSheet({
    super.key,
    required this.email,
    this.intent = VerificationIntent.signup,
    this.fromLogin = false,
    this.onVerified,
  });

  final String email;
  final VerificationIntent intent;
  final bool fromLogin;
  final VoidCallback? onVerified;

  @override
  State<VerifyEmailSheet> createState() => _VerifyEmailSheetState();
}

class _VerifyEmailSheetState extends State<VerifyEmailSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();

  bool _verifying = false;
  bool _resending = false;
  String? _errorText;
  int _cooldown = 0;
  Timer? _cooldownTimer;

  bool get _hasEmail => widget.email.trim().isNotEmpty;
  bool get _isEmailChange => widget.intent == VerificationIntent.emailChange;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_handleCodeChanged);
    if (!_hasEmail) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(
          () => _errorText = 'Missing email address for verification.',
        );
      });
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _codeController.removeListener(_handleCodeChanged);
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _handleCodeChanged() {
    if (_errorText != null && _codeController.text.isNotEmpty) {
      setState(() => _errorText = null);
    }
    final trimmed = _codeController.text.trim();
    if (trimmed.length == 6 && !_verifying && !_resending) {
      if (_formKey.currentState?.validate() ?? false) {
        _verify();
      }
    }
  }

  void _startCooldown([int seconds = 45]) {
    _cooldownTimer?.cancel();
    if (!mounted) return;
    setState(() => _cooldown = seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldown <= 1) {
        timer.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown -= 1);
      }
    });
  }

  String? _validateCode(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Enter the 6-digit code';
    }
    if (trimmed.length < 6) {
      return 'Enter all 6 digits';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(trimmed)) {
      return 'Digits only.';
    }
    return null;
  }

  Future<void> _verify() async {
    if (!_hasEmail) {
      setState(() => _errorText = 'Missing email address for verification.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _verifying = true;
      _errorText = null;
    });

    try {
      if (_isEmailChange) {
        await AuthService.instance.verifyEmailChangeCode(
          email: widget.email,
          token: _codeController.text,
        );
      } else {
        await AuthService.instance.verifySignupCode(
          email: widget.email,
          token: _codeController.text,
        );
      }
      if (!mounted) return;
      showAppSnackBar(
        context,
        _isEmailChange
            ? 'Email verified and updated.'
            : 'Email verified. You are now signed in.',
        type: AppSnackBarType.success,
      );
      widget.onVerified?.call();
      if (_isEmailChange) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pop(true);
        _goToApp();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorText = _mapError(error));
    } finally {
      if (mounted) {
        setState(() => _verifying = false);
      }
    }
  }

  Future<void> _resend() async {
    if (!_hasEmail || _cooldown > 0 || _resending) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _resending = true;
      _errorText = null;
    });
    try {
      if (_isEmailChange) {
        await AuthService.instance.resendEmailChangeCode(email: widget.email);
      } else {
        await AuthService.instance.resendSignupCode(email: widget.email);
      }
      if (!mounted) return;
      showAppSnackBar(
        context,
        'A new code was sent to ${widget.email}.',
        type: AppSnackBarType.success,
      );
      _startCooldown();
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorText = _mapError(error));
    } finally {
      if (mounted) {
        setState(() => _resending = false);
      }
    }
  }

  String _mapError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('verify_expired') || message.contains('expired')) {
      return 'Code expired. Tap resend to get a new one.';
    }
    if (message.contains('verify_invalid_code') ||
        message.contains('invalid') ||
        message.contains('otp')) {
      return 'Invalid code. Double-check and try again.';
    }
    if (message.contains('verify_rate_limited') ||
        message.contains('rate') ||
        message.contains('block')) {
      return 'Too many attempts. Wait a moment and try again.';
    }
    if (message.contains('verify_missing_email')) {
      return 'Missing email address for verification.';
    }
    return 'Verification failed. Please try again.';
  }

  void _goBackToLogin() {
    Navigator.of(context).pop();
    context.go(AppRoutes.login);
  }

  void _goToApp() {
    final scope = ReminderScopeStore.instance.value;
    context.go(
      AppRoutes.app,
      extra: {'reminderScope': scope.name},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    final heroSubtitle = _hasEmail
        ? (_isEmailChange
            ? 'Enter the code sent to ${widget.email} to confirm your new address.'
            : 'Enter the 6-digit code we sent to ${widget.email}.')
        : 'Add an email address to receive verification codes.';

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
              title: _isEmailChange
                  ? 'Confirm your new email'
                  : 'Verify your email',
              subtitle: heroSubtitle,
              icon: Icons.mark_email_read_outlined,
              onClose: _verifying ? () {} : () => Navigator.of(context).pop(),
            ),
          ),
          // Tag chip
          Padding(
            padding: spacing.edgeInsetsOnly(
              left: spacing.xl,
              right: spacing.xl,
              bottom: spacing.md,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InfoChip(
                icon: _isEmailChange
                    ? Icons.mail_outline_rounded
                    : Icons.person_add_outlined,
                label: _isEmailChange ? 'Email change' : 'New account',
              ),
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
                  // Verification code section
                  _buildVerificationSection(
                      theme, colors, spacing, isDark, palette),
                  SizedBox(height: spacing.lg),
                  // Resend section
                  _buildResendSection(theme, colors, spacing, isDark, palette),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationSection(
    ThemeData theme,
    ColorScheme colors,
    AppSpacing spacing,
    bool isDark,
    ColorPalette palette,
  ) {
    return SurfaceCard(
      padding: spacing.edgeInsetsAll(spacing.lg),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Verification code',
              style: AppTokens.typography.subtitle.copyWith(
                fontWeight: AppTokens.fontWeight.semiBold,
              ),
            ),
            SizedBox(height: spacing.md),
            if (_errorText != null) ...[
              DangerCard(
                padding: spacing.edgeInsetsAll(spacing.lg),
                margin: EdgeInsets.only(bottom: spacing.lg),
                child: Row(
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
                        style: AppTokens.typography.bodySecondary.copyWith(
                          color: palette.danger,
                          fontWeight: AppTokens.fontWeight.medium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Text(
              'Email',
              style: AppTokens.typography.caption.copyWith(
                color: palette.muted,
              ),
            ),
            SizedBox(height: spacing.xs),
            SelectableText(
              _hasEmail ? widget.email : 'Missing email',
              style: AppTokens.typography.subtitle.copyWith(
                color: _hasEmail ? colors.onSurface : palette.danger,
                fontWeight: AppTokens.fontWeight.semiBold,
              ),
            ),
            SizedBox(height: spacing.lg),
            TextFormField(
              controller: _codeController,
              focusNode: _codeFocus,
              enabled: !_verifying && !_resending,
              autofillHints: const [AutofillHints.oneTimeCode],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: AppTokens.typography.title.copyWith(
                letterSpacing: AppLetterSpacing.otpCode,
                fontWeight: AppTokens.fontWeight.semiBold,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: const InputDecoration(
                labelText: '6-digit code',
                hintText: '123456',
              ),
              textInputAction: TextInputAction.done,
              validator: _validateCode,
              onChanged: (_) {
                _formKey.currentState?.validate();
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
              onFieldSubmitted: (_) => _verify(),
            ),
            SizedBox(height: spacing.md),
            Text(
              'Codes expire after a few minutes. Enter digits only.',
              style: AppTokens.typography.caption.copyWith(
                color: palette.muted,
              ),
            ),
            SizedBox(height: spacing.xxl),
            PrimaryButton(
              label: _verifying ? 'Verifying...' : 'Verify email',
              onPressed:
                  (!_hasEmail || _verifying || _resending) ? null : _verify,
              minHeight: AppTokens.componentSize.buttonMd,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResendSection(
    ThemeData theme,
    ColorScheme colors,
    AppSpacing spacing,
    bool isDark,
    ColorPalette palette,
  ) {
    final resendLabel =
        _cooldown > 0 ? 'Resend code in $_cooldown s' : 'Send another code';

    return SurfaceCard(
      padding: spacing.edgeInsetsAll(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Need a new code?',
            style: AppTokens.typography.subtitle.copyWith(
              fontWeight: AppTokens.fontWeight.semiBold,
            ),
          ),
          SizedBox(height: spacing.md),
          Text(
            'Make sure you can access ${widget.email}. Check spam or promotions folders if you do not see the email.',
            style: AppTokens.typography.body.copyWith(
              color: palette.muted,
              height: AppTypography.bodyLineHeight,
            ),
          ),
          SizedBox(height: spacing.lg),
          SecondaryButton(
            label: resendLabel,
            onPressed: (!_hasEmail || _cooldown > 0 || _resending || _verifying)
                ? null
                : _resend,
            minHeight: AppTokens.componentSize.buttonMd,
          ),
          SizedBox(height: spacing.md),
          SecondaryButton(
            label: 'Back to login',
            onPressed: _verifying ? null : _goBackToLogin,
            minHeight: AppTokens.componentSize.buttonMd,
          ),
        ],
      ),
    );
  }
}
