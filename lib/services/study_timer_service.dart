import 'dart:async';
import 'package:flutter/foundation.dart';

/// Timer states for the Pomodoro timer.
enum TimerState {
  /// Timer is idle/stopped.
  idle,
  /// Timer is counting down.
  running,
  /// Timer is paused.
  paused,
  /// Timer has completed.
  completed,
}

/// Session types for the Pomodoro timer.
enum SessionType {
  /// Work/study session.
  work,
  /// Short break.
  shortBreak,
  /// Long break after multiple work sessions.
  longBreak,
}

/// Configuration for the study timer.
class TimerConfig {
  const TimerConfig({
    this.workMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
  });

  /// Duration of a work session in minutes.
  final int workMinutes;

  /// Duration of a short break in minutes.
  final int shortBreakMinutes;

  /// Duration of a long break in minutes.
  final int longBreakMinutes;

  /// Number of work sessions before a long break.
  final int sessionsBeforeLongBreak;

  /// Copy with new values.
  TimerConfig copyWith({
    int? workMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsBeforeLongBreak,
  }) {
    return TimerConfig(
      workMinutes: workMinutes ?? this.workMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      sessionsBeforeLongBreak: sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
    );
  }
}

/// A study timer session record.
class StudySession {
  const StudySession({
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.sessionType,
    this.classId,
    this.classTitle,
  });

  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final SessionType sessionType;
  final int? classId;
  final String? classTitle;
}

/// Service for managing a Pomodoro-style study timer.
class StudyTimerService extends ChangeNotifier {
  StudyTimerService._();
  static final StudyTimerService instance = StudyTimerService._();

  Timer? _timer;
  TimerState _state = TimerState.idle;
  SessionType _sessionType = SessionType.work;
  
  /// Remaining seconds in the current session.
  int _remainingSeconds = 0;
  
  /// Total seconds for the current session (for progress calculation).
  int _totalSeconds = 0;
  
  /// Number of completed work sessions.
  int _completedSessions = 0;
  
  /// Time when the current session started (for tracking).
  DateTime? _sessionStartTime;
  
  /// Linked class for this timer session.
  int? _linkedClassId;
  String? _linkedClassTitle;
  
  /// Timer configuration.
  TimerConfig _config = const TimerConfig();
  
  /// History of completed sessions.
  final List<StudySession> _history = [];

  // Getters
  TimerState get state => _state;
  SessionType get sessionType => _sessionType;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  int get completedSessions => _completedSessions;
  int? get linkedClassId => _linkedClassId;
  String? get linkedClassTitle => _linkedClassTitle;
  TimerConfig get config => _config;
  List<StudySession> get history => List.unmodifiable(_history);

  /// Progress from 0.0 to 1.0.
  double get progress {
    if (_totalSeconds == 0) return 0;
    return 1.0 - (_remainingSeconds / _totalSeconds);
  }

  /// Formatted time string (MM:SS).
  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Total study time today in minutes.
  int get todayStudyMinutes {
    final today = DateTime.now();
    return _history
        .where((s) =>
            s.sessionType == SessionType.work &&
            s.startTime.year == today.year &&
            s.startTime.month == today.month &&
            s.startTime.day == today.day)
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  /// Update timer configuration.
  void updateConfig(TimerConfig newConfig) {
    _config = newConfig;
    // If idle, update the display time
    if (_state == TimerState.idle) {
      _setSessionDuration();
    }
    notifyListeners();
  }

  /// Link a class to the current timer session.
  void linkClass({required int classId, required String classTitle}) {
    _linkedClassId = classId;
    _linkedClassTitle = classTitle;
    notifyListeners();
  }

  /// Unlink the current class.
  void unlinkClass() {
    _linkedClassId = null;
    _linkedClassTitle = null;
    notifyListeners();
  }

  /// Start the timer.
  void start() {
    if (_state == TimerState.running) return;

    if (_state == TimerState.idle || _state == TimerState.completed) {
      _setSessionDuration();
      _sessionStartTime = DateTime.now();
    }

    _state = TimerState.running;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  /// Pause the timer.
  void pause() {
    if (_state != TimerState.running) return;

    _timer?.cancel();
    _state = TimerState.paused;
    notifyListeners();
  }

  /// Resume from paused state.
  void resume() {
    if (_state != TimerState.paused) return;
    start();
  }

  /// Stop and reset the timer.
  void stop() {
    _timer?.cancel();
    _state = TimerState.idle;
    _sessionType = SessionType.work;
    _setSessionDuration();
    _sessionStartTime = null;
    notifyListeners();
  }

  /// Skip to the next session type.
  void skip() {
    _timer?.cancel();
    _completeSession(skipped: true);
    _advanceToNextSession();
    notifyListeners();
  }

  /// Reset all progress.
  void reset() {
    _timer?.cancel();
    _state = TimerState.idle;
    _sessionType = SessionType.work;
    _completedSessions = 0;
    _setSessionDuration();
    _sessionStartTime = null;
    _linkedClassId = null;
    _linkedClassTitle = null;
    notifyListeners();
  }

  void _tick(Timer timer) {
    if (_remainingSeconds > 0) {
      _remainingSeconds--;
      notifyListeners();
    } else {
      // Session completed
      timer.cancel();
      _completeSession(skipped: false);
      _state = TimerState.completed;
      notifyListeners();
    }
  }

  void _setSessionDuration() {
    switch (_sessionType) {
      case SessionType.work:
        _totalSeconds = _config.workMinutes * 60;
        break;
      case SessionType.shortBreak:
        _totalSeconds = _config.shortBreakMinutes * 60;
        break;
      case SessionType.longBreak:
        _totalSeconds = _config.longBreakMinutes * 60;
        break;
    }
    _remainingSeconds = _totalSeconds;
  }

  void _completeSession({required bool skipped}) {
    if (_sessionStartTime == null) return;

    final endTime = DateTime.now();
    final actualMinutes = endTime.difference(_sessionStartTime!).inMinutes;

    // Only record if we actually studied for at least 1 minute
    if (!skipped && actualMinutes >= 1) {
      _history.add(StudySession(
        startTime: _sessionStartTime!,
        endTime: endTime,
        durationMinutes: actualMinutes,
        sessionType: _sessionType,
        classId: _linkedClassId,
        classTitle: _linkedClassTitle,
      ));

      if (_sessionType == SessionType.work) {
        _completedSessions++;
      }
    }

    _sessionStartTime = null;
  }

  void _advanceToNextSession() {
    if (_sessionType == SessionType.work) {
      // Check if long break is due
      if (_completedSessions > 0 &&
          _completedSessions % _config.sessionsBeforeLongBreak == 0) {
        _sessionType = SessionType.longBreak;
      } else {
        _sessionType = SessionType.shortBreak;
      }
    } else {
      // After break, go back to work
      _sessionType = SessionType.work;
    }

    _state = TimerState.idle;
    _setSessionDuration();
    _sessionStartTime = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
