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
  static const AppShadow shadow = AppShadow();
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
  /// Half-micro spacing for pixel-perfect fine-tuning (1)
  final double microHalf = 1;
  /// Micro spacing for pixel-perfect fine-tuning (2)
  final double micro = 2;
  /// Small micro spacing for subtle adjustments (4)
  final double microLg = 4;
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

  /// Extra-small radius for checkboxes and subtle rounding
  final BorderRadius xs = const BorderRadius.all(Radius.circular(6));
  final BorderRadius sm = const BorderRadius.all(Radius.circular(8));
  /// Chip radius (between sm and md)
  final BorderRadius chip = const BorderRadius.all(Radius.circular(10));
  final BorderRadius md = const BorderRadius.all(Radius.circular(12));
  /// Popup/list tile radius (between md and lg)
  final BorderRadius popup = const BorderRadius.all(Radius.circular(14));
  final BorderRadius lg = const BorderRadius.all(Radius.circular(16));
  /// Sheet/dialog radius
  final BorderRadius sheet = const BorderRadius.all(Radius.circular(20));
  final BorderRadius xl = const BorderRadius.all(Radius.circular(24));
  /// Button radius (between xl and xxl)
  final BorderRadius button = const BorderRadius.all(Radius.circular(26));
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
  /// Extra large brand/splash text
  TextStyle get brand => const TextStyle(
        fontFamily: primaryFont,
        fontSize: 42,
        fontWeight: FontWeight.w700,
        height: 1.1,
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

  // Divider/border thickness
  final double divider = 1;
  final double dividerThin = 0.5;
  final double dividerMedium = 1.2;
  final double dividerThick = 1.5;
  final double dividerBold = 2;

  // Button heights
  final double buttonSm = 44;
  final double buttonMd = 48;
  final double buttonLg = 52;

  // Card preview heights
  final double previewSm = 120;
  final double previewMd = 200;
  final double previewLg = 280;

  // Progress indicator
  final double progressHeight = 4;
  final double progressWidth = 40;
}

/// Shadow blur radius presets and BoxShadow factories for consistent elevation effects.
class AppShadow {
  const AppShadow();

  /// Extra-small blur for subtle badges (4)
  final double xs = 4;
  /// Small blur for minimal elevation (6)
  final double sm = 6;
  /// Medium blur for standard tiles/cards (12)
  final double md = 12;
  /// Large blur for elevated cards (16)
  final double lg = 16;
  /// Extra-large blur for prominent cards (20)
  final double xl = 20;
  /// XXL blur for hero cards and modals (40)
  final double xxl = 40;

  // ---------------------------------------------------------------------------
  // BoxShadow Factory Methods
  // ---------------------------------------------------------------------------

  /// Subtle elevation for chips, badges, and inline elements.
  BoxShadow elevation1(Color color) => BoxShadow(
        color: color,
        blurRadius: xs,
        offset: const Offset(0, 2),
      );

  /// Light elevation for list tiles and small cards.
  BoxShadow elevation2(Color color) => BoxShadow(
        color: color,
        blurRadius: sm,
        offset: const Offset(0, 4),
      );

  /// Standard elevation for cards and containers.
  BoxShadow elevation3(Color color) => BoxShadow(
        color: color,
        blurRadius: md,
        offset: const Offset(0, 6),
      );

  /// Elevated cards with prominent shadow.
  BoxShadow elevation4(Color color) => BoxShadow(
        color: color,
        blurRadius: lg,
        offset: const Offset(0, 8),
      );

  /// High elevation for modals and sheets.
  BoxShadow elevation5(Color color) => BoxShadow(
        color: color,
        blurRadius: xl,
        offset: const Offset(0, 12),
      );

  /// Maximum elevation for floating action buttons and hero elements.
  BoxShadow elevation6(Color color) => BoxShadow(
        color: color,
        blurRadius: xxl,
        offset: const Offset(0, 16),
      );

