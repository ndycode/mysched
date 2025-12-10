/// Centralized layout constraint tokens.
///
/// Use these for consistent sheet widths, safe padding, and content constraints.
class AppLayout {
  const AppLayout._();

  /// Bottom navigation safe padding (accounts for nav bar + FAB).
  static const double bottomNavSafePadding = 120.0;

  /// Maximum width for modal sheets.
  static const double sheetMaxWidth = 520.0;

  /// Minimum height for modal sheets (ensures content visibility).
  static const double sheetMinHeight = 360.0;

  /// Maximum height ratio for modal sheets (78% of screen).
  static const double sheetMaxHeightRatio = 0.78;

  /// Maximum width for dialogs.
  static const double dialogMaxWidth = 400.0;

  /// Standard width for small confirmation dialogs.
  static const double dialogWidthSmall = 340.0;

  /// Maximum height ratio for dialogs (60% of screen).
  static const double dialogMaxHeightRatio = 0.6;

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

  /// Reference screen width for baseline scaling (Pixel 8 Pro ~412dp).
  /// Components designed at this width will have a scale factor of 1.0.
  /// Compact devices (360dp) will scale DOWN slightly.
  static const double referenceWidth = 412.0;

  /// Screen width threshold below which screen is considered compact.
  static const double compactThreshold = 380.0;

  /// Screen width threshold above which screen is considered wide/tablet.
  static const double wideThreshold = 600.0;
}

/// Display limits for dashboard previews and lists.
class AppDisplayLimits {
  const AppDisplayLimits._();

  /// Maximum reminders to show in dashboard preview.
  static const int reminderPreviewCount = 3;

  /// Maximum classes to show in dashboard schedule preview.
  static const int schedulePreviewCount = 5;
}
