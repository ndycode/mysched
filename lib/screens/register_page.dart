import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../services/auth_service.dart';
import '../services/telemetry_service.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';
import '../utils/formatters.dart';
import '../utils/validation_utils.dart';
import 'verify_email_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _studentId = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _saving = false;
  bool _hidePassword = true;
  String? _globalError;

  @override
  void dispose() {
    _name.dispose();
    _studentId.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your full name';
    }
    return null;
  }

  String? _validateStudentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your student ID';
    }
    final formatted = value.trim().toUpperCase();
    if (!ValidationUtils.isValidStudentId(formatted)) {
      return 'Format must be YYYY-XXXX-IC';
    }
    return null;
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
      return 'Enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _globalError = null;
    });

    final normalizedEmail = _email.text.trim().toLowerCase();

    try {
      await AuthService.instance.register(
        fullName: _name.text.trim(),
        studentId: _studentId.text.trim().toUpperCase(),
        email: normalizedEmail,
        password: _password.text,
      );

      if (!mounted) return;
      if (!mounted) return;
      context.go(
        AppRoutes.verify,
        extra: VerifyEmailPageArgs(email: normalizedEmail),
      );
    } catch (error, stackTrace) {
      TelemetryService.instance.recordEvent(
        'auth_register_failed',
        data: {'error': error.toString(), 'stack': stackTrace.toString()},
      );
      setState(() => _globalError = _mapError(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _mapError(Object error) {
    final message = error.toString().toLowerCase();
    final hasEmailOrIdCode = message.contains('emailorid');
    final studentIdConflict =
        message.contains('student id') || message.contains('student_id');
    if (studentIdConflict || (hasEmailOrIdCode && message.contains('student'))) {
      return 'Student ID already in use';
    }
    final emailConflict = hasEmailOrIdCode ||
        message.contains('email_in_use') ||
        message.contains('user already registered') ||
        message.contains('already registered') ||
        message.contains('already exists') ||
        (message.contains('email') &&
            (message.contains('use') || message.contains('registered')));
    if (emailConflict) {
      return 'Email already in use';
    }
    if (message.contains('password')) {
      return 'Password does not meet requirements.';
    }
    return 'Registration failed. Please try again.';
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
                  color: colors.error.withValues(alpha: 0.08),
                  borderRadius: AppTokens.radius.md,
                ),
                child: Text(
                  _globalError!,
                  style: AppTokens.typography.body.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: spacing.lg),
            ],
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(
                labelText: 'Full name',
              ),
              validator: _validateName,
            ),
            SizedBox(height: spacing.lg),
            TextFormField(
              controller: _studentId,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.characters,
              autofillHints: const [AutofillHints.username],
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z-]')),
                StudentIdInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'Student ID',
                helperText: 'Format: YYYY-XXXX-IC',
              ),
              validator: _validateStudentId,
            ),
            SizedBox(height: spacing.lg),
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
              obscureText: _hidePassword,
              autofillHints: const [AutofillHints.newPassword],
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
                'At least 8 characters.',
                style: AppTokens.typography.bodySecondary.copyWith(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(height: spacing.xl),
            PrimaryButton(
              label: 'Create account',
              loading: _saving,
              loadingLabel: 'Creating account...',
              onPressed: _submit,
              minHeight: 48,
            ),
          ],
        ),
      ),
    );

    final bottomActions = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SecondaryButton(
          label: 'Already have an account? Sign in',
          onPressed:
              _saving ? null : () => context.go(AppRoutes.login),
          minHeight: 48,
        ),
      ],
    );

    return AuthShell(
      screenName: 'register',
      title: 'Create your MySched account',
      subtitle: 'Join MySched to organize your schedule and reminders.',
      bottom: bottomActions,
      child: form,
    );
  }
}
