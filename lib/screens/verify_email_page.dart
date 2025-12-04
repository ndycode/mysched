import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../services/auth_service.dart';
import '../services/reminder_scope_store.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';

enum VerificationIntent { signup, emailChange }

class VerifyEmailPageArgs {
  const VerifyEmailPageArgs({
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

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({
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
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
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
    if (trimmed.length != 6) {
      return 'Enter the 6-digit code';
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
        if (context.canPop()) {
          context.pop(true);
        } else {
          _goToApp();
        }
      } else {
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
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spacing = AppTokens.spacing;
    final helperStyle = AppTokens.typography.bodySecondary.copyWith(
      color: colors.onSurfaceVariant,
    );

    final heroSubtitle = _hasEmail
        ? (_isEmailChange
            ? 'Enter the code sent to  to confirm your new address.'
            : 'Enter the 6-digit code we sent to .')
        : 'Add an email address to receive verification codes.';

    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorText != null)
            Container(
              padding: spacing.edgeInsetsAll(spacing.md),
              margin: EdgeInsets.only(bottom: spacing.lg),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.08),
                borderRadius: AppTokens.radius.md,
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: colors.error),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Text(
                      _errorText!,
                      style: AppTokens.typography.body.copyWith(
                        color: colors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Text(
            'Email',
            style: AppTokens.typography.caption.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.xs),
          SelectableText(
            _hasEmail ? widget.email : 'Missing email',
            style: AppTokens.typography.title.copyWith(
              color: _hasEmail ? colors.onSurface : colors.error,
            ),
          ),
          SizedBox(height: spacing.lg),
          TextFormField(
            controller: _codeController,
            focusNode: _codeFocus,
            autofillHints: const [AutofillHints.oneTimeCode],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: AppTokens.typography.title.copyWith(
              letterSpacing: 6,
              fontWeight: FontWeight.w600,
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
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
            },
            onFieldSubmitted: (_) => _verify(),
          ),
          SizedBox(height: spacing.md),
          Text(
            'Codes expire after a few minutes. Enter digits only.',
            style: helperStyle,
          ),
        SizedBox(height: spacing.xl),
        PrimaryButton(
          label: _verifying ? 'Verifying...' : 'Verify email',
          onPressed:
              (!_hasEmail || _verifying || _resending) ? null : _verify,
          minHeight: 48,
        ),
        ],
      ),
    );

    final resendLabel =
        _cooldown > 0 ? 'Resend code in $_cooldown s' : 'Send another code';

    return ScreenShell(
      screenName: 'verify_email',
      hero: ScreenHeroCard(
        title: _isEmailChange ? 'Confirm your new email' : 'Verify your email',
        subtitle: heroSubtitle,
        trailing: IconButton(
          splashRadius: 22,
          onPressed: _verifying
              ? null
              : () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.login);
                  }
                },
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: colors.primary.withValues(alpha: 0.12),
            child: Icon(Icons.close_rounded, color: colors.primary, size: AppTokens.iconSize.sm),
          ),
        ),
        chips: [
          Chip(
            label: Text(
              _isEmailChange ? 'Email change' : 'New account',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
      sections: [
        ScreenSection(
          title: 'Verification code',
          child: form,
        ),
        ScreenSection(
          title: 'Need a new code?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Make sure you can access . Check spam or promotions folders if you do not see the email.',
                style: helperStyle,
              ),
              SizedBox(height: spacing.lg),
              FilledButton.tonal(
                onPressed:
                    (!_hasEmail || _cooldown > 0 || _resending || _verifying)
                        ? null
                        : _resend,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(resendLabel),
              ),
              SizedBox(height: spacing.lg),
              SecondaryButton(
                label: 'Back to login',
                onPressed: _verifying ? null : _goBackToLogin,
                minHeight: 48,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _goToApp() {
    final scope = ReminderScopeStore.instance.value;
    context.go(
      AppRoutes.app,
      extra: {'reminderScope': scope.name},
    );
  }
}
