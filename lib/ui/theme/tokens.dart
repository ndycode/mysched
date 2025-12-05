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
  static const AppFontWeight fontWeight = AppFontWeight();
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
  
  /// Standard body text line height (1.5)
  static const double bodyLineHeight = 1.5;

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
  final double avatarXsDense = 26;
  final double avatarSmDense = 28;
  final double avatarSm = 32;
  final double avatarMd = 36;
  final double avatarMdLg = 40;
  final double avatarLg = 42;
  final double avatarLgXl = 44;
  final double avatarXl = 48;
  final double avatarXlXxl = 52;
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
  final double strokeHeavy = 6;
  final double paddingAdjust = 2;

  // Button heights
  /// Compact icon/button size (used for small icon actions)
  final double buttonXs = 36;
  final double buttonSm = 44;
  final double buttonMd = 48;
  final double buttonLg = 52;

  // Card preview heights
  final double previewSm = 120;
  final double previewMd = 200;
  final double previewSmd = 140;
  final double previewLg = 280;

  // Progress indicator
  final double progressHeight = 4;
  final double progressWidth = 40;
  final double progressStroke = 2;

  // Skeleton text block heights (approximate typography heights)
  final double skeletonTextXs = 12;  // caption
  final double skeletonTextSm = 14;  // bodySecondary, label
  final double skeletonTextMd = 16;  // body, subtitle
  final double skeletonTextLg = 18;  // between body and title
  final double skeletonTextXl = 20;  // title
  final double skeletonTextXxl = 22; // between title and headline
  final double skeletonTextDisplay = 24; // display approximation
  final double skeletonTextHero = 28; // headline approximation

  // Skeleton placeholder widths (content approximations)
  final double skeletonWidthXxs = 48;   // small metric values
  final double skeletonWidthXs = 60;    // short labels
  final double skeletonWidthSm = 70;    // action chips, trailing
  final double skeletonWidthMd = 80;    // badges, short text
  final double skeletonWidthLg = 100;   // names, medium text
  final double skeletonWidthXl = 120;   // section headers
  final double skeletonWidthXxl = 140;  // titles, longer labels
  final double skeletonWidthWide = 160; // descriptions
  final double skeletonWidthFull = 180; // full-width content
  final double skeletonWidthHero = 200; // hero/primary content
  final double skeletonWidthMax = 220;  // maximum placeholder width

  // Crop dialog dimensions
  final double cropDialogMin = 220;
  final double cropDialogMax = 360;
}

/// Font weight tokens for consistent typography emphasis.
class AppFontWeight {
  const AppFontWeight();

  /// Regular text (400)
  final FontWeight regular = FontWeight.w400;

  /// Medium emphasis (500)
  final FontWeight medium = FontWeight.w500;

  /// Semi-bold for labels and emphasis (600)
  final FontWeight semiBold = FontWeight.w600;

  /// Bold for headings and strong emphasis (700)
  final FontWeight bold = FontWeight.w700;

  /// Extra bold for hero/display text (800)
  final FontWeight extraBold = FontWeight.w800;
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
  /// Button/action blur (18)
  final double action = 18;
  /// Extra-large blur for prominent cards (20)
  final double xl = 20;
  /// Glow effect blur (22)
  final double glow = 22;
  /// Card hover base blur (24)
  final double cardHover = 24;
  /// Hero card blur (26)
  final double hero = 26;
  /// XXL blur for hero cards and modals (40)
  final double xxl = 40;

  // ---------------------------------------------------------------------------
  // Material Elevation Values
  // ---------------------------------------------------------------------------

  /// Dark mode popup elevation (8)
  final double elevationDark = 8;
  /// Light mode popup elevation (12)
  final double elevationLight = 12;

  /// Spread radius for indicator glow (0.5)
  final double spreadXs = 0.5;
  /// Spread radius for subtle glow effects (1)
  final double spreadSm = 1;
  /// Spread radius for active glow effects (2)
  final double spreadMd = 2;
  /// Spread radius for hero/card glow effects (10)
  final double spreadLg = 10;

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

  /// Zero opacity - transparent (0.0)
  static const double transparent = 0.0;

  /// Ultra-micro for barely perceptible hover states (0.02)
  static const double ultraMicro = 0.02;

  /// Micro tint for barely visible elements (0.04)
  static const double micro = 0.04;

  /// Minimal tint for subtle backgrounds (0.05)
  static const double faint = 0.05;

  /// Very subtle fills (0.06)
  static const double veryFaint = 0.06;

  /// Row highlights and hover states (0.08)
  static const double highlight = 0.08;

  /// Subtle button fills (0.10)
  static const double dim = 0.10;

  /// Surface overlays and subtle fills (0.12)
  static const double overlay = 0.12;

  /// Medium subtle fills (0.15)
  static const double medium = 0.15;

  /// Status chip backgrounds (0.16)
  static const double statusBg = 0.16;

