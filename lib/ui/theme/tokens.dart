import 'package:flutter/material.dart';

// Re-export all modular token classes for backward compatibility
export 'tokens/colors.dart';
export 'tokens/interaction.dart';
export 'tokens/layout.dart';
export 'tokens/motion.dart';
export 'tokens/opacity.dart';
export 'tokens/radius.dart';
export 'tokens/responsive.dart';
export 'tokens/shadows.dart';
export 'tokens/sizing.dart';
export 'tokens/spacing.dart';
export 'tokens/typography.dart';
export 'tokens/urgency.dart';

// Import for use in AppTokens wrapper class
import 'tokens/motion.dart';
import 'tokens/radius.dart';
import 'tokens/shadows.dart';
import 'tokens/sizing.dart';
import 'tokens/spacing.dart';
import 'tokens/typography.dart';

// ==============================================================================
// DESIGN TOKENS
// ==============================================================================
//
// Centralized design tokens for the MySched design system.
// All visual constants are defined here for consistency across the app.
//
// ORGANIZATION:
// ------------------------------------------------------------------------------
// Token classes are now organized in lib/ui/theme/tokens/:
//   - colors.dart        - Semantic colors, barriers, line heights, letter spacing
//   - interaction.dart   - Touch targets, gestures, sliders
//   - layout.dart        - Breakpoints, max widths, display limits
//   - motion.dart        - Duration and easing tokens
//   - opacity.dart       - Transparency levels, scale transforms
//   - radius.dart        - Border radius scale
//   - shadows.dart       - Blur values and BoxShadow factories
//   - sizing.dart        - Icon, component, font weight tokens
//   - spacing.dart       - Margins, padding, gaps (4px grid)
//   - typography.dart    - Font sizes, weights, styles
//
// USAGE:
// ------------------------------------------------------------------------------
// Direct class access:    AppSpacing().md, AppRadius().lg, AppOpacity.soft
// Wrapper access:         AppTokens.spacing.md (returns instance)
// Colors:                 AppTokens.lightColors.primary, lightColors.surface
//
// ==============================================================================

/// Centralized design tokens for the MySched design system.
class AppTokens {
  const AppTokens._();

