import 'package:flutter/material.dart';

import '../theme/card_styles.dart';
import '../theme/tokens.dart';
import 'responsive_provider.dart';

/// A reusable modal shell container for bottom sheets and dialogs.
///
/// Provides consistent styling with:
/// - Elevated card background and border
/// - Rounded corners with ClipRRect
/// - Modal shadow (light mode only)
/// - SafeArea and keyboard-aware padding
/// - Max width/height constraints
///
/// Used by change_email_sheet, change_password_sheet, delete_account_sheet,
/// verify_email_sheet, add_reminder_screen, etc.
class ModalShell extends StatelessWidget {
  const ModalShell({
    super.key,
    required this.child,
    this.maxWidthRatio,
    this.maxHeightRatio,
  });

  /// The content to display inside the modal.
  final Widget child;

  /// Optional max width ratio override (defaults to AppLayout.sheetMaxWidth).
  final double? maxWidthRatio;

  /// Optional max height ratio override (defaults to AppLayout.sheetMaxHeightRatio).
  final double? maxHeightRatio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final media = MediaQuery.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBackground = elevatedCardBackground(theme, solid: true);
    final borderColor = elevatedCardBorder(theme, solid: true);
    final borderWidth = elevatedCardBorderWidth(theme);
    final maxHeight = media.size.height * (maxHeightRatio ?? AppLayout.sheetMaxHeightRatio);

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
              maxWidth: maxWidthRatio ?? AppLayout.sheetMaxWidth,
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
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A detail sheet shell container for responsive detail views.
///
/// Similar to [ModalShell] but designed for detail sheets that need:
/// - Responsive scaling via ResponsiveProvider
/// - Internal padding with constraints
/// - Custom content layout without keyboard awareness
///
/// Used by ClassDetailsSheet, ReminderDetailsSheet, InstructorFinderSheet.
class DetailShell extends StatelessWidget {
  const DetailShell({
    super.key,
    required this.child,
    this.padding,
    this.useBubbleShadow = false,
  });

  /// The content to display inside the shell.
  final Widget child;

  /// Optional padding override.
  final EdgeInsetsGeometry? padding;

