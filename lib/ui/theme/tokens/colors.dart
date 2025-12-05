import 'package:flutter/material.dart';

/// Semantic color constants for use outside theme context.
///
/// Use these for cases where theme colors aren't available or for
/// fixed-color UI elements like alarm screens and theme previews.
class AppSemanticColor {
  const AppSemanticColor._();

  /// Pure white for light text on dark backgrounds.
  static const Color white = Colors.white;

  /// Pure black for dark text on light backgrounds.
  static const Color black = Colors.black;

  /// Semi-transparent black for scrim overlays (54% opacity).
  static const Color scrim = Colors.black54;
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

