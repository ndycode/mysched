import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../services/auth_service.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';

/// A modal sheet that prompts users to enter their student ID.
/// Used for Google sign-in users who haven't completed their profile.
class StudentIdPromptSheet extends StatefulWidget {
  const StudentIdPromptSheet({
    super.key,
    this.currentName,
  });

  final String? currentName;

  /// Shows the student ID prompt sheet.
  /// Returns true if the profile was successfully updated, false otherwise.
  static Future<bool?> show(
    BuildContext context, {
    String? currentName,
  }) {
    return AppModal.sheet<bool>(
      context: context,
      dismissible: false,
      builder: (_) => StudentIdPromptSheet(currentName: currentName),
    );
  }

  @override
  State<StudentIdPromptSheet> createState() => _StudentIdPromptSheetState();
}

class _StudentIdPromptSheetState extends State<StudentIdPromptSheet> {
  final _form = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  bool _saving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (widget.currentName != null && widget.currentName!.isNotEmpty) {
      _nameController.text = widget.currentName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  String _mapError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('student_id_in_use') || message.contains('already')) {
      return 'This student ID is already in use.';
    }
    if (message.contains('invalid_student_id') ||
        message.contains('profile_invalid_student_id')) {
      return 'Please enter a valid student ID.';
    }
    if (message.contains('invalid_name') ||
        message.contains('profile_invalid_name')) {
      return 'Name must be at least 3 characters.';
    }
    if (message.contains('not_authenticated')) {
      return 'Session expired. Please sign in again.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await AuthService.instance.updateProfileDetails(
        fullName: _nameController.text.trim(),
        studentId: _studentIdController.text.trim().toUpperCase(),
      );

      if (mounted) {
        showAppSnackBar(
          context,
          'Profile updated successfully.',
          type: AppSnackBarType.success,
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorText = _mapError(e));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    final shouldSignOut = await AppModal.confirm(
      context: context,
      title: 'Sign out?',
      message: 'You can complete your profile later by signing in again.',
      confirmLabel: 'Sign out',
    );

    if (shouldSignOut == true && mounted) {
      await AuthService.instance.logout();
      if (mounted) {
        Navigator.of(context).pop(false);
        context.go(AppRoutes.welcome);
      }
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
          // Header (custom without close button - user must complete profile)
          Padding(
            padding: spacing.edgeInsetsOnly(
              left: spacing.xl,
              right: spacing.xl,
              top: spacing.xl,
              bottom: spacing.md,
            ),
            child: _buildHeader(context),
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
                    label: _saving ? 'Saving...' : 'Save changes',
                    onPressed: _saving ? null : _submit,
                    minHeight: AppTokens.componentSize.buttonMd,
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: SecondaryButton(
                    label: 'Sign out',
                    onPressed: _saving ? null : _signOut,
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
            controller: _nameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Neil Daquioag',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Full name is required';
              }
              if (value.trim().length < 3) {
                return 'Name must be at least 3 characters';
              }
              return null;
            },
          ),
          SizedBox(height: spacing.md),
          TextFormField(
            controller: _studentIdController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Student ID',
              hintText: '2022-6767-IC',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Student ID is required';
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final accent = colors.primary;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: AppTokens.componentSize.avatarXl * scale,
          width: AppTokens.componentSize.avatarXl * scale,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: AppOpacity.statusBg),
                accent.withValues(alpha: AppOpacity.overlay),
              ],
            ),
            borderRadius: AppTokens.radius.md,
            border: Border.all(
              color: accent.withValues(alpha: AppOpacity.ghost),
              width: AppTokens.componentSize.dividerThick,
            ),
          ),
          child: Icon(
            Icons.badge_outlined,
            color: accent,
            size: AppTokens.iconSize.xl * scale,
          ),
        ),
        SizedBox(width: AppTokens.spacing.lg * spacingScale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complete your profile',
                style: AppTokens.typography.titleScaled(scale).copyWith(
                  fontWeight: AppTokens.fontWeight.extraBold,
                  letterSpacing: AppLetterSpacing.tight,
                  height: AppLineHeight.headline,
                  color: colors.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppTokens.spacing.xs * spacingScale),
              Text(
                'Add your student ID to finish setting up your account.',
                style: AppTokens.typography.bodyScaled(scale).copyWith(
                  color: palette.muted,
                  fontWeight: AppTokens.fontWeight.medium,
                ),
              ),
            ],
          ),
        ),
        // No close button - user must complete profile
      ],
    );
  }
}
