// lib/screens/login_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/constants.dart';
import '../app/routes.dart';
import '../services/auth_service.dart';
import '../services/reminder_scope_store.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';
import 'verify_email_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _saving = false;
  bool _hidePassword = true;
  String? _globalError;
  String? _pendingVerificationEmail;



  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your email';
    }
    if (!value.contains('@')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password';
    }
    if (value.length < AppConstants.minPasswordLengthLogin) {
      return 'Password must be at least ${AppConstants.minPasswordLengthLogin} characters';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _globalError = null;
    });

    try {
      await AuthService.instance.login(
        email: _email.text.trim().toLowerCase(),
        password: _password.text,
      );
      if (!mounted) return;
      final scope = ReminderScopeStore.instance.value;
      context.go(
        AppRoutes.app,
        extra: {'reminderScope': scope.name},
      );
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().toLowerCase();
      if (message.contains('invalid')) {
        _globalError = 'Invalid email or password.';
        _pendingVerificationEmail = null;
      } else if (message.contains('confirm')) {
        _globalError = 'Please confirm your email to continue.';
        _pendingVerificationEmail = _email.text.trim().toLowerCase();
      } else if (message.contains('timeout')) {
        _globalError = 'Network timeout. Try again.';
        _pendingVerificationEmail = null;
      } else {
        _globalError = 'Something went wrong. Try again.';
        _pendingVerificationEmail = null;
      }
      setState(() {});
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openVerificationFlow() async {
    if (_saving) return;
    final email =
        (_pendingVerificationEmail ?? _email.text).trim().toLowerCase();
    if (email.isEmpty) return;
    await context.push(
      AppRoutes.verify,
      extra: VerifyEmailPageArgs(
        email: email,
        fromLogin: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spacing = AppTokens.spacing;

    final form = AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_globalError != null) ...[
              Container(
                padding: spacing.edgeInsetsAll(spacing.md),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: AppOpacity.highlight),
                  borderRadius: AppTokens.radius.md,
                ),
                child: Text(
                  _globalError!,
                  style: AppTokens.typography.body.copyWith(
                    color: colors.error,
                    fontWeight: AppTokens.fontWeight.semiBold,
                  ),
                ),
              ),
              SizedBox(height: spacing.lg),
            ],
            TextFormField(
              controller: _email,
              autofillHints: const [AutofillHints.email],
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'name@example.com',
              ),
              validator: _validateEmail,
            ),
            SizedBox(height: spacing.lg),
            TextFormField(
              controller: _password,
              autofillHints: const [AutofillHints.password],
              obscureText: _hidePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  onPressed: _saving
                      ? null
                      : () => setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(
                    _hidePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              validator: _validatePassword,
            ),
            SizedBox(height: spacing.xs),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'At least ${AppConstants.minPasswordLengthLogin} characters.',
                style: AppTokens.typography.bodySecondary.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(height: spacing.xl),
            PrimaryButton(
              label: 'Sign in',
              loading: _saving,
              loadingLabel: 'Signing in...',
              onPressed: _submit,
              minHeight: AppTokens.componentSize.buttonMd,
            ),
          ],
        ),
      ),
    );

    final bottomActions = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton(
          onPressed: _saving ? null : () => context.push(AppRoutes.register),
          child: const Text('Don\'t have an account? Create one'),
        ),
        if (_pendingVerificationEmail != null) ...[
          SizedBox(height: spacing.sm),
          SecondaryButton(
            label: 'Enter verification code',
            onPressed: _saving ? null : _openVerificationFlow,
            minHeight: AppTokens.componentSize.buttonMd,
          ),
        ],
      ],
    );

    return AuthShell(
      screenName: 'login',
      title: 'Welcome back',
      subtitle: 'Sign in to keep your reminders and schedules in sync.',
      bottom: bottomActions,

      child: form,
    );
  }
}
