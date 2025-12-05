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

  /// 14px - Label text for form fields and buttons.
  TextStyle get label => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.36,
        letterSpacing: 0.3,
      );
}
