// ═══════════════════════════════════════════════════════════════════════════════
// TYPOGRAPHY TOKENS
// ═══════════════════════════════════════════════════════════════════════════════
//
// Font styles, sizes, and text style definitions.
//
// Usage: AppTokens.typography.title, AppTokens.typography.body
//
// Note: Font weights are in sizing.dart (AppFontWeight)
//       Letter spacing is in colors.dart (AppLetterSpacing)
//       Line heights are in colors.dart (AppLineHeight)
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// Typography style tokens.
class AppTypography {
  /// Private constructor. Access via [AppTokens.typography].
  const AppTypography._internal();

  /// Singleton instance for use in [AppTokens].
  static const AppTypography instance = AppTypography._internal();

  /// Primary font family.
  static const String primaryFont = 'SFProRounded';

  /// Standard body text line height (1.5).
  static const double bodyLineHeight = 1.5;

  /// 32px - Display text for hero sections.
  TextStyle get display => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.12,
      );

  /// 42px - Extra large brand/splash text.
  TextStyle get brand => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 42,
        fontWeight: FontWeight.w700,
        height: 1.1,
      );

  /// 26px - Headline text.
  TextStyle get headline => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  /// 20px - Title text.
  TextStyle get title => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.28,
      );

  /// 16px - Subtitle text.
  TextStyle get subtitle => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.36,
      );

  /// 16px - Body text.
  TextStyle get body => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  /// 14px - Secondary body text.
  TextStyle get bodySecondary => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  /// 12px - Caption text.
  TextStyle get caption => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.35,
        letterSpacing: 0.1,
      );

  /// 10px - Micro text for badges, tiny labels.
  TextStyle get micro => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.2,
      );

  /// 14px - Label text for form fields and buttons.
  TextStyle get label => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.36,
        letterSpacing: 0.3,
      );
}

/// Extension for responsive typography.
///
/// Use this to apply scale factors to text styles:
/// ```dart
/// final scaledDisplay = AppTokens.typography.displayScaled(scale);
/// ```
extension ResponsiveTypography on AppTypography {
  /// Returns display style with scaled font size.
  TextStyle displayScaled(double scale) => display.copyWith(
        fontSize: (display.fontSize ?? 32) * scale,
      );

  /// Returns headline style with scaled font size.
  TextStyle headlineScaled(double scale) => headline.copyWith(
        fontSize: (headline.fontSize ?? 26) * scale,
      );

  /// Returns title style with scaled font size.
  TextStyle titleScaled(double scale) => title.copyWith(
        fontSize: (title.fontSize ?? 20) * scale,
      );

  /// Returns subtitle style with scaled font size.
  TextStyle subtitleScaled(double scale) => subtitle.copyWith(
        fontSize: (subtitle.fontSize ?? 16) * scale,
      );

  /// Returns body style with scaled font size.
  TextStyle bodyScaled(double scale) => body.copyWith(
        fontSize: (body.fontSize ?? 16) * scale,
      );

  /// Returns caption style with scaled font size.
  TextStyle captionScaled(double scale) => caption.copyWith(
        fontSize: (caption.fontSize ?? 12) * scale,
      );

  /// Returns micro style with scaled font size.
  TextStyle microScaled(double scale) => micro.copyWith(
        fontSize: (micro.fontSize ?? 10) * scale,
      );

  /// Returns bodySecondary style with scaled font size.
  TextStyle bodySecondaryScaled(double scale) => bodySecondary.copyWith(
        fontSize: (bodySecondary.fontSize ?? 14) * scale,
      );
}
