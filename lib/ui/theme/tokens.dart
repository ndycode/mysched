import 'package:flutter/material.dart';

/// Centralized design tokens for the MySched design system.
class AppTokens {
  const AppTokens._();

  static const ColorPalette lightColors = ColorPalette(
    primary: Color(0xFF0066FF),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDDE7FF), // Kept as derivative
    onPrimaryContainer: Color(0xFF001A4D), // Kept as derivative
    surface: Color(0xFFFFFFFF), // --card
    onSurface: Color(0xFF000000), // --card-foreground
    surfaceVariant: Color(0xFFF7F7F7), // --muted
    onSurfaceVariant: Color(0xFF707070), // --muted-foreground
    background: Color(0xFFFCFCFC), // --background
    onBackground: Color(0xFF000000), // --foreground
    outline: Color(0xFFEBEBEB), // --border
    overlay: Color(0x140066FF),
    positive: Color(0xFF1FB98F),
    warning: Color(0xFFFFAE04), // --chart-1
    danger: Color(0xFFE54B4F), // --destructive
    info: Color(0xFF2D61EF), // --chart-2
    brand: Color(0xFF1A5DFF), // Brand accent for splash/loading
    muted: Color(0xFF4B556D), // Dashboard muted text
    mutedSecondary: Color(0xFF7F8AA7), // Summary muted text
    avatarGradientStart: Color(0xFF95BAFF), // Hero avatar gradient
    avatarGradientEnd: Color(0xFF6FB7FF), // Hero avatar gradient
  );

  static const ColorPalette darkColors = ColorPalette(
    primary: Color(0xFF0066FF), // --primary (same in dark mode per css var, though usually lighter)
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF002255),
    onPrimaryContainer: Color(0xFFDDE7FF),
    surface: Color(0xFF1A1A1A), // --card
    onSurface: Color(0xFFFFFFFF), // --card-foreground
    surfaceVariant: Color(0xFF262626), // --muted
    onSurfaceVariant: Color(0xFFA6A6A6), // --muted-foreground
    background: Color(0xFF000000), // --background
    onBackground: Color(0xFFFFFFFF), // --foreground
    outline: Color(0xFF333333), // --border
    overlay: Color(0x330066FF),
    positive: Color(0xFF44E5BC),
    warning: Color(0xFFFFAE04),
    danger: Color(0xFFE54B4F),
    info: Color(0xFF2D61EF),
    brand: Color(0xFF1A5DFF), // Brand accent for splash/loading
    muted: Color(0xFF8B95AD), // Dashboard muted text (lighter for dark mode)
    mutedSecondary: Color(0xFF9AA4BC), // Summary muted text
    avatarGradientStart: Color(0xFF95BAFF), // Hero avatar gradient
    avatarGradientEnd: Color(0xFF6FB7FF), // Hero avatar gradient
  );

  static const ColorPalette voidColors = ColorPalette(
    primary: Color(0xFF0066FF),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF001A4D),
    onPrimaryContainer: Color(0xFFDDE7FF),
    surface: Color(0xFF050505), // Almost pure black
    onSurface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFF141414), // Very dark grey
    onSurfaceVariant: Color(0xFFA6A6A6),
    background: Color(0xFF000000), // Pure black
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
  static const AppTypography typography = AppTypography._();
  static const AppMotion motion = AppMotion();
  static const AppDurations durations = AppDurations();
  static const AppIconSize iconSize = AppIconSize();
  static const AppComponentSize componentSize = AppComponentSize();
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
  final BorderRadius xxl = const BorderRadius.all(Radius.circular(28));
  final BorderRadius xxxl = const BorderRadius.all(Radius.circular(32));

  /// Fully rounded "pill" shape for chips, badges, and buttons.
  final BorderRadius pill = const BorderRadius.all(Radius.circular(999));

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

  // Duration tokens
  final Duration instant = const Duration(milliseconds: 80);
  final Duration fast = const Duration(milliseconds: 120);
  final Duration medium = const Duration(milliseconds: 200);
  final Duration slow = const Duration(milliseconds: 320);
  final Duration slower = const Duration(milliseconds: 500);

  // Curve tokens
  final Curve ease = Curves.easeOutCubic;
  final Curve easeIn = Curves.easeInCubic;
  final Curve easeOut = Curves.easeOutCubic;
  final Curve easeInOut = Curves.easeInOutCubic;

  // Press/release specific curves
  final Curve press = Curves.easeOut;
  final Curve release = Curves.easeOutBack;
  final Curve bounce = Curves.elasticOut;
  final Curve spring = Curves.easeOutBack;

  // Scale values for interactions
  final double pressScale = 0.96;
  final double pressScaleSubtle = 0.985;
  final double hoverScale = 1.02;

  // Opacity values for interactions
  final double pressOpacity = 0.85;
  final double disabledOpacity = 0.5;
  final double hoverOpacity = 0.92;
}

/// Centralized duration constants for timeouts, intervals, and delays.
class AppDurations {
  const AppDurations();

  /// Network request timeout.
  final Duration networkTimeout = const Duration(seconds: 20);

  /// Cache time-to-live for schedule data.
  final Duration cacheTtl = const Duration(minutes: 1);

  /// Ticker interval for time-based UI updates.
  final Duration tickerInterval = const Duration(minutes: 1);

  /// Heads-up notification lead time before alarm.
  final Duration headsUpLead = const Duration(minutes: 1);

  /// Minimum interval between schedule fetches.
  final Duration fetchDebounce = const Duration(seconds: 3);

  /// Default snooze duration for reminders.
  final Duration defaultSnooze = const Duration(hours: 1);

  /// Animation delay for staggered reveals.
  final Duration staggerDelay = const Duration(milliseconds: 220);

  /// Delay before form submission feedback.
  final Duration submitDelay = const Duration(milliseconds: 500);
}

/// Centralized icon size tokens for consistent icon sizing.
class AppIconSize {
  const AppIconSize();

  /// Extra small icons (chips, badges, inline indicators)
  final double xs = 14;

  /// Small icons (buttons, list items)
  final double sm = 16;

  /// Medium icons (standard UI icons)
  final double md = 20;

  /// Large icons (prominent actions, headers)
  final double lg = 24;

  /// Extra large icons (section headers, cards)
  final double xl = 28;

  /// Hero icons (empty states, featured content)
  final double xxl = 40;

  /// Display icons (large illustrations, scan options)
  final double display = 64;
}

/// Centralized component size tokens for avatars, badges, and containers.
class AppComponentSize {
  const AppComponentSize();

  // Avatar sizes
  final double avatarXs = 24;
  final double avatarSm = 32;
  final double avatarMd = 36;
  final double avatarLg = 42;
  final double avatarXl = 52;
  final double avatarXxl = 64;

  // Badge sizes
  final double badgeSm = 8;
  final double badgeMd = 16;
  final double badgeLg = 24;

  // List item heights
  final double listItemSm = 48;
  final double listItemMd = 56;
  final double listItemLg = 64;

  // Divider thickness
  final double divider = 1;
  final double dividerThick = 2;

  // Button heights
  final double buttonSm = 36;
  final double buttonMd = 48;
  final double buttonLg = 56;

  // Card preview heights
  final double previewSm = 120;
  final double previewMd = 200;
  final double previewLg = 280;

  // Progress indicator
  final double progressHeight = 4;
  final double progressWidth = 40;
}
