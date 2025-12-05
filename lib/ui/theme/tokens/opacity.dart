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

  /// Pressed state hover effect (0.14)
  static const double pressed = 0.14;

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

  /// Nav/bubble shadow in dark mode (0.24)
  static const double shadowBubble = 0.24;

  /// Border emphasis and outlines (0.25)
  static const double borderEmphasis = 0.25;

  /// Shadow for nav/action buttons (0.28)
  static const double shadowAction = 0.28;

  /// Ghost elements and hints (0.30)
  static const double ghost = 0.30;

  /// Row background dark mode (0.30)
  static const double rowBgDark = 0.30;

  /// Row background light mode (0.50)
  static const double rowBgLight = 0.50;

  /// Field border emphasis (0.32)
  static const double fieldBorder = 0.32;

  /// Switch track and moderate emphasis (0.35)
  static const double track = 0.35;

  /// Disabled state opacity (0.38) - Material standard
  static const double disabled = 0.38;

  /// Light mode borders and dividers (0.40)
  static const double divider = 0.40;

  /// Dark mode shadow opacity (0.42)
  static const double shadowDark = 0.42;

  /// Modal barrier tint (0.45)
  static const double barrier = 0.45;

  /// Shadow for emphasized/next elements (0.12)
  static const double shadowStrong = 0.12;

  /// Shadow for regular elements (0.06)
  static const double shadowLight = 0.06;

  /// Subtle overlays and shadows (0.50)
  static const double subtle = 0.50;

  /// Disabled button content (0.55)
  static const double buttonDisabled = 0.55;

  /// Soft content and backgrounds (0.60)
  static const double soft = 0.60;

  /// Disabled button opacity (0.65) - for entire button fade
  static const double disabledButton = 0.65;

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

  /// Label gradient end (0.86)
  static const double labelGradient = 0.86;

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

  /// Almost opaque surfaces (0.98)
  static const double solid = 0.98;

  /// Fully opaque (1.0)
  static const double opaque = 1.0;
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

  /// Switch component scale (0.85)
  static const double switchScale = 0.85;

  /// Preview image height ratio (0.45 = 45% of screen)
  static const double previewHeightRatio = 0.45;

  /// Narrow slidable action extent ratio (0.3 = 30%)
  static const double slideExtentNarrow = 0.3;

  /// Slidable action extent ratio (0.4 = 40%)
  static const double slideExtent = 0.4;

  /// Crop dialog width ratio (0.8 = 80% of screen)
  static const double cropDialogRatio = 0.8;

  /// Sheet max height ratio (0.85 = 85% of screen)
  static const double sheetHeightRatio = 0.85;
}
