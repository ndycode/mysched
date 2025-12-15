import 'package:flutter/material.dart';

import '../../app/constants.dart';
import '../theme/tokens.dart';
import 'layout.dart';
import 'responsive_provider.dart';

/// Shared, centered layout for auth flows with a branded top bar.
///
/// Follows the dashboard screen's design patterns:
/// - Card structure with proper border radius and shadow
/// - Hero-style header with brand accent
/// - Consistent spacing gaps using design tokens
/// - Typography hierarchy matching dashboard cards
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.screenName,
    required this.title,
    required this.subtitle,
    required this.child,
    this.bottom,
    this.headerAction,
  });

  final String screenName;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? bottom;
  final Widget? headerAction;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    // Plain text MySched branding
    final brandBadge = Text(
      AppConstants.appName,
      style: AppTokens.typography.titleScaled(scale).copyWith(
        color: colors.primary,
        fontWeight: AppTokens.fontWeight.bold,
      ),
    );

    // Title section matching dashboard card typography hierarchy
    final header = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        brandBadge,
        SizedBox(height: spacing.xl * spacingScale),
        if (headerAction != null)
          Align(
            alignment: Alignment.topRight,
            child: headerAction!,
          ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTokens.typography.titleScaled(scale).copyWith(
            fontWeight: AppTokens.fontWeight.bold,
            letterSpacing: AppLetterSpacing.snug,
            color: colors.onSurface,
          ),
        ),
        SizedBox(height: spacing.sm * spacingScale),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTokens.typography.bodyScaled(scale).copyWith(
            color: palette.muted,
            height: AppTypography.bodyLineHeight,
          ),
        ),
      ],
    );

    // Card container with improved padding
    final card = Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.xxl * spacingScale,
        vertical: spacing.xxxl * spacingScale,
      ),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: isDark
              ? colors.outline.withValues(alpha: AppOpacity.overlay)
              : colors.outline,
          width: isDark
              ? AppTokens.componentSize.divider
              : AppTokens.componentSize.dividerThin,
        ),
        boxShadow: isDark
            ? null
            : [
                AppTokens.shadow.modal(
                  colors.shadow.withValues(alpha: AppOpacity.border),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          SizedBox(height: spacing.xxl * spacingScale),
          child,
          if (bottom != null) ...[
            SizedBox(height: spacing.xxl * spacingScale),
            bottom!,
          ],
        ],
      ),
    );

    const maxWidth = AppLayout.sheetMaxWidth;
    final physics = theme.platform == TargetPlatform.iOS
        ? const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          )
        : const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          );

    return AppScaffold(
      screenName: screenName,
      safeArea: false, // Edge-to-edge mode
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: AppTokens.componentSize.dividerThin,
        scrolledUnderElevation: 0,
        backgroundColor: colors.surface,
        title: null,
      ),
      body: AppBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // When keyboard is visible, viewInsets.bottom > 0
            final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
            
            return SingleChildScrollView(
              physics: physics,
              // When keyboard is open, keep scroll position at top to prevent crop
              reverse: false,
              child: ConstrainedBox(
                // Only enforce minHeight when keyboard is not visible
                constraints: BoxConstraints(
                  minHeight: keyboardVisible ? 0 : constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: keyboardVisible
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.xl,
                          vertical: spacing.xxxl,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: maxWidth),
                          child: card,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
