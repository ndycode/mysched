// ═══════════════════════════════════════════════════════════════════════════════
// SPACING TOKENS
// ═══════════════════════════════════════════════════════════════════════════════
//
// Consistent spacing scale for margins, padding, and gaps.
// Based on 4px grid with semantic naming.
//
// Usage: AppTokens.spacing.md, AppTokens.spacing.lg
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// Spacing scale tokens.
class AppSpacing {
  const AppSpacing();

  /// 0px - No spacing.
  final double none = 0;

  /// 1px - Half-micro spacing for pixel-perfect fine-tuning.
  final double microHalf = 1;

  /// 2px - Micro spacing for pixel-perfect fine-tuning.
  final double micro = 2;

  /// 4px - Small micro / Extra small spacing.
  final double microLg = 4;
  final double xs = 4;

  /// 5px - Extra-small half-step for tight chip/badge vertical padding.
  final double xsHalf = 5;

  /// 6px - Extra-small plus spacing.
  final double xsPlus = 6;

  /// 8px - Small spacing.
  final double sm = 8;

  /// 10px - Small-medium spacing.
  final double smMd = 10;

  /// 12px - Medium spacing.
  final double md = 12;

  /// 14px - Medium-large spacing.
  final double mdLg = 14;

  /// 16px - Large spacing (base unit).
  final double lg = 16;

  /// 18px - Large plus spacing for card padding vertical adjustment.
  final double lgPlus = 18;

  /// 20px - Extra large spacing.
  final double xl = 20;

  /// 22px - Extra-large half-step between xl and xxl.
  final double xlHalf = 22;

  /// 24px - Extra extra large spacing.
  final double xxl = 24;

  /// 28px - Extra extra large plus spacing.
  final double xxlPlus = 28;

  /// 32px - Extra extra extra large spacing.
  final double xxxl = 32;

  /// 40px - Quad spacing.
  final double quad = 40;

  /// 64px - Empty state container size.
  final double emptyStateSize = 64;

  // ─────────────────────────────────────────────────────────────────────────────
  // HELPER METHODS
  // ─────────────────────────────────────────────────────────────────────────────

  /// Creates EdgeInsets with uniform spacing on all sides.
  EdgeInsets edgeInsetsAll(double value) => EdgeInsets.all(value);

  /// Creates EdgeInsets with symmetric horizontal/vertical spacing.
  EdgeInsets edgeInsetsSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  /// Creates EdgeInsets with individual side values.
  EdgeInsets edgeInsetsOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
}