  /// Use bubble shadow instead of modal shadow (for floating sheets).
  final bool useBubbleShadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final media = MediaQuery.of(context);
    final spacingScale = ResponsiveProvider.spacing(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBackground = elevatedCardBackground(theme, solid: true);
    final borderColor = elevatedCardBorder(theme, solid: true);
    final borderWidth = elevatedCardBorderWidth(theme);
    final maxHeight = media.size.height * AppLayout.sheetMaxHeightRatio;

    return SafeArea(
      child: Center(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: spacing.xl * spacingScale),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppLayout.sheetMaxWidth),
            child: Container(
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: AppTokens.radius.xl,
                border: Border.all(color: borderColor, width: borderWidth),
                boxShadow: isDark
                    ? null
                    : [
                        useBubbleShadow
                            ? AppTokens.shadow.bubble(
                                colors.shadow.withValues(alpha: AppOpacity.border),
                              )
                            : AppTokens.shadow.modal(
                                colors.shadow.withValues(alpha: AppOpacity.border),
                              ),
                      ],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: padding ??
                      EdgeInsets.all(spacing.xl * spacingScale),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A content sheet shell for scrollable content dialogs.
///
/// Used for Privacy, About, and other content-heavy sheets that need:
/// - Custom maxHeight based on screen padding
/// - Material wrapper with transparent background
/// - Internal padding and scrollable content area
class ContentShell extends StatelessWidget {
  const ContentShell({
    super.key,
    required this.child,
    this.padding,
  });

  /// The content to display inside the shell.
  final Widget child;

  /// Optional padding override.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final media = MediaQuery.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBackground = elevatedCardBackground(theme, solid: true);
    final borderColor = elevatedCardBorder(theme, solid: true);
    final borderWidth = elevatedCardBorderWidth(theme);
    final maxHeight = media.size.height -
        (spacing.xxxl * 2 + media.padding.top + media.padding.bottom);

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppLayout.sheetMaxWidth,
          maxHeight: maxHeight.clamp(AppLayout.sheetMinHeight, double.infinity),
        ),
        child: Container(
          padding: padding ??
              spacing.edgeInsetsAll(
                  spacing.xxl * ResponsiveProvider.spacing(context)),
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
                      colors.shadow.withValues(alpha: AppOpacity.veryFaint),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A dialog shell container for centered dialog modals.
///
/// Similar to [ModalShell] but designed for Dialog widgets with
/// transparent backgrounds and custom inset padding.
class DialogShell extends StatelessWidget {
  const DialogShell({
    super.key,
    required this.child,
    this.maxWidth = 400,
    this.padding,
  });

  /// The content to display inside the dialog.
  final Widget child;

  /// Max width of the dialog (defaults to 400).
  final double maxWidth;

  /// Optional padding override.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;

    final cardBackground = elevatedCardBackground(theme, solid: true);
    final borderColor = elevatedCardBorder(theme, solid: true);
    final borderWidth = elevatedCardBorderWidth(theme);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
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
            child: Padding(
              padding: padding ?? spacing.edgeInsetsAll(spacing.xl),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A danger/warning card with tinted background and border.
///
/// Used for error messages, warnings, and destructive action confirmations.
class DangerCard extends StatelessWidget {
  const DangerCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  /// The content to display inside the card.
  final Widget child;

  /// Optional padding override (defaults to spacing.lg).
  final EdgeInsetsGeometry? padding;

  /// Optional margin around the card.
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;

    return Container(
      margin: margin,
      padding: padding ?? spacing.edgeInsetsAll(spacing.lg),
      decoration: BoxDecoration(
        color: palette.danger.withValues(alpha: AppOpacity.dim),
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: palette.danger.withValues(alpha: AppOpacity.ghost),
          width: AppTokens.componentSize.dividerThin,
        ),
      ),
      child: child,
    );
  }
}

/// A gradient icon container with optional border.
///
/// Used for hero icons in cards and headers with gradient backgrounds.
class GradientIconBox extends StatelessWidget {
  const GradientIconBox({
    super.key,
    required this.icon,
    required this.size,
    this.iconSize,
    this.tint,
    this.gradient,
    this.showBorder = false,
  });

  /// The icon to display.
  final IconData icon;

  /// The size of the container (width and height).
  final double size;

  /// Optional explicit icon size (defaults to size * 0.5).
  final double? iconSize;

  /// Optional tint color (defaults to primary).
  final Color? tint;

  /// Optional custom gradient colors.
  final List<Color>? gradient;

  /// Whether to show a border.
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tintColor = tint ?? colors.primary;

    final gradientColors = gradient ??
        [
          tintColor.withValues(alpha: AppOpacity.medium),
          tintColor.withValues(alpha: AppOpacity.dim),
        ];

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: AppTokens.radius.md,
        border: showBorder
            ? Border.all(
                color: tintColor.withValues(alpha: AppOpacity.borderEmphasis),
                width: AppTokens.componentSize.dividerThick,
              )
            : null,
      ),
      child: Icon(
        icon,
        color: tintColor,
        size: iconSize ?? size * 0.5, // Icon defaults to half the container size
      ),
    );
  }
}

/// A responsive icon container that scales with screen size.
///
/// Similar to IconBox but supports responsive scaling.
class ResponsiveIconBox extends StatelessWidget {
  const ResponsiveIconBox({
    super.key,
    required this.icon,
    required this.scale,
    this.tint,
    this.backgroundAlpha,
    this.baseSize,
    this.radius,
  });

  /// The icon to display.
  final IconData icon;

  /// The scale factor for responsive sizing.
  final double scale;

  /// Optional tint color (defaults to primary).
  final Color? tint;

  /// Optional background alpha override.
  final double? backgroundAlpha;

  /// Base size before scaling (defaults to iconSize.lg).
  final double? baseSize;

  /// Optional radius override.
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final tintColor = tint ?? colors.primary;
    final alpha = backgroundAlpha ?? AppOpacity.highlight;
    final iconBaseSize = baseSize ?? AppTokens.iconSize.lg;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.md * scale),
      decoration: BoxDecoration(
        color: tintColor.withValues(alpha: alpha),
        borderRadius: radius ?? AppTokens.radius.lg,
      ),
      child: Icon(
        icon,
        color: tintColor,
        size: iconBaseSize * scale,
      ),
    );
  }
}