  /// Card shadow with customizable blur and offset.
  BoxShadow card(Color color, {double blur = 12, Offset offset = const Offset(0, 4)}) =>
      BoxShadow(color: color, blurRadius: blur, offset: offset);

  /// Modal/sheet shadow with high elevation.
  BoxShadow modal(Color color, {bool isDark = false}) => BoxShadow(
        color: color,
        blurRadius: 24,
        offset: const Offset(0, 18),
      );

  /// Navigation bar shadow.
  BoxShadow navBar(Color color) => BoxShadow(
        color: color,
        blurRadius: 30,
        offset: const Offset(0, 16),
      );

  /// FAB/quick action button shadow with spread.
  BoxShadow fab(Color color, {bool active = false}) => BoxShadow(
        color: color,
        blurRadius: active ? 36 : 30,
        offset: Offset(0, active ? 18 : 16),
        spreadRadius: active ? 2 : 0,
      );

  /// Hint bubble shadow.
  BoxShadow bubble(Color color) => BoxShadow(
        color: color,
        blurRadius: 28,
        offset: const Offset(0, 20),
      );
}

/// Centralized opacity tokens for consistent transparency values.
///
/// Use these instead of raw alpha values like `.withValues(alpha: 0.12)`.
class AppOpacity {
  const AppOpacity._();

  /// Minimal tint for subtle backgrounds (0.05)
  static const double faint = 0.05;

  /// Row highlights and hover states (0.08)
  static const double highlight = 0.08;

  /// Surface overlays and subtle fills (0.12)
  static const double overlay = 0.12;

  /// Status chip backgrounds (0.16)
  static const double statusBg = 0.16;

  /// Dark mode borders and dividers (0.18)
  static const double border = 0.18;

  /// Dark mode elevated tints (0.22)
  static const double darkTint = 0.22;

  /// Ghost elements and hints (0.3)
  static const double ghost = 0.30;

  /// Disabled state opacity (0.38) - Material standard
  static const double disabled = 0.38;

  /// Modal barrier tint (0.45)
  static const double barrier = 0.45;

  /// Subtle overlays and shadows (0.5)
  static const double subtle = 0.50;

  /// Muted text and secondary content (0.7)
  static const double muted = 0.70;

  /// Glass morphism background (0.72)
  static const double glass = 0.72;

  /// Near-opaque content (0.85)
  static const double prominent = 0.85;
}

/// Centralized layout constraint tokens.
///
/// Use these for consistent sheet widths, safe padding, and content constraints.
class AppLayout {
  const AppLayout._();

  /// Bottom navigation safe padding (accounts for nav bar + FAB).
  static const double bottomNavSafePadding = 120.0;

  /// Maximum width for modal sheets.
  static const double sheetMaxWidth = 520.0;

  /// Maximum height ratio for modal sheets (78% of screen).
  static const double sheetMaxHeightRatio = 0.78;

  /// Maximum width for dialogs.
  static const double dialogMaxWidth = 400.0;

  /// Maximum width for main content areas.
  static const double contentMaxWidth = 600.0;

  /// Wide content max width for tablets/desktop.
  static const double contentMaxWidthWide = 720.0;

  /// Extra wide content for large displays.
  static const double contentMaxWidthExtraWide = 840.0;

  /// Default horizontal page padding.
  static const double pagePaddingHorizontal = 20.0;

  /// Default vertical page padding.
  static const double pagePaddingVertical = 24.0;
}

/// Centralized interaction tokens for touch/click feedback.
///
/// Use these for splash radii, icon button containers, and loader sizes.
class AppInteraction {
  const AppInteraction._();

  /// Splash radius for IconButton and InkWell.
  static const double splashRadius = 22.0;

  /// CircleAvatar radius for icon button containers.
  static const double iconButtonContainerRadius = 16.0;

  /// Standard progress indicator stroke width.
  static const double progressStrokeWidth = 2.0;

  /// Large progress indicator stroke width.
  static const double progressStrokeWidthLarge = 2.5;

  /// Standard loader/spinner size.
  static const double loaderSize = 18.0;

