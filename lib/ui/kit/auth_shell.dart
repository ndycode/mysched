import 'package:flutter/material.dart';

import '../../app/constants.dart';
import '../theme/tokens.dart';
import 'layout.dart';

/// Shared, centered layout for auth flows with a branded top bar.
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
    final textTheme = theme.textTheme;

    final header = Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppConstants.appName,
              textAlign: TextAlign.center,
              style: AppTokens.typography.subtitle.copyWith(
                color: colors.primary,
                fontWeight: AppTokens.fontWeight.bold,
                letterSpacing: AppLetterSpacing.normal,
              ),
            ),
            SizedBox(height: spacing.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                    fontWeight: AppTokens.fontWeight.bold,
                    color: colors.onSurface,
                  ) ??
                  AppTokens.typography.headline
                      .copyWith(color: colors.onSurface),
            ),
            SizedBox(height: spacing.sm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: AppTypography.bodyLineHeight,
                  ) ??
                  AppTokens.typography.body.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        if (headerAction != null)
          Align(
            alignment: Alignment.topRight,
            child: headerAction!,
          ),
      ],
    );

    final card = Container(
      padding: spacing.edgeInsetsAll(spacing.xl),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colors.surfaceContainerHigh
            : colors.surface,
        borderRadius: AppTokens.radius.xxl,
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? colors.outline.withValues(alpha: AppOpacity.overlay)
              : colors.outlineVariant,
          width: theme.brightness == Brightness.dark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: AppOpacity.medium),
            blurRadius: AppTokens.shadow.xxl,
            offset: AppShadowOffset.modal,
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
