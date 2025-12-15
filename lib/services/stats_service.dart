import 'package:flutter/foundation.dart';

import '../utils/app_log.dart';
import 'study_timer_service.dart';

const _scope = 'StatsService';

/// Aggregated study statistics.
class StudyStats {
  const StudyStats({
    this.todayMinutes = 0,
    this.weekMinutes = 0,
    this.monthMinutes = 0,
    this.totalSessions = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.dailyData,
  });

  /// Study time today in minutes.
  final int todayMinutes;

  /// Study time this week in minutes.
  final int weekMinutes;

  /// Study time this month in minutes.
  final int monthMinutes;

  /// Total completed sessions.
  final int totalSessions;

  /// Current daily study streak.
  final int currentStreak;

  /// Longest ever daily study streak.
  final int longestStreak;

  /// Daily study minutes for the last 7 days.
  /// Index 0 = 6 days ago, Index 6 = today.
  final List<DailyStudyData> dailyData;

  /// Formatted study time string.
  static String formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
}

/// Study data for a single day.
class DailyStudyData {
  const DailyStudyData({
    required this.date,
    required this.minutes,
    required this.sessions,
  });

  final DateTime date;
  final int minutes;
  final int sessions;

  bool get hasStudied => minutes > 0;
}

/// Service for aggregating and calculating study statistics.
class StatsService extends ChangeNotifier {
  StatsService._();
  static final StatsService instance = StatsService._();

  StudyStats? _cachedStats;
  DateTime? _lastCalculated;

  /// Get current study statistics.
  StudyStats get stats {
    final now = DateTime.now();
    
    // Recalculate if cache is stale (older than 1 minute)
    if (_cachedStats == null ||
        _lastCalculated == null ||
        now.difference(_lastCalculated!) > const Duration(minutes: 1)) {
      _calculateStats();
    }
    
    return _cachedStats!;
  }

  /// Force recalculation of stats.
  void refresh() {
    _calculateStats();
    notifyListeners();
  }

  void _calculateStats() {
    final timer = StudyTimerService.instance;
    final sessions = timer.history;
    final now = DateTime.now();
    
    // Calculate time periods
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    
    // Filter work sessions only
    final workSessions = sessions.where((s) => s.sessionType == SessionType.work).toList();
    
    // Calculate totals
    int todayMinutes = 0;
    int weekMinutes = 0;
    int monthMinutes = 0;
    
    for (final session in workSessions) {
      if (session.startTime.isAfter(todayStart)) {
        todayMinutes += session.durationMinutes;
      }
      if (session.startTime.isAfter(weekStart)) {
        weekMinutes += session.durationMinutes;
      }
      if (session.startTime.isAfter(monthStart)) {
        monthMinutes += session.durationMinutes;
      }
    }
    
    // Calculate daily data for last 7 days
    final dailyData = <DailyStudyData>[];
    for (int i = 6; i >= 0; i--) {
      final date = todayStart.subtract(Duration(days: i));
      final nextDay = date.add(const Duration(days: 1));
      
      final daySessions = workSessions.where((s) =>
          s.startTime.isAfter(date) && s.startTime.isBefore(nextDay));
      
      final dayMinutes = daySessions.fold(0, (sum, s) => sum + s.durationMinutes);
      
      dailyData.add(DailyStudyData(
        date: date,
        minutes: dayMinutes,
        sessions: daySessions.length,
      ));
    }
    
    // Calculate streaks
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    
    // Check from today backwards
    for (int i = dailyData.length - 1; i >= 0; i--) {
      if (dailyData[i].hasStudied) {
        tempStreak++;
        if (i == dailyData.length - 1 || i == dailyData.length - 2) {
          // Include today or yesterday in current streak
          currentStreak = tempStreak;
        }
      } else {
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 0;
      }
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
    
    _cachedStats = StudyStats(
      todayMinutes: todayMinutes,
      weekMinutes: weekMinutes,
      monthMinutes: monthMinutes,
      totalSessions: workSessions.length,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      dailyData: dailyData,
    );
    _lastCalculated = now;
    
    AppLog.debug(_scope, 'Stats calculated', data: {
      'today': todayMinutes,
      'week': weekMinutes,
      'sessions': workSessions.length,
    });
  }

  /// Clear cached stats (call on logout).
  void clear() {
    _cachedStats = null;
    _lastCalculated = null;
  }
}
