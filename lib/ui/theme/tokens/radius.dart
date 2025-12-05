// ═══════════════════════════════════════════════════════════════════════════════
// RADIUS TOKENS
// ═══════════════════════════════════════════════════════════════════════════════
//
// Border radius scale for consistent rounded corners.
//
// Usage: AppTokens.radius.md, AppTokens.radius.pill
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// Border radius tokens.
class AppRadius {
  const AppRadius();

  /// 2px - Micro radius for handles and subtle rounding.
  final BorderRadius micro = const BorderRadius.all(Radius.circular(2));

  /// 4px - Micro-plus radius.
  final BorderRadius microPlus = const BorderRadius.all(Radius.circular(4));

  /// 6px - Extra-small radius for checkboxes and subtle rounding.
  final BorderRadius xs = const BorderRadius.all(Radius.circular(6));

  /// 8px - Small radius.
  final BorderRadius sm = const BorderRadius.all(Radius.circular(8));

  /// 10px - Chip radius (between sm and md).
  final BorderRadius chip = const BorderRadius.all(Radius.circular(10));

  /// 12px - Medium radius.
  final BorderRadius md = const BorderRadius.all(Radius.circular(12));

  /// 14px - Popup/list tile radius (between md and lg).
  final BorderRadius popup = const BorderRadius.all(Radius.circular(14));

  /// 16px - Large radius.
  final BorderRadius lg = const BorderRadius.all(Radius.circular(16));

  /// 20px - Sheet/dialog radius.
  final BorderRadius sheet = const BorderRadius.all(Radius.circular(20));

  /// 24px - Extra large radius.
  final BorderRadius xl = const BorderRadius.all(Radius.circular(24));

  /// 26px - Button radius (between xl and xxl).
  final BorderRadius button = const BorderRadius.all(Radius.circular(26));

  /// 28px - Extra extra large radius.
  final BorderRadius xxl = const BorderRadius.all(Radius.circular(28));

  /// 32px - Extra extra extra large radius.
  final BorderRadius xxxl = const BorderRadius.all(Radius.circular(32));

  /// 999px - Fully rounded "pill" shape for chips, badges, and buttons.
  final BorderRadius pill = const BorderRadius.all(Radius.circular(999));

  /// Creates a custom circular BorderRadius.
  BorderRadius circular(double value) =>
      BorderRadius.all(Radius.circular(value));
}
