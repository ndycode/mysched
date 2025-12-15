// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/constants.dart';
import '../../app/routes.dart';
import '../../services/auth_service.dart';
import '../../services/reminder_scope_store.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/validation_utils.dart';
import '../account/verify_email_screen.dart';

/// Key for storing remembered email in SharedPreferences
const _kRememberEmailKey = 'auth.remember_email';
const _kRememberMeKey = 'auth.remember_me';

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
  bool _rememberMe = false;
  String? _globalError;
  String? _pendingVerificationEmail;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString(_kRememberEmailKey);
      final rememberMe = prefs.getBool(_kRememberMeKey) ?? false;
      if (!mounted) return;
      setState(() {
        _rememberMe = rememberMe;
        if (savedEmail != null && savedEmail.isNotEmpty) {
          _email.text = savedEmail;
        }
      });
    } catch (_) {
      // Ignore errors loading preferences
    }
  }

  Future<void> _saveRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString(_kRememberEmailKey, _email.text.trim().toLowerCase());
        await prefs.setBool(_kRememberMeKey, true);
      } else {
        await prefs.remove(_kRememberEmailKey);
        await prefs.setBool(_kRememberMeKey, false);
      }
    } catch (_) {
      // Ignore errors saving preferences
    }
  }

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
    if (!ValidationUtils.looksLikeEmail(value)) {
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
      // Save remember me preference on successful login
      await _saveRememberMe();
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
      extra: VerifyEmailScreenArgs(
        email: email,
        fromLogin: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final colors = theme.colorScheme;

    final form = AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_globalError != null) ...[
              ErrorBanner(message: _globalError!),
              SizedBox(height: spacing.xl),
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
            SizedBox(height: spacing.xl),
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
            SizedBox(height: spacing.lg),
            // Remember me - styled tappable row
            GestureDetector(
              onTap: _saving
                  ? null
                  : () => setState(() => _rememberMe = !_rememberMe),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  // Custom styled checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _rememberMe
                          ? colors.primary
                          : Colors.transparent,
                      borderRadius: AppTokens.radius.xs,
                      border: Border.all(
                        color: _rememberMe
                            ? colors.primary
                            : palette.muted.withValues(alpha: AppOpacity.medium),
                        width: 2,
                      ),
                    ),
                    child: _rememberMe
                        ? Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: colors.onPrimary,
                          )
                        : null,
                  ),
                  SizedBox(width: spacing.md),
                  Text(
                    'Remember me',
                    style: AppTokens.typography.body.copyWith(
                      color: _rememberMe ? colors.onSurface : palette.muted,
                      fontWeight: _rememberMe
                          ? AppTokens.fontWeight.medium
                          : AppTokens.fontWeight.regular,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.xxl),
            PrimaryButton(
              label: 'Sign in',
              loading: _saving,
              loadingLabel: 'Signing in...',
              onPressed: _submit,
              minHeight: AppTokens.componentSize.buttonLg,
            ),
          ],
        ),
      ),
    );

    final bottomActions = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TertiaryButton(
          label: 'Don\'t have an account? Create one',
          onPressed: _saving ? null : () => context.push(AppRoutes.register),
          expanded: false,
        ),
        if (_pendingVerificationEmail != null) ...[
          SizedBox(height: spacing.md),
          SecondaryButton(
            label: 'Enter verification code',
            onPressed: _saving ? null : _openVerificationFlow,
            minHeight: AppTokens.componentSize.buttonLg,
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