  /// Dark mode borders and dividers (0.18)
  static const double border = 0.18;

  /// Accent tints and fills (0.20)
  static const double accent = 0.20;

  /// Dark mode elevated tints (0.22)
  static const double darkTint = 0.22;

  /// Border emphasis and outlines (0.25)
  static const double borderEmphasis = 0.25;

  /// Ghost elements and hints (0.30)
  static const double ghost = 0.30;

  /// Field border emphasis (0.32)
  static const double fieldBorder = 0.32;

  /// Switch track and moderate emphasis (0.35)
  static const double track = 0.35;

  /// Disabled state opacity (0.38) - Material standard
  static const double disabled = 0.38;

  /// Light mode borders and dividers (0.40)
  static const double divider = 0.40;

  /// Modal barrier tint (0.45)
  static const double barrier = 0.45;

  /// Subtle overlays and shadows (0.50)
  static const double subtle = 0.50;

  /// Disabled button content (0.55)
  static const double buttonDisabled = 0.55;

  /// Soft content and backgrounds (0.60)
  static const double soft = 0.60;

  /// Skeleton light mode base (0.65)
  static const double skeletonLight = 0.65;

  /// Muted text and secondary content (0.70)
  static const double muted = 0.70;

  /// Glass morphism background (0.72)
  static const double glass = 0.72;

  /// Tertiary content emphasis (0.75)
  static const double tertiary = 0.75;

  /// Glass card surfaces (0.78)
  static const double glassCard = 0.78;

  /// Secondary content emphasis (0.80)
  static const double secondary = 0.80;

  /// Near-opaque content (0.85)
  static const double prominent = 0.85;

  /// Frosted glass surfaces (0.88)
  static const double frosted = 0.88;

  /// High emphasis content (0.90)
  static const double high = 0.90;

  /// App bar and navigation surfaces (0.92)
  static const double surface = 0.92;

  /// Near-full opacity (0.95)
  static const double full = 0.95;

  /// Dense glass surfaces (0.96)
  static const double dense = 0.96;
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

  /// Slightly wider content max width for forms.
  static const double contentMaxWidthMedium = 640.0;

  /// Wide content max width for tablets/desktop.
  static const double contentMaxWidthWide = 720.0;

  /// Extra wide content for large displays.
  static const double contentMaxWidthExtraWide = 840.0;

  /// Default horizontal page padding.
  static const double pagePaddingHorizontal = 20.0;

  /// Default vertical page padding.
  static const double pagePaddingVertical = 24.0;

  /// List cache extent for performance optimization.
  static const double listCacheExtent = 800.0;

  /// Responsive breakpoint for wide layouts.
  static const double wideLayoutBreakpoint = 520.0;
}

/// Display limits for dashboard previews and lists.
class AppDisplayLimits {
  const AppDisplayLimits._();

  /// Maximum reminders to show in dashboard preview.
  static const int reminderPreviewCount = 3;

  /// Maximum classes to show in dashboard schedule preview.
  static const int schedulePreviewCount = 5;
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

  /// Section header spacing for prominent labels (1.2)
  static const double sectionHeader = 1.2;

  /// OTP/verification code spacing (6.0)
  static const double otpCode = 6.0;
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

  /// Single line height for icons/chips (1.0)
  static const double single = 1.0;

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

  /// Modal/auth shell elevation offset
  static const Offset modal = Offset(0, 10);

  /// Extra-large elevation offset
  static const Offset xl = Offset(0, 12);

  /// Hero card elevation offset
  static const Offset hero = Offset(0, 14);

  /// Modal/hero elevation offset
  static const Offset xxl = Offset(0, 16);

  /// Sheet elevation offset
  static const Offset sheet = Offset(0, 18);

  /// Bubble/tooltip elevation offset
  static const Offset bubble = Offset(0, 20);

  /// Alarm preview elevation offset
  static const Offset alarm = Offset(0, 22);

  /// Quick actions panel offset
  static const Offset panel = Offset(0, 24);

  /// Layout body card elevation offset
  static const Offset layout = Offset(0, 28);

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

  /// Dense scale for slightly smaller elements (0.85)
  static const double dense = 0.85;

  /// Slightly reduced scale (0.9)
  static const double reduced = 0.9;

  /// Default scale (1.0)
  static const double normal = 1.0;

  /// Hover/focus emphasis scale (1.02)
  static const double hover = 1.02;

  /// Slightly enlarged scale (1.1)
  static const double enlarged = 1.1;

  /// Narrow slidable action extent ratio (0.3 = 30%)
  static const double slideExtentNarrow = 0.3;

  /// Slidable action extent ratio (0.4 = 40%)
  static const double slideExtent = 0.4;

  /// Crop dialog width ratio (0.8 = 80% of screen)
  static const double cropDialogRatio = 0.8;

  /// Sheet max height ratio (0.85 = 85% of screen)
  static const double sheetHeightRatio = 0.85;
}
