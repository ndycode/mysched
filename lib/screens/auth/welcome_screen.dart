import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../app/routes.dart';
import '../../services/auth_service.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';

/// Clean welcome screen with illustration and authentication options.
/// Uses the original layout while keeping button styling aligned to shared tokens.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isGoogleLoading = false;

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    if (_isGoogleLoading) return;
    
    setState(() => _isGoogleLoading = true);
    
    try {
      await AuthService.instance.signInWithGoogle();
      if (mounted) {
        // ignore: use_build_context_synchronously - guarded by mounted check
        context.go(AppRoutes.app);
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
        
        // ignore: use_build_context_synchronously - guarded by mounted check
        showAppSnackBar(context, message, type: AppSnackBarType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  void _openTerms(BuildContext context) {
    AppModal.legal(
      context: context,
      title: AppConstants.termsLinkText,
      content: AppConstants.termsAndConditionsContent,
      icon: Icons.description_outlined,
    );
  }

  void _openPrivacy(BuildContext context) {
    AppModal.legal(
      context: context,
      title: AppConstants.privacyLinkText,
      content: AppConstants.privacyPolicyContent,
      icon: Icons.privacy_tip_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);
    final screenSize = MediaQuery.of(context).size;

    return AppScaffold(
      screenName: 'welcome',
      safeArea: false,
      backgroundColor: isDark ? palette.surface : Colors.white,
      body: Container(
        color: isDark ? palette.surface : Colors.white,
        child: SafeArea(
          top: false,
          bottom: false, // Let background extend to navigation bar
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).padding.top +
                              spacing.xxxl,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: spacing.sm),
                          child: ScreenBrandHeader(
                            showChevron: false,
                            height: AppTokens.componentSize.listItemLg,
                            textStyle: AppTokens.typography.title.copyWith(
                              fontWeight: AppTokens.fontWeight.bold,
                              color: colors.primary,
                              letterSpacing: AppLetterSpacing.snug,
                            ),
                          ),
                        ),
                        const Spacer(flex: 1),
                        Container(
                          height: constraints.maxHeight * 0.25,
                          padding:
                              EdgeInsets.symmetric(horizontal: spacing.xxl),
                          child: Center(
                            child: Image.asset(
                              AppConstants.welcomeIllustrationAsset,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return _FallbackIllustration(
                                  primaryColor: colors.primary,
                                  size: Size(
                                    screenSize.width * 0.7,
                                    screenSize.height * 0.3,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: spacing.xs),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: spacing.quad),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                AppConstants.welcomeHeadline,
                                textAlign: TextAlign.center,
                                style: AppTokens.typography.display.copyWith(
                                  fontWeight: AppTokens.fontWeight.extraBold,
                                  color: colors.primary,
                                  letterSpacing: AppLetterSpacing.tight,
                                ),
                              ),
                              SizedBox(height: spacing.sm),
                              Text(
                                AppConstants.welcomeSubtitle,
                                textAlign: TextAlign.center,
                                style:
                                    AppTokens.typography.bodySecondary.copyWith(
                                  color: palette.muted,
                                  height: AppLineHeight.relaxed,
                                ),
                              ),
                              SizedBox(height: spacing.xxl * spacingScale),
                              PrimaryButton(
                                label: AppConstants.loginWithEmailLabel,
                                icon: Icons.mail_outline_rounded,
                                onPressed: () => context.push(AppRoutes.login),
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
                                onPressed: _isGoogleLoading
                                    ? null
                                    : () => _handleGoogleSignIn(context),
                                minHeight: AppTokens.componentSize.buttonLg,
                                expanded: true,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(flex: 1),
                        SizedBox(height: spacing.md * spacingScale),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: spacing.quad),
                          child: _TermsText(
                            palette: palette,
                            scale: scale,
                            onTermsTap: () => _openTerms(context),
                            onPrivacyTap: () => _openPrivacy(context),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).padding.bottom + spacing.xxxl),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Or divider with gradient lines.
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

/// Terms and privacy text with tappable links.
class _TermsText extends StatelessWidget {
  const _TermsText({
    required this.palette,
    required this.scale,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  final ColorPalette palette;
  final double scale;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTokens.typography.captionScaled(scale).copyWith(
          color: palette.muted,
          height: AppLineHeight.relaxed,
        );
    final linkStyle = textStyle.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: palette.muted,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppConstants.termsAgreementPrefix,
          style: textStyle,
          textAlign: TextAlign.center,
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTermsTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.spacing.xs,
                  vertical: AppTokens.spacing.sm,
                ),
                child: Text(AppConstants.termsLinkText, style: linkStyle),
              ),
            ),
            Text(AppConstants.andText, style: textStyle),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onPrivacyTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.spacing.xs,
                  vertical: AppTokens.spacing.sm,
                ),
                child: Text('${AppConstants.privacyLinkText}.', style: linkStyle),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Fallback illustration.
class _FallbackIllustration extends StatelessWidget {
  const _FallbackIllustration({
    required this.primaryColor,
    required this.size,
  });

  final Color primaryColor;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveProvider.scale(context);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Center(
        child: Icon(
          Icons.schedule_rounded,
          size: AppTokens.iconSize.display * scale,
          color: primaryColor.withValues(alpha: AppOpacity.medium),
        ),
      ),
    );
  }
}
