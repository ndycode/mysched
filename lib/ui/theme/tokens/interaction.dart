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
