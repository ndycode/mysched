import 'package:flutter/material.dart';

import '../../app/constants.dart';
import '../theme/tokens.dart';
import 'layout.dart';

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

    // Hero-style brand header matching dashboard's ScreenBrandHeader
    final brandBadge = Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.md,
        vertical: spacing.sm - spacing.micro,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: AppOpacity.dim),
        borderRadius: AppTokens.radius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_month_rounded,
            size: AppTokens.iconSize.sm,
            color: colors.primary,
          ),
          SizedBox(width: spacing.xs + spacing.micro),
          Text(
            AppConstants.appName,
            style: AppTokens.typography.caption.copyWith(
              color: colors.primary,
              fontWeight: AppTokens.fontWeight.bold,
              letterSpacing: AppLetterSpacing.wider,
            ),
          ),
        ],
      ),
    );

    // Title section matching dashboard card typography hierarchy
    final header = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        brandBadge,
        SizedBox(height: spacing.xl),
        if (headerAction != null)
          Align(
            alignment: Alignment.topRight,
            child: headerAction!,
          ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTokens.typography.title.copyWith(
            fontWeight: AppTokens.fontWeight.bold,
            letterSpacing: AppLetterSpacing.snug,
            color: colors.onSurface,
          ),
        ),
        SizedBox(height: spacing.sm),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTokens.typography.body.copyWith(
            color: palette.muted,
            height: AppTypography.bodyLineHeight,
          ),
        ),
      ],
    );

    // Card container matching dashboard's _DashboardSummaryCard structure
    final card = Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
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
                BoxShadow(
                  color: colors.shadow.withValues(alpha: AppOpacity.veryFaint),
                  blurRadius: AppTokens.shadow.lg,
                  offset: AppShadowOffset.sm,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          SizedBox(height: spacing.xl),
          child,
          if (bottom != null) ...[
            SizedBox(height: spacing.xl),
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
            return SingleChildScrollView(
              physics: physics,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.xl,
                      vertical: spacing.xxxl,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: maxWidth),
                      child: card,
                    ),
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
