// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/routes.dart';
import '../services/auth_service.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _auth = AuthService.instance;
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();

  bool _hidePassword = true;
  bool _busy = false;
  String? _error;
  bool _completed = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _attemptDelete() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently removes your schedule data. This action cannot be undone.',
        ),
        actions: [
          SecondaryButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(ctx, false),
            minHeight: 44,
            expanded: false,
          ),
          PrimaryButton(
            label: 'Delete',
            onPressed: () => Navigator.pop(ctx, true),
            minHeight: 44,
            expanded: false,
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await _auth.deleteAccount(password: _password.text.trim());
      if (!mounted) return;
      setState(() => _completed = true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _mapError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _mapError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('incorrect password')) {
      return 'Incorrect password. Please try again.';
    }
    if (message.contains('unauthorized') ||
        message.contains('unauthenticated')) {
      return 'Session expired. Please sign in again.';
    }
    if (message.contains('rate limit')) {
      return 'Too many attempts. Wait a moment and try again.';
    }
    return 'Delete failed. Please try again.';
  }

  Future<void> _backToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final helperStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurfaceVariant,
    );

    final backButton = IconButton(
      splashRadius: 22,
      onPressed: _busy ? null : () => context.pop(),
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: colors.primary.withValues(alpha: 0.12),
        child: Icon(
          Icons.arrow_back_rounded,
          color: colors.primary,
          size: AppTokens.iconSize.sm,
        ),
      ),
    );

    Widget passwordForm() {
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _password,
              obscureText: _hidePassword,
              onChanged: (_) {
                if (_error != null) {
                  setState(() => _error = null);
                }
              },
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(
                    _hidePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Password is required'
                  : null,
            ),
            if (_error != null) ...[
              SizedBox(height: spacing.md),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            SizedBox(height: spacing.xl),
            FilledButton(
              onPressed: _busy ? null : _attemptDelete,
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTokens.radius.xl,
                ),
              ),
              child: Text(_busy ? 'Deleting...' : 'Delete account'),
            ),
            SizedBox(height: spacing.sm),
            SecondaryButton(
              label: 'Cancel',
              onPressed: _busy ? null : () => context.pop(),
            ),
            TextButton(
              onPressed: _busy ? null : _backToLogin,
              child: const Text('Sign out instead'),
            ),
          ],
        ),
      );
    }

    final sections = <Widget>[];
    if (_completed) {
      sections.add(
        ScreenSection(
          title: 'Account deleted',
          child: _SuccessView(onBack: _backToLogin),
        ),
      );
    } else {
      sections.add(
        ScreenSection(
          title: 'Before you delete',
          decorated: false,
          child: Container(
            padding: spacing.edgeInsetsAll(spacing.xl),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? colors.surfaceContainerHigh
                  : colors.surface,
              borderRadius: AppTokens.radius.xl,
              border: Border.all(
                color: colors.outlineVariant,
                width: theme.brightness == Brightness.dark ? 1 : 0.5,
              ),
              boxShadow: theme.brightness == Brightness.dark
                  ? null
                  : [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deleting your account removes your schedules, reminders, and offline backups immediately.',
                  style: helperStyle,
                ),
                SizedBox(height: spacing.sm),
                Text(
                  'Export your timetable first if you think you might need it later.',
                  style: helperStyle,
                ),
              ],
            ),
          ),
        ),
      );
      sections.add(
        ScreenSection(
          title: 'Confirm with password',
          decorated: false,
          child: Container(
            padding: spacing.edgeInsetsAll(spacing.xl),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? colors.surfaceContainerHigh
                  : colors.surface,
              borderRadius: AppTokens.radius.xl,
              border: Border.all(
                color: colors.outlineVariant,
                width: theme.brightness == Brightness.dark ? 1 : 0.5,
              ),
              boxShadow: theme.brightness == Brightness.dark
                  ? null
                  : [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: passwordForm(),
          ),
        ),
      );
    }

    return ScreenShell(
      screenName: 'delete_account',
      hero: ScreenHeroCard(
        leading: Align(
          alignment: Alignment.centerLeft,
          child: backButton,
        ),
        title: 'Delete account',
        subtitle: _completed
            ? 'Your data has been removed from MySched.'
            : 'This action cannot be undone.',
      ),
      sections: sections,
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onBack});

  final Future<void> Function() onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary,
              width: 6,
            ),
          ),
          child: Icon(
            Icons.check,
            size: AppTokens.iconSize.display,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: AppTokens.spacing.xl),
        Text(
          'Account deleted',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: AppTokens.spacing.sm),
        Text(
          'Your account and schedule data have been removed.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppTokens.spacing.xxl),
        PrimaryButton(
          label: 'Back to sign in',
          onPressed: onBack,
        ),
      ],
    );
  }
}
