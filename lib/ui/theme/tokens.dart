import 'package:flutter/material.dart';

/// Centralized design tokens for the MySched design system.
class AppTokens {
  const AppTokens._();

  static const ColorPalette lightColors = ColorPalette(
    primary: Color(0xFF1A5DFF),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDDE7FF),
    onPrimaryContainer: Color(0xFF0C1F5C),
    surface: Color(0xFFF7FAFF),
    onSurface: Color(0xFF0F172A),
    surfaceVariant: Color(0xFFE8F0FF),
    onSurfaceVariant: Color(0xFF1E293B),
    background: Color(0xFFEFF4FF),
    onBackground: Color(0xFF0A1020),
    outline: Color(0xFFC7D4F8),
    overlay: Color(0x143E68F9),
    positive: Color(0xFF1FB98F),
    warning: Color(0xFFF4A938),
    danger: Color(0xFFED5A5A),
    info: Color(0xFF3B82F6),
  );

  static const ColorPalette darkColors = ColorPalette(
    primary: Color(0xFF7FA5FF),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF293A73),
    onPrimaryContainer: Color(0xFFDCE6FF),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE3E3E3),
    surfaceVariant: Color(0xFF1E1E1E),
    onSurfaceVariant: Color(0xFFBFC7E4),
    background: Color(0xFF121212),
    onBackground: Color(0xFFE3E3E3),
    outline: Color(0xFF2A2A2A),
    overlay: Color(0x332D4CFF),
    positive: Color(0xFF44E5BC),
    warning: Color(0xFFFAD06A),
    danger: Color(0xFFFF8A8A),
    info: Color(0xFF9AB8FF),
  );

  static const AppSpacing spacing = AppSpacing();
  static const AppRadius radius = AppRadius();
  static const AppTypography typography = AppTypography._();
  static const AppMotion motion = AppMotion();
}

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
  });
}

class AppSpacing {
  const AppSpacing();

  final double none = 0;
  final double xs = 4;
  final double sm = 8;
  final double md = 12;
  final double lg = 16;
  final double xl = 20;
  final double xxl = 24;
  final double xxxl = 32;
  final double quad = 40;

  EdgeInsets edgeInsetsAll(double value) => EdgeInsets.all(value);
  EdgeInsets edgeInsetsSymmetric(
          {double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  EdgeInsets edgeInsetsOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
}

class AppRadius {
  const AppRadius();

  final BorderRadius sm = const BorderRadius.all(Radius.circular(8));
  final BorderRadius md = const BorderRadius.all(Radius.circular(12));
  final BorderRadius lg = const BorderRadius.all(Radius.circular(16));
  final BorderRadius xl = const BorderRadius.all(Radius.circular(24));

  BorderRadius circular(double value) =>
      BorderRadius.all(Radius.circular(value));
}

class AppTypography {
  const AppTypography._();

  static const String primaryFont = 'SFProRounded';

  TextStyle get display => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.12,
      );
  TextStyle get headline => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );
  TextStyle get title => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.28,
      );
  TextStyle get subtitle => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.36,
      );
  TextStyle get body => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );
  TextStyle get bodySecondary => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );
  TextStyle get caption => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.35,
        letterSpacing: 0.1,
      );
  TextStyle get label => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.36,
        letterSpacing: 0.3,
      );
}

class AppMotion {
  const AppMotion();

  final Duration fast = const Duration(milliseconds: 120);
  final Duration medium = const Duration(milliseconds: 200);
  final Duration slow = const Duration(milliseconds: 320);
  final Curve ease = Curves.easeOutCubic;
}
