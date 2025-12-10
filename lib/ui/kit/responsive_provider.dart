import 'package:flutter/material.dart';

import '../theme/tokens/layout.dart';
import '../theme/tokens/responsive.dart';

/// Provides responsive scale factors to descendant widgets.
///
/// Wrap your widget tree with [ResponsiveProvider] to make scale factors
/// available throughout the app. Access via static methods:
///
/// ```dart
/// final scale = ResponsiveProvider.scale(context);
/// final spacingScale = ResponsiveProvider.spacing(context);
/// ```
class ResponsiveProvider extends InheritedWidget {
  const ResponsiveProvider({
    super.key,
    required this.scaleFactor,
    required this.textScale,
    required this.spacingScale,
    required this.screenWidth,
    required super.child,
  });

  /// Scale factor for icons and component sizing (0.92 - 1.10).
  final double scaleFactor;

  /// Scale factor for typography - gentler to preserve readability (0.96 - 1.06).
  final double textScale;

  /// Gentler scale factor for spacing adjustments (0.94 - 1.06).
  final double spacingScale;

  /// Current screen width in logical pixels.
  final double screenWidth;

  /// Gets the [ResponsiveProvider] from the widget tree, if available.
  static ResponsiveProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ResponsiveProvider>();
  }

  /// Gets the component/icon scale factor.
  ///
  /// Returns 1.0 if no provider is found in the tree.
  static double scale(BuildContext context) {
    return maybeOf(context)?.scaleFactor ?? 1.0;
  }

  /// Gets the typography scale factor (gentler, preserves readability).
  ///
  /// Returns 1.0 if no provider is found in the tree.
  static double text(BuildContext context) {
    return maybeOf(context)?.textScale ?? 1.0;
  }

  /// Gets the spacing scale factor (gentler adjustment).
  ///
  /// Returns 1.0 if no provider is found in the tree.
  static double spacing(BuildContext context) {
    return maybeOf(context)?.spacingScale ?? 1.0;
  }

  /// Gets the current screen width.
  ///
  /// Returns [AppLayout.referenceWidth] if no provider is found.
  static double width(BuildContext context) {
    return maybeOf(context)?.screenWidth ?? AppLayout.referenceWidth;
  }

  /// Check if current screen is compact (narrower than reference).
  static bool isCompact(BuildContext context) {
    return AppResponsive.isCompact(width(context));
  }

  /// Check if current screen is wide (tablet-like).
  static bool isWide(BuildContext context) {
    return AppResponsive.isWide(width(context));
  }

  @override
  bool updateShouldNotify(ResponsiveProvider oldWidget) {
    return scaleFactor != oldWidget.scaleFactor ||
        textScale != oldWidget.textScale ||
        spacingScale != oldWidget.spacingScale ||
        screenWidth != oldWidget.screenWidth;
  }
}

/// Extension on [BuildContext] for convenient access to responsive values.
extension ResponsiveContext on BuildContext {
  /// Get the component/icon scale factor.
  double get responsiveScale => ResponsiveProvider.scale(this);

  /// Get the typography scale factor.
  double get responsiveTextScale => ResponsiveProvider.text(this);

  /// Get the spacing scale factor.
  double get responsiveSpacing => ResponsiveProvider.spacing(this);

  /// Check if screen is compact (narrow).
  bool get isCompactScreen => ResponsiveProvider.isCompact(this);

  /// Check if screen is wide (tablet-like).
  bool get isWideScreen => ResponsiveProvider.isWide(this);
}
