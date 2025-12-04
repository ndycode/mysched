// coverage:ignore-file
// lib/screens/change_email_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../services/auth_service.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';
import 'verify_email_page.dart';

class ChangeEmailPageArgs {
  const ChangeEmailPageArgs({required this.currentEmail});

  final String currentEmail;
}

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key, required this.currentEmail});

  final String currentEmail;

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
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
      return 'We couldn’t send the verification code. Check your connection and try again in a moment.';
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
      final result = await context.push(
        AppRoutes.verify,
        extra: VerifyEmailPageArgs(
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
        context.pop(true);
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

    final backButton = IconButton(
      splashRadius: 22,
      onPressed: _saving ? null : () => context.pop(),
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: colors.primary.withValues(alpha: 0.12),
        child: Icon(
          Icons.arrow_back_rounded,
          color: colors.primary,
          size: 18,
        ),
      ),
    );

    final descriptionStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurfaceVariant,
    );

    Widget formFields() {
      return Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _email,
              // Avoid auto-filling the "new email" with the current account.
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
                if (!value.contains('@')) {
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
            if (_errorText != null) ...[
              SizedBox(height: spacing.md),
              Text(
                _errorText!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ScreenShell(
      screenName: 'change_email',
      hero: ScreenHeroCard(
        leading: Align(
          alignment: Alignment.centerLeft,
          child: backButton,
        ),
        title: 'Update your email',
        subtitle:
            'Use an address you check often so verification codes arrive quickly.',
      ),
      sections: [
        ScreenSection(
          title: 'New address',
          subtitle: 'We\'ll send a 6-digit code to confirm the change.',
          decorated: false,
          child: Container(
            padding: spacing.edgeInsetsAll(spacing.xl),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? colors.surfaceContainerHigh
                  : Colors.white,
              borderRadius: AppTokens.radius.xl,
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? colors.outline.withValues(alpha: 0.12)
                    : const Color(0xFFE5E5E5),
                width: theme.brightness == Brightness.dark ? 1 : 0.5,
              ),
              boxShadow: theme.brightness == Brightness.dark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Currently signed in as ${widget.currentEmail}',
                  style: descriptionStyle,
                ),
                SizedBox(height: spacing.md),
                formFields(),
                SizedBox(height: spacing.xl),
                PrimaryButton(
                  label: _saving ? 'Saving...' : 'Save changes',
                  onPressed: _saving ? null : _submit,
                  minHeight: 48,
                ),
                SizedBox(height: spacing.sm),
                SecondaryButton(
                  label: 'Cancel',
                  onPressed: _saving ? null : () => context.pop(),
                  minHeight: 48,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
