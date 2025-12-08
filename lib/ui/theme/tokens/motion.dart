// ═══════════════════════════════════════════════════════════════════════════════
// MOTION TOKENS
// ═══════════════════════════════════════════════════════════════════════════════
//
// Animation durations, curves, and timing values.
//
// Usage: AppTokens.motion.medium, AppTokens.durations.networkTimeout
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// Motion timing and curve tokens.
class AppMotion {
  const AppMotion();

  // ─────────────────────────────────────────────────────────────────────────────
  // DURATION TOKENS
  // ─────────────────────────────────────────────────────────────────────────────

  /// 80ms - Instant feedback for micro-interactions.
  final Duration instant = const Duration(milliseconds: 80);

  /// 120ms - Fast transitions for quick feedback.
  final Duration fast = const Duration(milliseconds: 120);

  /// 200ms - Medium transitions for standard animations.
  final Duration medium = const Duration(milliseconds: 200);

  /// 320ms - Slow transitions for emphasis.
  final Duration slow = const Duration(milliseconds: 320);

  /// 500ms - Slower transitions for extended animations.
  final Duration slower = const Duration(milliseconds: 500);

  // ─────────────────────────────────────────────────────────────────────────────
  // CURVE TOKENS
  // ─────────────────────────────────────────────────────────────────────────────

  /// Standard ease curve.
  final Curve ease = Curves.easeOutCubic;

  /// Ease in curve.
  final Curve easeIn = Curves.easeInCubic;

  /// Ease out curve.
  final Curve easeOut = Curves.easeOutCubic;

  /// Ease in-out curve.
  final Curve easeInOut = Curves.easeInOutCubic;

  /// Press effect curve.
  final Curve press = Curves.easeOut;

  /// Release effect curve with overshoot.
  final Curve release = Curves.easeOutBack;

  /// Bouncy elastic curve.
  final Curve bounce = Curves.elasticOut;

  /// Spring-like curve with overshoot.
  final Curve spring = Curves.easeOutBack;

  // ─────────────────────────────────────────────────────────────────────────────
  // SCALE VALUES FOR INTERACTIONS
  // ─────────────────────────────────────────────────────────────────────────────

  /// 0.96 - Scale on press.
  final double pressScale = 0.96;

  /// 0.985 - Subtle scale on press.
  final double pressScaleSubtle = 0.985;

  /// 1.02 - Scale on hover.
  final double hoverScale = 1.02;

  // ─────────────────────────────────────────────────────────────────────────────
  // OPACITY VALUES FOR INTERACTIONS
  // ─────────────────────────────────────────────────────────────────────────────

  /// 0.85 - Opacity on press.
  final double pressOpacity = 0.85;

  /// 0.5 - Opacity for disabled state.
  final double disabledOpacity = 0.5;

  /// 0.92 - Opacity on hover.
  final double hoverOpacity = 0.92;
}

/// Extended duration tokens for timeouts, intervals, and delays.
class AppDurations {
  const AppDurations();

  /// 20s - Network request timeout.
  final Duration networkTimeout = const Duration(seconds: 20);

  /// 8s - Quick request timeout (for secondary fetches).
  final Duration quickTimeout = const Duration(seconds: 8);

  /// 1min - Cache time-to-live for schedule data.
  final Duration cacheTtl = const Duration(minutes: 1);

  /// 1min - Ticker interval for time-based UI updates.
  final Duration tickerInterval = const Duration(minutes: 1);

  /// 1min - Heads-up notification lead time before alarm.
  final Duration headsUpLead = const Duration(minutes: 1);

  /// 3s - Minimum interval between schedule fetches.
  final Duration fetchDebounce = const Duration(seconds: 3);

  /// 3s - Default snackbar display duration.
  final Duration snackbarDuration = const Duration(seconds: 3);

  /// 1hr - Default snooze duration for reminders.
  final Duration defaultSnooze = const Duration(hours: 1);

  /// 220ms - Animation delay for staggered reveals.
  final Duration staggerDelay = const Duration(milliseconds: 220);

  /// 500ms - Delay before form submission feedback.
  final Duration submitDelay = const Duration(milliseconds: 500);

  /// 1s - Duration for UI highlight effects (e.g., scroll-to-day).
  final Duration highlightDuration = const Duration(seconds: 1);

  /// 2.5s - Duration for audio preview playback indicator.
  final Duration previewDuration = const Duration(milliseconds: 2500);

  /// 800ms - Minimum splash screen display time.
  final Duration splashMinDisplay = const Duration(milliseconds: 800);

  /// 500ms - Delay before refreshing settings after returning from system settings.
  final Duration settingsRefreshDelay = const Duration(milliseconds: 500);

  /// 8px - Small slide offset for fast/subtle animations.
  final double slideOffsetSm = 8;

  /// 20px - Medium slide offset for dramatic animations.
  final double slideOffsetMd = 20;
}
