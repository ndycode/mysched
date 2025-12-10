// ═══════════════════════════════════════════════════════════════════════════════
// RESPONSIVE TOKENS
// ═══════════════════════════════════════════════════════════════════════════════
//
// Responsive scaling utility for adapting UI to different screen sizes.
// Provides scale factors based on screen width vs a reference baseline.
//
// Usage: AppResponsive.scaleFactor(screenWidth)
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'layout.dart';

/// Responsive scaling utility for adapting UI to different screen sizes.
///
/// Calculates scale factors based on screen width compared to a reference
/// baseline defined in [AppLayout.referenceWidth]. This allows components
/// to gracefully adapt to smaller devices (like Infinix Hot 30i at ~360dp)
/// and larger tablets.
class AppResponsive {
  const AppResponsive._();

  /// Minimum scale factor to prevent extreme shrinking on very small screens.
  /// Used for icons and non-text elements.
  static const double minScale = 0.92;

  /// Maximum scale factor - capped at 1.0 to prevent upscaling on standard screens.
  static const double maxScale = 1.0;

  /// Minimum text scale - text should NOT shrink much to preserve readability.
  static const double minTextScale = 0.96;

  /// Maximum text scale - capped at 1.0 to prevent upscaling.
  static const double maxTextScale = 1.0;

  /// Minimum spacing scale - gentler minimum for padding/margins.
  static const double minSpacingScale = 0.94;

  /// Maximum spacing scale - capped at 1.0 to prevent upscaling.
  static const double maxSpacingScale = 1.0;

  /// Calculate scale factor based on screen width.
  ///
  /// Returns a value between [minScale] and [maxScale].
  /// Use this for icons and component sizing (NOT typography).
  ///
  /// Example:
  /// ```dart
  /// final scale = AppResponsive.scaleFactor(360); // ~0.92 on small device
  /// final iconSize = 24 * scale; // Scales down proportionally
  /// ```
  static double scaleFactor(double screenWidth) {
    final ratio = screenWidth / AppLayout.referenceWidth;
    return ratio.clamp(minScale, maxScale);
  }

  /// Typography-specific scale factor with gentler minimum.
  ///
  /// Returns a value between [minTextScale] and [maxTextScale].
  /// Text should NOT shrink as aggressively as icons to preserve readability.
  ///
  /// Example:
  /// ```dart
  /// final textScale = AppResponsive.scaleTypography(360); // ~0.96
  /// final fontSize = 14 * textScale; // Minimal reduction for readability
  /// ```
  static double scaleTypography(double screenWidth) {
    final ratio = screenWidth / AppLayout.referenceWidth;
    return ratio.clamp(minTextScale, maxTextScale);
  }

  /// Gentler scale factor for spacing (less aggressive adjustment).
  ///
  /// Returns a value between [minSpacingScale] and [maxSpacingScale].
  /// Use this for padding, margins, and gaps where extreme scaling
  /// could hurt readability or touch targets.
  ///
  /// Example:
  /// ```dart
  /// final spacingScale = AppResponsive.scaleCompact(360); // ~0.94
  /// final padding = 24 * spacingScale; // Gentle reduction
  /// ```
  static double scaleCompact(double screenWidth) {
    final ratio = screenWidth / AppLayout.referenceWidth;
    // Map ratio to a compressed range for gentler adjustment
    // ratio 0.85 -> 0.94, ratio 1.0 -> 1.0, ratio 1.15 -> 1.06
    final normalized = (ratio - 1.0) * 0.4 + 1.0;
    return normalized.clamp(minSpacingScale, maxSpacingScale);
  }

  /// Check if the screen is considered compact (narrower than reference).
  static bool isCompact(double screenWidth) {
    return screenWidth < AppLayout.compactThreshold;
  }

  /// Check if the screen is considered wide (tablet-like).
  static bool isWide(double screenWidth) {
    return screenWidth > AppLayout.wideThreshold;
  }
}
