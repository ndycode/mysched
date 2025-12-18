import 'package:flutter/foundation.dart';

import '../utils/app_log.dart';
import 'study_session_repository.dart';
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
  bool _initialized = false;

  /// Get current study statistics.
  StudyStats get stats {
    final now = DateTime.now();
    
    // Return cached stats if fresh (1 minute)
    if (_cachedStats != null &&
        _lastCalculated != null &&
        now.difference(_lastCalculated!) < const Duration(minutes: 1)) {
      return _cachedStats!;
    }
    
    // Calculate from available data
    _calculateStats();
    return _cachedStats!;
  }

  /// Initialize and fetch sessions from Supabase.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    
    try {
      await StudySessionRepository.instance.fetchSessions();
      _calculateStats();
      notifyListeners();
    } catch (e) {
      AppLog.warn(_scope, 'Failed to fetch sessions on init: $e');
    }
  }

  /// Force refresh from Supabase.
  Future<void> refresh() async {
    try {
      await StudySessionRepository.instance.fetchSessions(forceRefresh: true);
      _calculateStats();
      notifyListeners();
    } catch (e) {
      AppLog.warn(_scope, 'Failed to refresh sessions: $e');
    }
  }

  void _calculateStats() {
    final repo = StudySessionRepository.instance;
    final timer = StudyTimerService.instance;
    final now = DateTime.now();
    
    // Calculate time periods
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    
    // Use Supabase sessions if available, fallback to in-memory
    final supabaseSessions = repo.sessions;
    final inMemorySessions = timer.history;
    
    // Calculate totals from Supabase sessions (work sessions only, not skipped)
    int todayMinutes = 0;
    int weekMinutes = 0;
    int monthMinutes = 0;
    int totalSessions = 0;
    
    for (final session in supabaseSessions) {
      if (session.sessionType != 'work' || session.skipped) continue;
      totalSessions++;
      
      if (session.completedAt.isAfter(todayStart)) {
        todayMinutes += session.durationMinutes;
      }
      if (session.completedAt.isAfter(weekStart)) {
        weekMinutes += session.durationMinutes;
      }
      if (session.completedAt.isAfter(monthStart)) {
        monthMinutes += session.durationMinutes;
      }
    }
    
    // Also add in-memory sessions (may not be persisted yet)
    for (final session in inMemorySessions) {
      if (session.sessionType != SessionType.work) continue;
      
      // Check if already counted from Supabase
      final alreadyCounted = supabaseSessions.any((s) =>
        s.durationMinutes == session.durationMinutes &&
        s.startedAt.difference(session.startTime).abs() < const Duration(seconds: 5)
      );
      if (alreadyCounted) continue;
      
      totalSessions++;
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
      
      int dayMinutes = 0;
      int daySessionCount = 0;
      
      // From Supabase
      for (final s in supabaseSessions) {
        if (s.sessionType != 'work' || s.skipped) continue;
        if (s.completedAt.isAfter(date) && s.completedAt.isBefore(nextDay)) {
          dayMinutes += s.durationMinutes;
          daySessionCount++;
        }
      }
      
      // From in-memory (if not already counted)
      for (final s in inMemorySessions) {
        if (s.sessionType != SessionType.work) continue;
        if (s.startTime.isAfter(date) && s.startTime.isBefore(nextDay)) {
          final alreadyCounted = supabaseSessions.any((ss) =>
            ss.durationMinutes == s.durationMinutes &&
            ss.startedAt.difference(s.startTime).abs() < const Duration(seconds: 5)
          );
          if (!alreadyCounted) {
            dayMinutes += s.durationMinutes;
            daySessionCount++;
          }
        }
      }
      
      dailyData.add(DailyStudyData(
        date: date,
        minutes: dayMinutes,
        sessions: daySessionCount,
      ));
    }
    
    // Calculate streaks
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    
    for (int i = dailyData.length - 1; i >= 0; i--) {
      if (dailyData[i].hasStudied) {
        tempStreak++;
        if (i == dailyData.length - 1 || i == dailyData.length - 2) {
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
      totalSessions: totalSessions,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      dailyData: dailyData,
    );
    _lastCalculated = now;
    
    AppLog.debug(_scope, 'Stats calculated', data: {
      'today': todayMinutes,
      'week': weekMinutes,
      'sessions': totalSessions,
    });
  }

  /// Clear cached stats (call on logout).
  void clear() {
    _cachedStats = null;
    _lastCalculated = null;
    _initialized = false;
    StudySessionRepository.instance.clear();
  }
}
