import 'dart:async';

import 'telemetry_service.dart';

/// Throttle window for UI tap events to prevent excessive logging.
const _kThrottleWindow = Duration(milliseconds: 300);

/// Event prefixes that should be throttled to reduce volume.
const _kThrottledPrefixes = ['ui_tap_', 'ui_haptic_'];

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  /// Tracks the last time each event was logged for throttling.
  final Map<String, DateTime> _lastEventTimes = {};

  /// Logs an analytics event.
  ///
  /// UI tap events (prefixed with `ui_tap_` or `ui_haptic_`) are throttled
  /// to prevent excessive logging from rapid repeated taps.
  Future<void> logEvent(String eventName,
      {Map<String, dynamic>? params}) async {
    try {
      // Check if this event should be throttled
      if (_shouldThrottle(eventName)) {
        final now = DateTime.now();
        final lastTime = _lastEventTimes[eventName];
        if (lastTime != null && now.difference(lastTime) < _kThrottleWindow) {
          // Skip this event - too soon after the last one
          return;
        }
        _lastEventTimes[eventName] = now;

        // Cleanup old entries periodically to prevent memory growth
        if (_lastEventTimes.length > 100) {
          _cleanupOldEntries(now);
        }
      }

      TelemetryService.instance.recordEvent(eventName, data: params);
    } catch (_) {
      // Swallow errors to avoid crashing callers if telemetry is unavailable.
    }
  }

  /// Returns true if the event should be subject to throttling.
  bool _shouldThrottle(String eventName) {
    for (final prefix in _kThrottledPrefixes) {
      if (eventName.startsWith(prefix)) return true;
    }
    return false;
  }

  /// Removes entries older than 1 second to prevent memory growth.
  void _cleanupOldEntries(DateTime now) {
    final cutoff = now.subtract(const Duration(seconds: 1));
    _lastEventTimes.removeWhere((_, time) => time.isBefore(cutoff));
  }
}