  /// Large loader/spinner size.
  static const double loaderSizeLarge = 24.0;

  /// Small loader/spinner size.
  static const double loaderSizeSmall = 14.0;
}

/// Centralized slider control tokens.
class AppSlider {
  const AppSlider._();

  /// Slider track height.
  static const double trackHeight = 4.0;

  /// Slider thumb radius.
  static const double thumbRadius = 8.0;

  /// Slider overlay radius (touch target).
  static const double overlayRadius = 16.0;
}

/// Centralized letter spacing tokens for typography.
///
/// Use these instead of raw letter spacing values.
class AppLetterSpacing {
  const AppLetterSpacing._();

  /// Tight spacing for large headings (-0.5)
  static const double tight = -0.5;

  /// Snug spacing for titles (-0.3)
  static const double snug = -0.3;

  /// Slightly tight spacing (-0.2)
  static const double compact = -0.2;

  /// Normal/default spacing (0.0)
  static const double normal = 0.0;

  /// Slightly wide spacing (0.1)
  static const double relaxed = 0.1;

  /// Wide spacing for captions (0.2)
  static const double wide = 0.2;

  /// Wider spacing for labels (0.3)
  static const double wider = 0.3;

  /// Maximum spacing for all-caps (0.4)
  static const double widest = 0.4;
}

/// Centralized modal barrier color tokens.
///
/// Use these for showModalBottomSheet and showDialog barriers.
class AppBarrier {
  const AppBarrier._();

  /// Light barrier (30% black) for subtle overlays.
  static const Color light = Color(0x4D000000);

  /// Medium barrier (45% black) for standard sheets.
  static const Color medium = Color(0x73000000);

  /// Heavy barrier (54% black) for prominent modals.
  static const Color heavy = Color(0x8A000000);
}

/// Centralized line height tokens for text styling.
///
/// Use these instead of raw height values in TextStyle.
class AppLineHeight {
  const AppLineHeight._();

  /// Tight line height for display text (1.1)
  static const double tight = 1.1;

  /// Display line height (1.12)
  static const double display = 1.12;

  /// Headline line height (1.2)
  static const double headline = 1.2;

  /// Title line height (1.28)
  static const double title = 1.28;

  /// Compact line height for UI labels (1.3)
  static const double compact = 1.3;

  /// Caption line height (1.35)
  static const double caption = 1.35;

  /// Subtitle/label line height (1.36)
  static const double subtitle = 1.36;

  /// Relaxed line height (1.4)
  static const double relaxed = 1.4;

  /// Body secondary line height (1.45)
  static const double bodySecondary = 1.45;

  /// Body text line height (1.5)
  static const double body = 1.5;
}

/// Centralized shadow offset tokens.
///
/// Use these for consistent BoxShadow offsets.
class AppShadowOffset {
  const AppShadowOffset._();

  /// Minimal elevation offset
  static const Offset xs = Offset(0, 2);

  /// Small elevation offset
  static const Offset sm = Offset(0, 4);

  /// Medium elevation offset
  static const Offset md = Offset(0, 6);

  /// Large elevation offset
  static const Offset lg = Offset(0, 8);

  /// Extra-large elevation offset
  static const Offset xl = Offset(0, 12);

  /// Modal/hero elevation offset
  static const Offset xxl = Offset(0, 16);

  /// Slide-in animation offset (subtle upward entry)
  static const Offset slideIn = Offset(0, 0.05);
}

/// Centralized transform scale tokens.
///
/// Use these for consistent Transform.scale values.
class AppScale {
  const AppScale._();

  /// Compact scale for dense UI elements (0.8)
  static const double compact = 0.8;

  /// Slightly reduced scale (0.9)
  static const double reduced = 0.9;

  /// Default scale (1.0)
  static const double normal = 1.0;

  /// Slightly enlarged scale (1.1)
  static const double enlarged = 1.1;

  /// Hover/focus emphasis scale (1.02)
  static const double hover = 1.02;
}
