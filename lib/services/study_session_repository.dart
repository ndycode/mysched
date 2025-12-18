import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/app_log.dart';
import 'user_scope.dart';

const _scope = 'StudySessionRepo';

/// Represents a completed study session.
class StudySessionRecord {
  const StudySessionRecord({
    required this.id,
    required this.userId,
    required this.sessionType,
    required this.durationMinutes,
    required this.startedAt,
    required this.completedAt,
    this.classId,
    this.classTitle,
    this.skipped = false,
    this.createdAt,
  });

  final int id;
  final String userId;
  final String sessionType; // 'work', 'short_break', 'long_break'
  final int durationMinutes;
  final DateTime startedAt;
  final DateTime completedAt;
  final int? classId;
  final String? classTitle;
  final bool skipped;
  final DateTime? createdAt;

  factory StudySessionRecord.fromMap(Map<String, dynamic> map) {
    return StudySessionRecord(
      id: (map['id'] as num).toInt(),
      userId: map['user_id'] as String,
      sessionType: map['session_type'] as String,
      durationMinutes: (map['duration_minutes'] as num).toInt(),
      startedAt: DateTime.parse(map['started_at'] as String),
      completedAt: DateTime.parse(map['completed_at'] as String),
      classId: map['class_id'] != null ? (map['class_id'] as num).toInt() : null,
      classTitle: map['class_title'] as String?,
      skipped: map['skipped'] as bool? ?? false,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toInsertMap() => {
    'user_id': userId,
    'session_type': sessionType,
    'duration_minutes': durationMinutes,
    'started_at': startedAt.toUtc().toIso8601String(),
    'completed_at': completedAt.toUtc().toIso8601String(),
    if (classId != null) 'class_id': classId,
    if (classTitle != null) 'class_title': classTitle,
    'skipped': skipped,
  };
}

/// Repository for managing study sessions in Supabase.
class StudySessionRepository extends ChangeNotifier {
  StudySessionRepository._();
  static final StudySessionRepository instance = StudySessionRepository._();

  SupabaseClient get _client => Supabase.instance.client;

  List<StudySessionRecord> _sessions = [];
  DateTime? _lastFetched;
  bool _loading = false;

  /// Cached sessions (in-memory).
  List<StudySessionRecord> get sessions => List.unmodifiable(_sessions);

  /// Whether a fetch is in progress.
  bool get loading => _loading;

  /// Save a completed session to Supabase.
  Future<void> saveSession({
    required String sessionType,
    required int durationMinutes,
    required DateTime startedAt,
    required DateTime completedAt,
    int? classId,
    String? classTitle,
    bool skipped = false,
  }) async {
    final userId = UserScope.currentUserId();
    if (userId == null) {
      AppLog.warn(_scope, 'Cannot save session - not authenticated');
      return;
    }

    try {
      final data = {
        'user_id': userId,
        'session_type': sessionType,
        'duration_minutes': durationMinutes,
        'started_at': startedAt.toUtc().toIso8601String(),
        'completed_at': completedAt.toUtc().toIso8601String(),
        if (classId != null) 'class_id': classId,
        if (classTitle != null) 'class_title': classTitle,
        'skipped': skipped,
      };

      await _client.from('study_sessions').insert(data);
      
      AppLog.info(_scope, 'Saved study session', data: {
        'type': sessionType,
        'minutes': durationMinutes,
        'skipped': skipped,
      });

      // Invalidate cache so next fetch gets fresh data
      _lastFetched = null;
      
      // Optimistically add to local cache
      _sessions.insert(0, StudySessionRecord(
        id: 0, // Temp ID
        userId: userId,
        sessionType: sessionType,
        durationMinutes: durationMinutes,
        startedAt: startedAt,
        completedAt: completedAt,
        classId: classId,
        classTitle: classTitle,
        skipped: skipped,
        createdAt: DateTime.now(),
      ));
      notifyListeners();
    } catch (e, stack) {
      AppLog.error(_scope, 'Failed to save session', error: e, stack: stack);
    }
  }

  /// Fetch sessions from Supabase.
  Future<List<StudySessionRecord>> fetchSessions({
    bool forceRefresh = false,
    int limit = 100,
  }) async {
    final userId = UserScope.currentUserId();
    if (userId == null) return [];

    // Use cache if fresh (5 minutes)
    if (!forceRefresh && 
        _lastFetched != null && 
        DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5)) {
      return _sessions;
    }

    _loading = true;
    notifyListeners();

    try {
      final response = await _client
          .from('study_sessions')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false)
          .limit(limit);

      _sessions = (response as List)
          .cast<Map<String, dynamic>>()
          .map(StudySessionRecord.fromMap)
          .toList();
      
      _lastFetched = DateTime.now();
      _loading = false;
      notifyListeners();

      AppLog.debug(_scope, 'Fetched ${_sessions.length} sessions');
      return _sessions;
    } catch (e, stack) {
      _loading = false;
      notifyListeners();
      AppLog.error(_scope, 'Failed to fetch sessions', error: e, stack: stack);
      return _sessions;
    }
  }

  /// Get sessions for today.
  List<StudySessionRecord> getTodaySessions() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return _sessions.where((s) => 
      s.completedAt.isAfter(todayStart) && 
      s.sessionType == 'work' &&
      !s.skipped
    ).toList();
  }

  /// Get total minutes studied today.
  int getTodayMinutes() {
    return getTodaySessions().fold(0, (sum, s) => sum + s.durationMinutes);
  }

  /// Get session count for today.
  int getTodaySessionCount() => getTodaySessions().length;

  /// Clear cached data (call on logout).
  void clear() {
    _sessions = [];
    _lastFetched = null;
    notifyListeners();
  }
}
