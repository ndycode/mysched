import 'dart:io';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../app/routes.dart';
import '../../services/auth_service.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthMode { login, register }

/// Unified authentication screen that mirrors the provided blueprint using
/// global design tokens for spacing, typography, and colors.
class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    this.initialMode = AuthMode.login,
  });

  final AuthMode initialMode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AuthMode _mode;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isReturningUser = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _mode == AuthMode.login ? 0 : 1,
    );
    _checkReturningUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _studentIdController.dispose();
    _confirmPasswordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode, {bool fromTab = false}) {
    FocusScope.of(context).unfocus();
    setState(() {
      _mode = mode;
      _formKey.currentState?.reset();
    });
    if (!fromTab) {
      final targetIndex = mode == AuthMode.login ? 0 : 1;
      if (_tabController.index != targetIndex) {
        _tabController.index = targetIndex;
      }
    }
  }

  Future<void> _checkReturningUser() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLoggedInBefore = prefs.getBool('auth.has_logged_in_before') ?? false;
    if (mounted) {
      setState(() => _isReturningUser = hasLoggedInBefore);
    }
  }

  Future<void> _markAsReturningUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth.has_logged_in_before', true);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_mode == AuthMode.login) {
        await AuthService.instance.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        await _markAsReturningUser();
        if (mounted) context.go(AppRoutes.app);
      } else {
        await AuthService.instance.register(
          fullName: _nameController.text.trim(),
          studentId: _studentIdController.text.trim().toUpperCase(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (mounted) {
          context.push(AppRoutes.verify,
              extra: {'email': _emailController.text.trim()});
        }
      }
    } catch (e) {
      if (mounted) {
        String message =
            _mode == AuthMode.login ? 'Login failed' : 'Registration failed';
        final errorMsg = e.toString().toLowerCase();
        if (_mode == AuthMode.login) {
          if (errorMsg.contains('invalid_credentials') ||
              errorMsg.contains('wrong password')) {
            message = 'Invalid email or password';
          }
        } else {
          if (errorMsg.contains('email_in_use') ||
              errorMsg.contains('already registered')) {
            message = 'This email is already registered';
          } else if (errorMsg.contains('student_id_in_use')) {
            message = 'This student ID is already in use';
          }
        }
        showAppSnackBar(context, message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;
    
    setState(() => _isGoogleLoading = true);
    
    try {
      await AuthService.instance.signInWithGoogle();
      if (mounted) {
        // Check if profile is complete (has student_id)
        final isComplete = await AuthService.instance.isProfileComplete();
        if (mounted) {
          if (isComplete) {
            context.go(AppRoutes.app);
          } else {
            // Go to app with flag to show profile completion modal
            context.go(AppRoutes.app, extra: {'showProfilePrompt': true});
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().toLowerCase();
        String message = 'Google Sign In failed';
        
        if (msg.contains('cancelled') || msg.contains('canceled')) {
          // User cancelled - don't show error
          setState(() => _isGoogleLoading = false);
          return;
        } else if (msg.contains('network')) {
          message = 'Network error. Please check your connection.';
        } else if (msg.contains('email_exists')) {
          message = 'An account with this email already exists.';
        }
        
        showAppSnackBar(context, message);
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  void _handleAppleSignIn() async {
    if (_isAppleLoading) return;
    
    setState(() => _isAppleLoading = true);
    
    try {
      await AuthService.instance.signInWithApple();
      if (mounted) {
        // Check if profile is complete (has student_id)
        final isComplete = await AuthService.instance.isProfileComplete();
        if (mounted) {
          if (isComplete) {
            context.go(AppRoutes.app);
          } else {
            // Go to app with flag to show profile completion modal
            context.go(AppRoutes.app, extra: {'showProfilePrompt': true});
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().toLowerCase();
        String message = 'Apple Sign In failed';
        
        if (msg.contains('cancelled') || msg.contains('canceled')) {
          // User cancelled - don't show error
          setState(() => _isAppleLoading = false);
          return;
        } else if (msg.contains('not_available')) {
          message = 'Apple Sign In is not available on this device.';
        } else if (msg.contains('network')) {
          message = 'Network error. Please check your connection.';
        } else if (msg.contains('email_exists')) {
          message = 'An account with this email already exists.';
        }
        
        showAppSnackBar(context, message);
      }
    } finally {
      if (mounted) {
        setState(() => _isAppleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);
    final canPop = Navigator.canPop(context);
    final heroTitle =
        _mode == AuthMode.login 
            ? (_isReturningUser ? 'Welcome back!' : 'Welcome!')
            : 'Create your account';
    final heroSubtitle = _mode == AuthMode.login
        ? "Let's stop pretending you'll remember."
        : 'You vs. time — round two.';

    return ScreenShell(
      screenName: 'auth_${_mode.name}',
      hero: ScreenBrandHeader(
        showChevron: false,
        height: AppTokens.componentSize.listItemLg,
        textStyle: AppTokens.typography.title.copyWith(
          fontWeight: AppTokens.fontWeight.bold,
          letterSpacing: AppLetterSpacing.snug,
          color: colors.primary,
        ),
        leading: canPop
            ? IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                padding: EdgeInsets.zero,
                splashRadius: AppInteraction.splashRadius,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: colors.primary,
                  size: AppTokens.iconSize.lg,
                ),
              )
            : null,
      ),
      sections: [
        ScreenSection(
          decorated: false,
          child: Padding(
            padding: spacing.edgeInsetsAll(spacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heroTitle,
                  style: AppTokens.typography.headline.copyWith(
                    fontWeight: AppTokens.fontWeight.extraBold,
                    letterSpacing: AppLetterSpacing.tight,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  heroSubtitle,
                  style: AppTokens.typography.bodySecondary.copyWith(
                    color: palette.muted,
                    height: AppLineHeight.relaxed,
                  ),
                ),
                SizedBox(height: spacing.lg),
                Container(
                  padding: spacing.edgeInsetsAll(spacing.micro),
                  decoration: BoxDecoration(
                    color: palette.surfaceVariant,
                    borderRadius: AppTokens.radius.sm,
                  ),
                  child: TabBar(
                    controller: _tabController,
                    onTap: (index) => _switchMode(
                      index == 0 ? AuthMode.login : AuthMode.register,
                      fromTab: true,
                    ),
                    indicator: BoxDecoration(
                      color: palette.surface,
                      borderRadius: AppTokens.radius.sm,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: palette.onSurface,
                    unselectedLabelColor: palette.muted,
                    labelStyle: AppTokens.typography.bodySecondary.copyWith(
                      fontWeight: AppTokens.fontWeight.semiBold,
                    ),
                    unselectedLabelStyle:
                        AppTokens.typography.bodySecondary.copyWith(
                      fontWeight: AppTokens.fontWeight.medium,
                    ),
                    labelPadding: EdgeInsets.zero,
                    dividerHeight: 0,
                    tabs: [
                      Tab(
                        height: AppTokens.componentSize.buttonSm,
                        text: 'Log In',
                      ),
                      Tab(
                        height: AppTokens.componentSize.buttonSm,
                        text: 'Sign Up',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.xl),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_mode == AuthMode.register) ...[
                        _buildTextField(
                          controller: _nameController,
                          labelText: 'Full Name',
                          hint: 'Neil Daquioag',
                          textInputAction: TextInputAction.next,
                          validator: (v) => v!.isEmpty ? 'Full name is required' : null,
                        ),
                        SizedBox(height: spacing.lg),
                        _buildTextField(
                          controller: _studentIdController,
                          labelText: 'Student ID',
                          hint: '2022-6767-IC',
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.next,
                          validator: (v) => v!.isEmpty ? 'Student ID is required' : null,
                        ),
                        SizedBox(height: spacing.lg),
                      ],
                      _buildTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hint: 'severity@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            v!.contains('@') ? null : 'Please enter a valid email address',
                      ),
                      SizedBox(height: spacing.lg),
                      _buildTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hint: 'Min 6 characters',
                        obscureText: _obscurePassword,
                        onToggleVisibility: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        textInputAction: _mode == AuthMode.login
                            ? TextInputAction.done
                            : TextInputAction.next,
                        validator: (v) =>
                            v != null && v.length >= 6 ? null : 'Password must be at least 6 characters',
                      ),
                      if (_mode == AuthMode.register) ...[
                        SizedBox(height: spacing.lg),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          hint: 'Re-enter your password',
                          obscureText: _obscureConfirmPassword,
                          onToggleVisibility: () => setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                          textInputAction: TextInputAction.done,
                          validator: (v) =>
                              v != _passwordController.text ? 'Passwords do not match' : null,
                        ),
                      ],
                    ],
                  ),
                ),
                if (_mode == AuthMode.login) ...[
                  SizedBox(height: spacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TertiaryButton(
                      label: 'Forgot password?',
                      onPressed: () {
                        context.push(
                          AppRoutes.forgotPassword,
                          extra: {'email': _emailController.text},
                        );
                      },
                      expanded: false,
                      minHeight: AppTokens.componentSize.buttonSm,
                    ),
                  ),
                ],
                SizedBox(height: spacing.xxl * spacingScale),
                PrimaryButton(
                  label: _mode == AuthMode.login ? 'Log In' : 'Sign Up',
                  onPressed: _isLoading ? null : _handleSubmit,
                  loading: _isLoading,
                  minHeight: AppTokens.componentSize.buttonLg,
                  expanded: true,
                ),
                SizedBox(height: spacing.md * spacingScale),
                _OrDivider(
                  palette: palette,
                  scale: scale,
                  spacing: spacing,
                ),
                SizedBox(height: spacing.md * spacingScale),
                SecondaryButton(
                  label: AppConstants.continueWithGoogleLabel,
                  leading: _isGoogleLoading
                      ? SizedBox(
                          width: AppTokens.iconSize.md * scale,
                          height: AppTokens.iconSize.md * scale,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primary,
                          ),
                        )
                      : GoogleLogo(
                          size: AppTokens.iconSize.md * scale,
                        ),
                  onPressed: (_isLoading || _isGoogleLoading || _isAppleLoading) 
                      ? null 
                      : _handleGoogleSignIn,
                  minHeight: AppTokens.componentSize.buttonLg,
                  expanded: true,
                ),
                // Apple Sign-In - only displayed on iOS
                if (Platform.isIOS) ...[
                  SizedBox(height: spacing.md * spacingScale),
                  SecondaryButton(
                    label: 'Continue with Apple',
                    leading: _isAppleLoading
                        ? SizedBox(
                            width: AppTokens.iconSize.md * scale,
                            height: AppTokens.iconSize.md * scale,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.primary,
                            ),
                          )
                        : Icon(
                            Icons.apple,
                            size: AppTokens.iconSize.md * scale,
                          ),
                    onPressed: (_isLoading || _isGoogleLoading || _isAppleLoading) 
                        ? null 
                        : _handleAppleSignIn,
                    minHeight: AppTokens.componentSize.buttonLg,
                    expanded: true,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
      padding: spacing.edgeInsetsOnly(
        left: spacing.xl,
        right: spacing.xl,
        top: MediaQuery.of(context).padding.top + spacing.xxxl,
        bottom: spacing.quad,
      ),
      safeArea: false,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? labelText,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final colors = Theme.of(context).colorScheme;
    final spacing = AppTokens.spacing;
    final typography = AppTokens.typography;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      style: typography.body.copyWith(color: palette.onSurface),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: typography.body.copyWith(
          color: palette.muted,
        ),
        floatingLabelStyle: typography.caption.copyWith(
          color: colors.primary,
          fontWeight: AppTokens.fontWeight.medium,
        ),
        hintText: hint,
        hintStyle: typography.body.copyWith(
          color: palette.mutedSecondary,
        ),
        filled: true,
        fillColor: palette.surface,
        contentPadding: spacing.edgeInsetsSymmetric(
          horizontal: spacing.xl,
          vertical: spacing.md,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTokens.radius.popup,
          borderSide: BorderSide(
            color: colors.outline,
            width: AppTokens.componentSize.divider,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTokens.radius.popup,
          borderSide: BorderSide(
            color: colors.primary,
            width: AppTokens.componentSize.dividerBold,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppTokens.radius.popup,
          borderSide: BorderSide(
            color: palette.danger,
            width: AppTokens.componentSize.divider,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppTokens.radius.popup,
          borderSide: BorderSide(
            color: palette.danger,
            width: AppTokens.componentSize.dividerBold,
          ),
        ),
        suffixIcon: onToggleVisibility != null
            ? IconButton(
                onPressed: onToggleVisibility,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: AppTokens.iconSize.lg,
                  color: palette.mutedSecondary,
                ),
              )
            : null,
      ),
      validator: validator,
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({
    required this.palette,
    required this.scale,
    required this.spacing,
  });

  final ColorPalette palette;
  final double scale;
  final AppSpacing spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  palette.outline.withValues(alpha: AppOpacity.medium),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
          child: Text(
            AppConstants.orDividerText,
            style: AppTokens.typography.captionScaled(scale).copyWith(
                  color: palette.muted,
                ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  palette.outline.withValues(alpha: AppOpacity.medium),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
