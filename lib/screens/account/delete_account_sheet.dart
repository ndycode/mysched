// coverage:ignore-file
// lib/screens/delete_account_sheet.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/routes.dart';
import '../../services/auth_service.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/card_styles.dart';
import '../../ui/theme/tokens.dart';

class DeleteAccountSheet extends StatefulWidget {
  const DeleteAccountSheet({super.key});

  @override
  State<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<DeleteAccountSheet> {
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

    final confirmed = await AppModal.confirm(
      context: context,
      title: 'Delete account?',
      message:
          'This permanently removes your schedule data. This action cannot be undone.',
      confirmLabel: 'Delete',
      isDanger: true,
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
    Navigator.of(context).pop(true);
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final media = MediaQuery.of(context);
    final cardBackground = elevatedCardBackground(theme, solid: true);
    final borderColor = elevatedCardBorder(theme, solid: true);
    final borderWidth = elevatedCardBorderWidth(theme);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final maxHeight = media.size.height * AppLayout.sheetMaxHeightRatio;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: spacing.xl,
          right: spacing.xl,
          bottom: media.viewInsets.bottom + spacing.xl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppLayout.sheetMaxWidth,
              maxHeight: maxHeight,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: AppTokens.radius.xl,
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        AppTokens.shadow.modal(
                          colors.shadow.withValues(alpha: AppOpacity.border),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: AppTokens.radius.xl,
                child: Material(
                  type: MaterialType.transparency,
                  child: _completed
                      ? _buildSuccessContent(theme, colors, spacing, palette)
                      : _buildDeleteContent(theme, colors, spacing,
                          cardBackground, isDark, palette),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteContent(
    ThemeData theme,
    ColorScheme colors,
    AppSpacing spacing,
    Color cardBackground,
    bool isDark,
    ColorPalette palette,
  ) {
    return Column(
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
            title: 'Delete account',
            subtitle: 'This action cannot be undone.',
            icon: Icons.delete_forever_outlined,
            iconColor: palette.danger,
            onClose: _busy ? () {} : () => Navigator.of(context).pop(),
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
                // Warning section
                Container(
                  padding: spacing.edgeInsetsAll(spacing.lg),
                  decoration: BoxDecoration(
                    color: palette.danger.withValues(alpha: AppOpacity.dim),
                    borderRadius: AppTokens.radius.lg,
                    border: Border.all(
                      color: palette.danger.withValues(alpha: AppOpacity.ghost),
                      width: AppTokens.componentSize.dividerThin,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deleting your account removes your schedules, reminders, and offline backups immediately.',
                        style: AppTokens.typography.body.copyWith(
                          color: palette.muted,
                          height: AppTypography.bodyLineHeight,
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      Text(
                        'Export your timetable first if you think you might need it later.',
                        style: AppTokens.typography.body.copyWith(
                          color: palette.muted,
                          height: AppTypography.bodyLineHeight,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.lg),
                // Password form
                _buildForm(theme, colors, spacing, palette),
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
                child: DestructiveButton(
                  label: 'Delete account',
                  onPressed: _busy ? null : _attemptDelete,
                  loading: _busy,
                  minHeight: AppTokens.componentSize.buttonMd,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: SecondaryButton(
                  label: 'Cancel',
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                  minHeight: AppTokens.componentSize.buttonMd,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent(
    ThemeData theme,
    ColorScheme colors,
    AppSpacing spacing,
    ColorPalette palette,
  ) {
    return Padding(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: spacing.xl),
          Container(
            width: AppTokens.componentSize.previewSm,
            height: AppTokens.componentSize.previewSm,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: palette.positive,
                width: AppTokens.componentSize.strokeHeavy,
              ),
            ),
            child: Icon(
              Icons.check,
              size: AppTokens.iconSize.display,
              color: palette.positive,
            ),
          ),
          SizedBox(height: spacing.xl),
          Text(
            'Account deleted',
            style: AppTokens.typography.title.copyWith(
              fontWeight: AppTokens.fontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            'Your account and schedule data have been removed.',
            textAlign: TextAlign.center,
            style: AppTokens.typography.body.copyWith(
              color: palette.muted,
            ),
          ),
          SizedBox(height: spacing.xxl),
          PrimaryButton(
            label: 'Back to sign in',
            onPressed: _backToLogin,
            minHeight: AppTokens.componentSize.buttonMd,
          ),
          SizedBox(height: spacing.lg),
        ],
      ),
    );
  }

  Widget _buildForm(ThemeData theme, ColorScheme colors, AppSpacing spacing,
      ColorPalette palette) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Confirm with password',
            style: AppTokens.typography.subtitle.copyWith(
              fontWeight: AppTokens.fontWeight.semiBold,
            ),
          ),
          SizedBox(height: spacing.md),
          TextFormField(
            controller: _password,
            obscureText: _hidePassword,
            enabled: !_busy,
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
              style: AppTokens.typography.bodySecondary.copyWith(
                color: palette.danger,
                fontWeight: AppTokens.fontWeight.medium,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
