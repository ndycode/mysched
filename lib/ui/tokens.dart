import 'package:flutter/material.dart';

/// Consolidated design tokens aligned with dashboard specs.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double quad = 48;
}

class AppRadius {
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}

class AppIconSize {
  static const double md = 20;
  static const double lg = 28;
}

class AppComponentSize {
  static const double buttonMd = 48;
}

class AppShadow {
  static const double md = 12;
}

class AppLayout {
  static const double contentMaxWidth = 560;
}

class AppTypography {
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.3,
  );

  static const TextStyle captionMuted = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.grey,
    letterSpacing: 0,
    height: 1.3,
  );
}