  static const ColorPalette lightColors = ColorPalette(
    primary: Color(0xFF0066FF),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDDE7FF),
    onPrimaryContainer: Color(0xFF001A4D),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF000000),
    surfaceVariant: Color(0xFFF7F7F7),
    onSurfaceVariant: Color(0xFF707070),
    background: Color(0xFFFCFCFC),
    onBackground: Color(0xFF000000),
    outline: Color(0xFFEBEBEB),
    overlay: Color(0x140066FF),
    positive: Color(0xFF1FB98F),
    warning: Color(0xFFFFAE04),
    danger: Color(0xFFE54B4F),
    info: Color(0xFF2D61EF),
    brand: Color(0xFF1A5DFF),
    muted: Color(0xFF4B556D),
    mutedSecondary: Color(0xFF7F8AA7),
    avatarGradientStart: Color(0xFF95BAFF),
    avatarGradientEnd: Color(0xFF6FB7FF),
  );

  static const ColorPalette darkColors = ColorPalette(
    primary: Color(0xFF0066FF),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF002255),
    onPrimaryContainer: Color(0xFFDDE7FF),
    surface: Color(0xFF1A1A1A),
    onSurface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFF262626),
    onSurfaceVariant: Color(0xFFA6A6A6),
    background: Color(0xFF000000),
    onBackground: Color(0xFFFFFFFF),
    outline: Color(0xFF333333),
    overlay: Color(0x330066FF),
    positive: Color(0xFF44E5BC),
    warning: Color(0xFFFFAE04),
    danger: Color(0xFFE54B4F),
    info: Color(0xFF2D61EF),
    brand: Color(0xFF1A5DFF),
    muted: Color(0xFF8B95AD),
    mutedSecondary: Color(0xFF9AA4BC),
    avatarGradientStart: Color(0xFF95BAFF),
    avatarGradientEnd: Color(0xFF6FB7FF),
  );

  /// Ultra-dark "void" theme variant with near-black surfaces.
  ///
  /// This theme provides an AMOLED-friendly experience with true black (#000000)
  /// backgrounds for maximum battery savings on OLED displays. Surface colors
  /// are slightly elevated (#050505, #141414) to maintain visual hierarchy
  /// while keeping the overall appearance extremely dark.
  ///
  /// Use this theme via [ThemeController] when user selects "Void" mode in settings.
  static const ColorPalette voidColors = ColorPalette(
    primary: Color(0xFF0066FF),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF001A4D),
    onPrimaryContainer: Color(0xFFDDE7FF),
    surface: Color(0xFF050505),
    onSurface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFF141414),
    onSurfaceVariant: Color(0xFFA6A6A6),
    background: Color(0xFF000000),
    onBackground: Color(0xFFFFFFFF),
    outline: Color(0xFF262626),
    overlay: Color(0x330066FF),
    positive: Color(0xFF44E5BC),
    warning: Color(0xFFFFAE04),
    danger: Color(0xFFE54B4F),
    info: Color(0xFF2D61EF),
    brand: Color(0xFF1A5DFF),
    muted: Color(0xFF6B7280),
    mutedSecondary: Color(0xFF8B95AD),
    avatarGradientStart: Color(0xFF95BAFF),
    avatarGradientEnd: Color(0xFF6FB7FF),
  );

  static const AppSpacing spacing = AppSpacing();
  static const AppRadius radius = AppRadius();
  static const AppTypography typography = AppTypography.instance;
  static const AppMotion motion = AppMotion();
  static const AppDurations durations = AppDurations();
  static const AppIconSize iconSize = AppIconSize();
  static const AppComponentSize componentSize = AppComponentSize();
  static const AppShadow shadow = AppShadow();
  static const AppFontWeight fontWeight = AppFontWeight();
}

/// Color palette data class for theme colors.
class ColorPalette {
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color background;
  final Color onBackground;
  final Color outline;
  final Color overlay;
  final Color positive;
  final Color warning;
  final Color danger;
  final Color info;

  /// Brand accent color used in splash/loading screens.
  final Color brand;

  /// Muted text color for secondary content.
  final Color muted;

  /// Summary/tertiary muted color.
  final Color mutedSecondary;

  /// Avatar gradient start color.
  final Color avatarGradientStart;

  /// Avatar gradient end color.
  final Color avatarGradientEnd;

  const ColorPalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.background,
    required this.onBackground,
    required this.outline,
    required this.overlay,
    required this.positive,
    required this.warning,
    required this.danger,
    required this.info,
    required this.brand,
    required this.muted,
    required this.mutedSecondary,
    required this.avatarGradientStart,
    required this.avatarGradientEnd,
  });

  // Aliases for Material 3 compatibility
  Color get surfaceContainerHigh => surfaceVariant;
  Color get error => danger;

  /// Creates a copy of this palette with the given fields replaced.
  ColorPalette copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? surface,
    Color? onSurface,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? background,
    Color? onBackground,
    Color? outline,
    Color? overlay,
    Color? positive,
    Color? warning,
    Color? danger,
    Color? info,
    Color? brand,
    Color? muted,
    Color? mutedSecondary,
    Color? avatarGradientStart,
    Color? avatarGradientEnd,
  }) {
    return ColorPalette(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      outline: outline ?? this.outline,
      overlay: overlay ?? this.overlay,
      positive: positive ?? this.positive,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      brand: brand ?? this.brand,
      muted: muted ?? this.muted,
      mutedSecondary: mutedSecondary ?? this.mutedSecondary,
      avatarGradientStart: avatarGradientStart ?? this.avatarGradientStart,
      avatarGradientEnd: avatarGradientEnd ?? this.avatarGradientEnd,
    );
  }
}
