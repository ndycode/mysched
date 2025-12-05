import 'package:flutter/material.dart';

/// Urgency level enum for time-sensitive items.
///
/// Used to determine visual styling for schedules and reminders
/// based on how soon they occur.
enum UrgencyLevel {
  /// Currently active/live (happening now)
  live,

  /// Imminent - starting within 1 hour
  imminent,

  /// Soon - starting within 3 hours
  soon,

  /// Upcoming - starting within 24 hours (today)
  upcoming,

  /// Default - more than 24 hours away or no urgency
  none,
}

/// Time thresholds for urgency levels (in minutes).
///
/// These define when each urgency level activates based on
/// time remaining until an event starts.
class AppUrgencyThreshold {
  const AppUrgencyThreshold._();

  /// Threshold for "imminent" urgency (60 minutes = 1 hour)
  static const int imminent = 60;

  /// Threshold for "soon" urgency (180 minutes = 3 hours)
  static const int soon = 180;

  /// Threshold for "upcoming" urgency (1440 minutes = 24 hours)
  static const int upcoming = 1440;
}

/// Urgency-based color resolver.
///
/// Provides colors from the theme's ColorScheme based on urgency level.
/// This ensures consistent visual hierarchy across schedules and reminders.
class AppUrgencyColor {
  const AppUrgencyColor._();

  /// Get the primary color for an urgency level.
  ///
  /// Returns the appropriate theme color based on urgency:
  /// - [UrgencyLevel.live]: primary (blue) - currently happening
  /// - [UrgencyLevel.imminent]: warning (amber) - act now
  /// - [UrgencyLevel.soon]: tertiary (teal/purple) - prepare soon
  /// - [UrgencyLevel.upcoming]: secondary - later today
  /// - [UrgencyLevel.none]: null (use default styling)
  static Color? resolve(UrgencyLevel level, ColorScheme colors) {
    return switch (level) {
      UrgencyLevel.live => colors.primary,
      UrgencyLevel.imminent => colors.error.withValues(alpha: 0.0) == colors.error 
          ? _warningFallback(colors) // Use warning color
          : _warningFallback(colors),
      UrgencyLevel.soon => colors.tertiary,
      UrgencyLevel.upcoming => colors.secondary,
      UrgencyLevel.none => null,
    };
  }

  /// Fallback warning color (amber/orange) since ColorScheme doesn't have warning.
  static Color _warningFallback(ColorScheme colors) {
    // Use a warm amber that works in both light and dark themes
    return colors.brightness == Brightness.dark
        ? const Color(0xFFFFB74D) // Amber 300
        : const Color(0xFFF57C00); // Orange 700
  }

  /// Get warning color directly.
  static Color warning(ColorScheme colors) => _warningFallback(colors);
}

/// Utility to calculate urgency level from time difference.
///
/// Use this to determine the urgency level for a scheduled item
/// based on its start time relative to now.
class AppUrgency {
  const AppUrgency._();

  /// Calculate urgency level based on start time.
  ///
  /// [startTime] - When the event starts
  /// [now] - Current time (optional, defaults to DateTime.now())
  /// [endTime] - When the event ends (optional, for detecting "live" status)
  ///
  /// Returns the appropriate [UrgencyLevel] based on time remaining.
  static UrgencyLevel calculate({
    required DateTime startTime,
    DateTime? now,
    DateTime? endTime,
  }) {
    final currentTime = now ?? DateTime.now();

    // Check if currently live (between start and end)
    if (endTime != null) {
      if (currentTime.isAfter(startTime) && currentTime.isBefore(endTime)) {
        return UrgencyLevel.live;
      }
    }

    // If start time is in the past and not live, no urgency
    if (startTime.isBefore(currentTime)) {
      return UrgencyLevel.none;
    }

    // Calculate minutes until start
    final minutesUntil = startTime.difference(currentTime).inMinutes;

    if (minutesUntil < AppUrgencyThreshold.imminent) {
      return UrgencyLevel.imminent;
    } else if (minutesUntil < AppUrgencyThreshold.soon) {
      return UrgencyLevel.soon;
    } else if (minutesUntil < AppUrgencyThreshold.upcoming) {
      return UrgencyLevel.upcoming;
    }

    return UrgencyLevel.none;
  }

  /// Check if an urgency level should show highlighting.
  ///
  /// Returns true for levels that warrant visual emphasis.
  static bool shouldHighlight(UrgencyLevel level) {
    return level != UrgencyLevel.none;
  }

  /// Get a human-readable label for an urgency level.
  static String label(UrgencyLevel level) {
    return switch (level) {
      UrgencyLevel.live => 'Live',
      UrgencyLevel.imminent => 'Starting soon',
      UrgencyLevel.soon => 'Coming up',
      UrgencyLevel.upcoming => 'Today',
      UrgencyLevel.none => '',
    };
  }
}
