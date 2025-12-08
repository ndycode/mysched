import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/app_exceptions.dart';
import '../utils/app_log.dart';
import '../utils/instructor_utils.dart';
import '../ui/theme/motion.dart';
import 'connection_monitor.dart';
import 'data_sync.dart';
import 'offline_queue.dart';
import 'semester_service.dart';
import 'telemetry_service.dart';
import 'user_scope.dart';

const _maxRetries = 3;
const _scope = 'ScheduleApi';
final _initialRetryDelay = AppMotionSystem.medium; // 300ms

class ClassItem {
  final int id;
  final String? code;
  final String? title;
  final int? units;
  final String? room;
  final String? instructor;
  final String? instructorAvatar;
  final int day; // 1..7
  final String start; // 'HH:MM'
  final String end; // 'HH:MM'
  final bool enabled;
  final bool isCustom;

  ClassItem({
    required this.id,
    required this.day,
    required this.start,
    required this.end,
    this.code,
    this.title,
    this.units,
    this.room,
    this.instructor,
    this.instructorAvatar,
    this.enabled = true,
    this.isCustom = false,
  });

  ClassItem copyWith({
    int? id,
    String? code,
    String? title,
    int? units,
    String? room,
    String? instructor,
    String? instructorAvatar,
    int? day,
    String? start,
    String? end,
    bool? enabled,
    bool? isCustom,
  }) {
    return ClassItem(
      id: id ?? this.id,
      day: day ?? this.day,
      start: start ?? this.start,
      end: end ?? this.end,
      code: code ?? this.code,
      title: title ?? this.title,
      units: units ?? this.units,
      room: room ?? this.room,
      instructor: instructor ?? this.instructor,
      instructorAvatar: instructorAvatar ?? this.instructorAvatar,
      enabled: enabled ?? this.enabled,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  factory ClassItem.fromMap(Map<String, dynamic> m, {bool isCustom = false}) {
    final instructorName = resolveInstructorName(m);
    int readId(Map<String, dynamic> map) {
      final raw = map['id'] ?? map['class_id'];
      if (raw is num) return raw.toInt();
      if (raw is String) return int.tryParse(raw) ?? 0;
      throw StateError('Class item missing id/class_id field: $map');
    }

    String? readAvatar(Map<String, dynamic> map) {
      final raw = map['instructor_avatar'] ?? map['avatar_url'];
      if (raw == null) return null;
      if (raw is String && raw.trim().isNotEmpty) return raw.trim();
      return null;
    }

    return ClassItem(
      id: readId(m),
      code: m['code'] as String?,
      title: m['title'] as String? ?? m['subject'] as String?,
      units: m['units'] == null ? null : (m['units'] as num).toInt(),
      room: m['room'] as String?,
      instructor: instructorName.isEmpty ? null : instructorName,
      instructorAvatar: readAvatar(m),
      day: m['day'] is num ? (m['day'] as num).toInt() : _parseDay(m['day']),
      start: (m['start'] ?? m['start_time']) as String,
      end: (m['end'] ?? m['end_time']) as String,
      enabled: (m['enabled'] is bool)
          ? (m['enabled'] as bool)
          : ((m['enabled'] ?? 1) == 1),
      isCustom: isCustom,
    );
  }

  factory ClassItem.fromJson(Map<String, dynamic> json) {
    return ClassItem.fromMap(
      json,
      isCustom: json['isCustom'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'units': units,
      'room': room,
      'instructor': instructor,
      'instructor_avatar': instructorAvatar,
      'day': day,
      'start': start,
      'end': end,
      'enabled': enabled,
      'isCustom': isCustom,
    };
  }

  static int _parseDay(dynamic day) {
    if (day is num) return day.toInt();
    if (day is String) {
      switch (day.substring(0, 3).toLowerCase()) {
        case 'mon':
          return 1;
        case 'tue':
          return 2;
        case 'wed':
          return 3;
        case 'thu':
          return 4;
        case 'fri':
          return 5;
        case 'sat':
          return 6;
        case 'sun':
          return 7;
      }
    }
    return 0;
  }
}

class ClassDetails {
  ClassDetails({
    required this.id,
    required this.isCustom,
    required this.title,
    required this.day,
    required this.start,
    required this.end,
    required this.enabled,
    this.code,
    this.room,
    this.units,
    this.sectionId,
    this.sectionCode,
    this.sectionName,
    this.sectionNumber,
    this.sectionStatus,
    this.instructorName,
    this.instructorEmail,
    this.instructorTitle,
    this.instructorDepartment,
    this.instructorAvatar,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final bool isCustom;
  final String title;
  final int day;
  final String start;
  final String end;
  final bool enabled;
  final String? code;
  final String? room;
  final int? units;
  final int? sectionId;
  final String? sectionCode;
  final String? sectionName;
  final String? sectionNumber;
  final String? sectionStatus;
  final String? instructorName;
  final String? instructorEmail;
  final String? instructorTitle;
  final String? instructorDepartment;
  final String? instructorAvatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClassDetails copyWith({
    String? title,
    int? day,
    String? start,
    String? end,
    bool? enabled,
    String? code,
    String? room,
    int? units,
    int? sectionId,
    String? sectionCode,
    String? sectionName,
    String? sectionNumber,
    String? sectionStatus,
    String? instructorName,
    String? instructorEmail,
    String? instructorTitle,
    String? instructorDepartment,
    String? instructorAvatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassDetails(
      id: id,
      isCustom: isCustom,
      title: title ?? this.title,
      day: day ?? this.day,
      start: start ?? this.start,
      end: end ?? this.end,
      enabled: enabled ?? this.enabled,
      code: code ?? this.code,
      room: room ?? this.room,
      units: units ?? this.units,
      sectionId: sectionId ?? this.sectionId,
      sectionCode: sectionCode ?? this.sectionCode,
      sectionName: sectionName ?? this.sectionName,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      sectionStatus: sectionStatus ?? this.sectionStatus,
      instructorName: instructorName ?? this.instructorName,
      instructorEmail: instructorEmail ?? this.instructorEmail,
      instructorTitle: instructorTitle ?? this.instructorTitle,
      instructorDepartment: instructorDepartment ?? this.instructorDepartment,
      instructorAvatar: instructorAvatar ?? this.instructorAvatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toSnapshot() {
    final map = <String, dynamic>{
      'id': id,
      'is_custom': isCustom,
      'title': title,
      'day': day,
      'start': start,
      'end': end,
      'enabled': enabled,
      'code': code,
      'room': room,
      'units': units,
      'section_id': sectionId,
      'section_code': sectionCode,
      'section_name': sectionName,
      'section_number': sectionNumber,
      'section_status': sectionStatus,
      'instructor_name': instructorName,
      'instructor_email': instructorEmail,
      'instructor_title': instructorTitle,
      'instructor_department': instructorDepartment,
      'instructor_avatar': instructorAvatar,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
    map.removeWhere((_, value) => value == null);
    return map;
  }

  factory ClassDetails.fromClassRow(
    Map<String, dynamic> row, {
    required ClassItem fallback,
  }) {
    final instructor = _asMap(row['instructors']);
    final section = _asMap(row['sections']);
    final day = _parseDay(row['day']) ?? fallback.day;
    final start = _coerceTime(row['start'], fallback.start);
    final end = _coerceTime(row['end'], fallback.end);
    final room = _coerceString(
          row['room'],
        ) ??
        _coerceString(section?['room']) ??
        fallback.room;
    final instructorName = _coerceString(
          instructor?['full_name'],
        ) ??
        _coerceString(row['instructor']) ??
        fallback.instructor;

    return ClassDetails(
      id: _readId(row['id']) ?? fallback.id,
      isCustom: false,
      title: _coerceString(row['title']) ??
          fallback.title ??
          fallback.code ??
          'Class',
      code: _coerceString(row['code']) ?? fallback.code,
      day: day,
      start: start,
      end: end,
      room: room,
      units: _coerceInt(row['units']) ?? fallback.units,
      enabled: fallback.enabled,
      sectionId: _coerceInt(row['section_id']) ?? _coerceInt(section?['id']),
      sectionCode: _coerceString(section?['code']),
      sectionName: _coerceString(section?['class_name']),
      sectionNumber: _coerceString(section?['section_number']),
      sectionStatus: _coerceString(section?['status']),
      instructorName: instructorName,
      instructorEmail: _coerceString(instructor?['email']),
      instructorTitle: _coerceString(instructor?['title']),
      instructorDepartment: _coerceString(instructor?['department']),
      instructorAvatar:
          _coerceString(instructor?['avatar_url']) ?? fallback.instructorAvatar,
      createdAt: _parseTimestamp(row['created_at']),
      updatedAt: _parseTimestamp(row['updated_at']),
    );
  }

  factory ClassDetails.fromCustomRow(Map<String, dynamic> row) {
    final day = _parseDay(row['day']) ?? 1;
    final start =
        _coerceTime(row['start_time'], _coerceString(row['start']) ?? '08:00');
    final end =
        _coerceTime(row['end_time'], _coerceString(row['end']) ?? '09:00');
    final instructor = _coerceString(row['instructor']);
    final room = _coerceString(row['room']);
    final created = _parseTimestamp(row['created_at']);

    return ClassDetails(
      id: _readId(row['id']) ?? 0,
      isCustom: true,
      title: _coerceString(row['title']) ?? 'Custom class',
      code: null,
      day: day,
      start: start,
      end: end,
      room: room,
      units: null,
      enabled: _coerceBool(row['enabled']) ?? true,
      sectionId: null,
      sectionCode: null,
      sectionName: null,
      sectionNumber: null,
      sectionStatus: null,
      instructorName: instructor,
      instructorEmail: null,
      instructorTitle: null,
      instructorDepartment: null,
      instructorAvatar: null,
      createdAt: created,
      updatedAt: null,
    );
  }

  factory ClassDetails.fromViewRow(
    Map<String, dynamic> row, {
    required ClassItem fallback,
  }) {
    final day = _parseDay(row['day']) ?? fallback.day;
    final start = _coerceTime(row['start'], fallback.start);
    final end = _coerceTime(row['end'], fallback.end);

    return ClassDetails(
      id: fallback.id,
      isCustom: false,
      title: _coerceString(row['title']) ??
          fallback.title ??
          fallback.code ??
          'Class',
      code: _coerceString(row['code']) ?? fallback.code,
      day: day,
      start: start,
      end: end,
      room: _coerceString(row['room']) ?? fallback.room,
      units: _coerceInt(row['units']) ?? fallback.units,
      enabled: fallback.enabled,
      sectionId: _coerceInt(row['section_id']),
      sectionCode: _coerceString(row['section_code']),
      sectionName: _coerceString(row['section_name']),
      sectionNumber: _coerceString(row['section_number']),
      sectionStatus: _coerceString(row['section_status']),
      instructorName: _coerceString(row['instructor']) ?? fallback.instructor,
      instructorEmail: _coerceString(row['instructor_email']),
      instructorTitle: _coerceString(row['instructor_title']),
      instructorDepartment: _coerceString(row['instructor_department']),
      instructorAvatar:
          _coerceString(row['instructor_avatar']) ?? fallback.instructorAvatar,
      createdAt: _parseTimestamp(row['created_at']),
      updatedAt: _parseTimestamp(row['updated_at']),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map<String, dynamic>) {
        return Map<String, dynamic>.from(first);
      }
    }
    return null;
  }

  static int? _parseDay(dynamic day) {
    if (day == null) return null;
    if (day is num) return day.toInt();
    final text = day.toString();
    if (text.isEmpty) return null;
    switch (text.substring(0, 3).toLowerCase()) {
      case 'mon':
        return 1;
      case 'tue':
        return 2;
      case 'wed':
        return 3;
      case 'thu':
        return 4;
      case 'fri':
        return 5;
      case 'sat':
        return 6;
      case 'sun':
        return 7;
    }
    return null;
  }

  static String _coerceTime(dynamic value, String fallback) {
    final text = _coerceString(value);
    if (text == null || text.isEmpty) return fallback;
    return text;
  }

  static String? _coerceString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _coerceInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _coerceBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true' || normalized == 't' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == 'f' || normalized == '0') {
        return false;
      }
    }
    return null;
  }

  static int? _readId(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

class InstructorOption {
  const InstructorOption({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String? avatarUrl;

  factory InstructorOption.fromMap(Map<String, dynamic> map) {
    return InstructorOption(
      id: map['id']?.toString() ?? '',
      name: (map['full_name'] ?? map['name'] ?? '').toString(),
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}

class ScheduleApi {
  static const Duration _cacheTtl = Duration(minutes: 1);
  static final Map<String, _ScheduleCacheEntry> _cache =
      <String, _ScheduleCacheEntry>{};
  static const String _anonCacheKey = '__anon__';

  static String _cacheKeyFor(String? userId) {
    final trimmed = userId?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return _anonCacheKey;
    }
    return trimmed;
  }

  final SupabaseClient? _overrideClient;

  ScheduleApi({SupabaseClient? client})
      : _overrideClient = client {
    _registerQueueHandlers();
  }

  static bool _queueHandlersRegistered = false;

  void _registerQueueHandlers() {
    if (_queueHandlersRegistered) return;
    OfflineQueue.registerHandler(
      'schedule_add_custom',
      (payload) async {
        final api = ScheduleApi();
        await api.addCustomClass(
          day: payload['day'] as int,
          startTime: payload['start_time'] as String,
          endTime: payload['end_time'] as String,
          title: payload['title'] as String,
          room: payload['room'] as String?,
          instructor: payload['instructor'] as String?,
        );
      },
    );
    OfflineQueue.registerHandler(
      'schedule_update_custom',
      (payload) async {
        final api = ScheduleApi();
        await api.updateCustomClass(
          id: payload['id'] as int,
          day: payload['day'] as int,
          startTime: payload['start_time'] as String,
          endTime: payload['end_time'] as String,
          title: payload['title'] as String,
          room: payload['room'] as String?,
          instructor: payload['instructor'] as String?,
        );
      },
    );
    OfflineQueue.registerHandler(
      'schedule_delete_custom',
      (payload) async {
        final api = ScheduleApi();
        await api.deleteCustomClass(payload['id'] as int);
      },
    );
    OfflineQueue.registerHandler(
      'schedule_set_enabled',
      (payload) async {
        final api = ScheduleApi();
        final item = ClassItem(
          id: payload['class_id'] as int,
          day: 1,
          start: '00:00',
          end: '00:01',
        );
        await api.setClassEnabled(item, payload['enabled'] as bool);
      },
    );
    OfflineQueue.registerHandler(
      'schedule_set_custom_enabled',
      (payload) async {
        final api = ScheduleApi();
        await api.setCustomClassEnabled(
          payload['id'] as int,
          payload['enabled'] as bool,
        );
      },
    );
    _queueHandlersRegistered = true;
  }

  SupabaseClient get _s => _overrideClient ?? Supabase.instance.client;

  /// Retry wrapper with exponential backoff for transient failures.
  Future<T> _withRetry<T>(
    Future<T> Function() operation, {
    String? operationName,
    bool Function(Object error)? shouldRetry,
  }) async {
    var attempt = 0;
    var delay = _initialRetryDelay;

    while (true) {
      attempt++;
      try {
        final result = await operation();
        if (attempt > 1 && operationName != null) {
          TelemetryService.instance.recordEvent(
            'schedule_api_retry_success',
            data: {'operation': operationName, 'attempt': attempt},
          );
        }
        return result;
      } catch (e) {
        final canRetry = shouldRetry?.call(e) ?? _isRetryableError(e);
        if (!canRetry || attempt >= _maxRetries) {
          if (attempt > 1 && operationName != null) {
            TelemetryService.instance.recordEvent(
              'schedule_api_retry_failed',
              data: {
                'operation': operationName,
                'attempt': attempt,
                'error': e.toString(),
              },
            );
          }
          rethrow;
        }
        await Future.delayed(delay);
        delay *= 2;
      }
    }
  }

  bool _isRetryableError(Object error) {
    // Don't retry auth or validation errors
    if (error is AuthException) return false;
    if (error is NotAuthenticatedException) return false;
    if (error is ValidationException) return false;

    final msg = error.toString().toLowerCase();
    // Don't retry permission or conflict errors
    if (msg.contains('permission denied') ||
        msg.contains('already exists') ||
        msg.contains('duplicate') ||
        msg.contains('not authenticated')) {
      return false;
    }
    // Retry network/timeout errors
    return msg.contains('timeout') ||
        msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('failed host lookup');
  }

  /// Expose retry logic to tests.
  @visibleForTesting
  Future<T> debugRetry<T>(
    Future<T> Function() operation, {
    String? operationName,
    bool Function(Object error)? shouldRetry,
  }) {
    return _withRetry(
      operation,
      operationName: operationName,
      shouldRetry: shouldRetry,
    );
  }

  /// Expose retryable classification to tests.
  @visibleForTesting
  bool debugIsRetryable(Object error) => _isRetryableError(error);

  Future<int?> getCurrentSectionId() async {
    final uid = UserScope.currentUserId();
    if (uid == null) return null;

    // Get active semester ID - if no active semester, return null
    final activeSemesterId = await SemesterService.instance.getActiveSemesterId();
    if (activeSemesterId == null) {
      AppLog.warn(_scope, 'No active semester - skipping section lookup');
      return null;
    }

    // Step 1: Get user's most recently linked section with its code
    final userSectionRes = await _s
        .from('user_sections')
        .select('section_id, sections(code)')
        .eq('user_id', uid)
        .order('added_at', ascending: false)
        .limit(1);

    final userSectionList = (userSectionRes as List?) ?? const [];
    if (userSectionList.isEmpty) return null;

    final userRow = Map<String, dynamic>.from(userSectionList.first as Map);
    final sectionsData = userRow['sections'];
    String? sectionCode;
    if (sectionsData is Map) {
      sectionCode = sectionsData['code'] as String?;
    } else if (sectionsData is List && sectionsData.isNotEmpty) {
      sectionCode = (sectionsData.first as Map)['code'] as String?;
    }

    if (sectionCode == null || sectionCode.isEmpty) {
      // Fallback: just return the user's linked section_id
      final value = userRow['section_id'];
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Step 2: Find the section with same code in the active semester
    final activeSectionRes = await _s
        .from('sections')
        .select('id')
        .eq('code', sectionCode)
        .eq('semester_id', activeSemesterId)
        .limit(1);

    final activeSectionList = (activeSectionRes as List?) ?? const [];
    if (activeSectionList.isNotEmpty) {
      final activeRow = Map<String, dynamic>.from(activeSectionList.first as Map);
      final activeId = activeRow['id'];
      if (activeId is num) return activeId.toInt();
      if (activeId is String) return int.tryParse(activeId);
    }

    // Fallback: no matching section in active semester, return user's original
    AppLog.info(_scope, 'No section "$sectionCode" found in active semester');
    final fallbackValue = userRow['section_id'];
    if (fallbackValue is num) return fallbackValue.toInt();
    if (fallbackValue is String) return int.tryParse(fallbackValue);
    return null;
  }

  Future<List<ClassItem>> getMyClasses({bool forceRefresh = false}) async {
    final uid = UserScope.currentUserId();
    final cacheKey = _cacheKeyFor(uid);
    final now = DateTime.now();
    final entry = _cache[cacheKey];
    if (!forceRefresh &&
        entry != null &&
        entry.fetchedAt != null &&
        now.difference(entry.fetchedAt!) < _cacheTtl) {
      return List<ClassItem>.from(entry.classes);
    }

    final fresh = await fetchClasses();
    _cache[cacheKey] = _ScheduleCacheEntry(
      List<ClassItem>.from(fresh),
      DateTime.now(),
    );
    return List<ClassItem>.from(fresh);
  }

  Future<List<ClassItem>> refreshMyClasses() =>
      getMyClasses(forceRefresh: true);

  Future<List<InstructorOption>> fetchInstructors({String? search}) async {
    var query = _s.from('instructors').select('id, full_name, avatar_url');
    if (search != null && search.trim().isNotEmpty) {
      query = query.ilike('full_name', '%${search.trim()}%');
    }
    final rows = await query.order('full_name', ascending: true);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(InstructorOption.fromMap)
        .where((option) => option.name.isNotEmpty)
        .toList();
  }

  Future<ClassItem?> fetchRandomClass() async {
    try {
      // Fetch a batch of classes to pick from
      final res = await _s
          .from('classes')
          .select('id, code, title, room, units')
          .limit(50);
      
      final list = (res as List).cast<Map<String, dynamic>>();
      if (list.isEmpty) return null;
      
      final random = list[DateTime.now().microsecond % list.length];
      
      // Map to ClassItem with dummy time/day values since we only need the details
      return ClassItem(
        id: (random['id'] as num).toInt(),
        day: 1,
        start: '00:00',
        end: '00:00',
        code: random['code'] as String?,
        title: random['title'] as String?,
        room: random['room'] as String?,
        units: random['units'] != null ? (random['units'] as num).toInt() : null,
      );
    } catch (e) {
      AppLog.error(_scope, 'Error fetching random class', error: e);
      return null;
    }
  }

  List<ClassItem>? getCachedClasses() {
    final uid = UserScope.currentUserId();
    final cacheKey = _cacheKeyFor(uid);
    final entry = _cache[cacheKey];
    if (entry == null) return null;
    return List<ClassItem>.unmodifiable(entry.classes);
  }

  @protected
  Future<List<ClassItem>> fetchClasses() async {
    final uid = UserScope.currentUserId();
    if (uid == null) throw const AuthException('Not authenticated');

    return _withRetry(
      operationName: 'fetchClasses',
      () async {
        final sectionId = await getCurrentSectionId();
        final baseList = <ClassItem>[];
        if (sectionId != null) {
          final baseRes = await _s
              .from('user_classes_v')
              .select()
              .eq('section_id', sectionId)
              .order('day', ascending: true)
              .order('start', ascending: true);

          baseList.addAll(
            (baseRes as List)
                .cast<Map<String, dynamic>>()
                .map((m) => ClassItem.fromMap(m, isCustom: false)),
          );

          if (baseList.isNotEmpty) {
            final overrideRes = await _s
                .from('user_class_overrides')
                .select('class_id, enabled')
                .eq('user_id', uid);

            final overrides = Map<int, bool>.fromEntries(
              (overrideRes as List).cast<Map<String, dynamic>>().map(
                    (o) => MapEntry(
                      (o['class_id'] as num).toInt(),
                      (o['enabled'] as bool),
                    ),
                  ),
            );

            for (var i = 0; i < baseList.length; i++) {
              final item = baseList[i];
              if (overrides.containsKey(item.id)) {
                baseList[i] = item.copyWith(enabled: overrides[item.id]);
              }
            }
          }
        }

        final custRes = await _s
            .from('user_custom_classes')
            .select()
            .eq('user_id', uid)
            .order('day', ascending: true)
            .order('start_time', ascending: true);

        final customList = (custRes as List)
            .cast<Map<String, dynamic>>()
            .map((m) => ClassItem.fromMap(m, isCustom: true))
            .toList();

        final all = <ClassItem>[...baseList, ...customList];
        all.sort(
          (a, b) => a.day != b.day
              ? a.day.compareTo(b.day)
              : a.start.compareTo(b.start),
        );
        return all;
      },
    );
  }

  Future<ClassDetails> fetchClassDetails(ClassItem item) async {
    final uid = UserScope.currentUserId();
    if (uid == null) throw const AuthException('Not authenticated');

    if (item.isCustom) {
      final res = await _s
          .from('user_custom_classes')
          .select(
            'id, day, start_time, end_time, title, room, instructor, created_at, enabled',
          )
          .eq('id', item.id)
          .eq('user_id', uid)
          .maybeSingle();
      if (res == null) {
        throw Exception('Custom class not found.');
      }
      return ClassDetails.fromCustomRow(
        Map<String, dynamic>.from(res as Map),
      );
    }

    Map<String, dynamic>? classRow;
    try {
      final res = await _s
          .from('classes')
          .select(
            '''
id, code, title, units, room, start, end, day, section_id, instructor_id, created_at, updated_at,
sections (id, code, class_name, section_number, status, room),
instructors (id, full_name, email, avatar_url, title, department)
''',
          )
          .eq('id', item.id)
          .maybeSingle();
      if (res != null) {
        classRow = Map<String, dynamic>.from(res as Map);
      }
    } on PostgrestException {
      // Fall back to view below.
    }

    if (classRow != null) {
      return ClassDetails.fromClassRow(classRow, fallback: item);
    }

    final viewRow = await _s
        .from('user_classes_v')
        .select()
        .eq('class_id', item.id)
        .limit(1)
        .maybeSingle();
    if (viewRow != null) {
      return ClassDetails.fromViewRow(
        Map<String, dynamic>.from(viewRow as Map),
        fallback: item,
      );
    }

    TelemetryService.instance.logEvent(
      'class_details_fallback',
      data: {
        'class_id': item.id,
        'is_custom': item.isCustom,
      },
    );

    return ClassDetails(
      id: item.id,
      isCustom: false,
      title: item.title ?? item.code ?? 'Class',
      day: item.day,
      start: item.start,
      end: item.end,
      enabled: item.enabled,
      code: item.code,
      room: item.room,
      units: item.units,
      sectionId: null,
      sectionCode: null,
      sectionName: null,
      sectionNumber: null,
      sectionStatus: null,
      instructorName: item.instructor,
      instructorEmail: null,
      instructorTitle: null,
      instructorDepartment: null,
      instructorAvatar: item.instructorAvatar,
      createdAt: null,
      updatedAt: null,
    );
  }

  Future<void> setClassEnabled(ClassItem c, bool enable) async {
    if (c.isCustom) return;
    final uid = UserScope.currentUserId();
    if (uid == null) throw const AuthException('Not authenticated');

    await _runOrQueueMutation(
      type: 'schedule_set_enabled',
      payload: {
        'user_id': uid,
        'class_id': c.id,
        'enabled': enable,
      },
      action: () async {
        await _withRetry(
          operationName: 'setClassEnabled',
          () async {
            await _s.from('user_class_overrides').upsert(
              {
                'user_id': uid,
                'class_id': c.id,
                'enabled': enable,
              },
              onConflict: 'user_id,class_id',
            );
          },
        );
      },
      changeType: enable
          ? ScheduleChangeType.classEnabled
          : ScheduleChangeType.classDisabled,
      classId: c.id,
    );
  }

  Future<void> setCustomClassEnabled(int id, bool enable) async {
    final uid = UserScope.currentUserId();
    if (uid == null) throw const AuthException('Not authenticated');

    await _runOrQueueMutation(
      type: 'schedule_set_custom_enabled',
      payload: {
        'id': id,
        'user_id': uid,
        'enabled': enable,
      },
      action: () async {
        await _withRetry(
          operationName: 'setCustomClassEnabled',
          () async {
            await _s
                .from('user_custom_classes')
                .update({'enabled': enable})
                .eq('id', id)
                .eq('user_id', uid);
          },
        );
      },
      changeType: enable
          ? ScheduleChangeType.classEnabled
          : ScheduleChangeType.classDisabled,
      classId: id,
    );
  }

  Future<void> reportClassIssue(
    ClassDetails details, {
    String? note,
  }) async {
    final uid = UserScope.currentUserId();
    if (uid == null) throw const AuthException('Not authenticated');

    final sanitizedNote = note?.trim();
    final payload = <String, dynamic>{
      'user_id': uid,
      'class_id': details.id,
      if (details.sectionId != null) 'section_id': details.sectionId,
      'snapshot': details.toSnapshot(),
      'status': 'new',
      if (sanitizedNote != null && sanitizedNote.isNotEmpty)
        'note': sanitizedNote,
    };

    await _withRetry(
      operationName: 'reportClassIssue',
      () async {
        await _s.from('class_issue_reports').insert(payload);
      },
    );
  }

  Future<void> addCustomClass({
    required int day,
    required String startTime,
    required String endTime,
    required String title,
    String? room,
    String? instructor,
    String? instructorAvatar,
  }) async {
    final uid = UserScope.currentUserId();
    if (uid == null) throw const AuthException('Not authenticated');

    await _runOrQueueMutation(
      type: 'schedule_add_custom',
      payload: {
        'user_id': uid,
        'day': day,
        'start_time': startTime,
        'end_time': endTime,
        'title': title,
        'room': room,
        'instructor': instructor,
        'instructor_avatar': instructorAvatar,
      },
      action: () async {
        await _withRetry(
          operationName: 'addCustomClass',
          () async {
            await _s.from('user_custom_classes').insert({
              'user_id': uid,
              'day': dayIntToDbString(day),
              'start_time': startTime,
              'end_time': endTime,
              'title': title,
              'room': room,
              'instructor': instructor,
              'instructor_avatar': instructorAvatar,
              'enabled': true,
            });
          },
        );
      },
      changeType: ScheduleChangeType.classAdded,
    );
  }

  Future<void> updateCustomClass({
    required int id,
    required int day,
    required String startTime,
    required String endTime,
    required String title,
    String? room,
    String? instructor,
    String? instructorAvatar,
  }) async {
    final uid = UserScope.currentUserId();
    if (uid == null) throw const AuthException('Not authenticated');

    await _runOrQueueMutation(
      type: 'schedule_update_custom',
      payload: {
        'id': id,
        'user_id': uid,
        'day': day,
        'start_time': startTime,
        'end_time': endTime,
        'title': title,
        'room': room,
        'instructor': instructor,
        'instructor_avatar': instructorAvatar,
      },
      action: () async {
        await _withRetry(
          operationName: 'updateCustomClass',
          () async {
            await _s
                .from('user_custom_classes')
                .update({
                  'day': dayIntToDbString(day),
                  'start_time': startTime,
                  'end_time': endTime,
                  'title': title,
                  'room': room,
                  'instructor': instructor,
                'instructor_avatar': instructorAvatar,
                })
                .eq('id', id)
                .eq('user_id', uid);
          },
        );
      },
      changeType: ScheduleChangeType.classUpdated,
      classId: id,
    );
  }

  Future<void> deleteCustomClass(int id) async {
    final uid = UserScope.currentUserId();
    if (uid == null) throw const AuthException('Not authenticated');

    await _runOrQueueMutation(
      type: 'schedule_delete_custom',
      payload: {
        'id': id,
        'user_id': uid,
      },
      action: () async {
        await _withRetry(
          operationName: 'deleteCustomClass',
          () async {
            await _s
                .from('user_custom_classes')
                .delete()
                .eq('id', id)
                .eq('user_id', uid);
          },
        );
      },
      changeType: ScheduleChangeType.classDeleted,
      classId: id,
    );
  }

  Future<void> resetAllForCurrentUser() async {
    final uid = UserScope.currentUserId();
    if (uid == null) throw const AuthException('Not authenticated');

    await _s.from('user_sections').delete().eq('user_id', uid);
    await _s.from('user_custom_classes').delete().eq('user_id', uid);
    await _s.from('user_class_overrides').delete().eq('user_id', uid);
    _invalidateCurrentUserCache();
  }

  @visibleForTesting
  static void clearCache({String? userId}) => invalidateCache(userId: userId);

  static void invalidateCache({String? userId}) {
    if (userId == null) {
      _cache.clear();
      return;
    }
    _cache.remove(_cacheKeyFor(userId));
  }

  @visibleForTesting
  static void primeCache(
    List<ClassItem> items,
    DateTime fetchedAt, {
    String? userId,
  }) {
    final key = _cacheKeyFor(userId);
    _cache[key] = _ScheduleCacheEntry(
      List<ClassItem>.from(items),
      fetchedAt,
    );
  }

  @visibleForTesting
  static void setCacheTimestamp(DateTime? timestamp, {String? userId}) {
    if (timestamp == null) {
      if (userId == null) {
        for (final entry in _cache.values) {
          entry.fetchedAt = null;
        }
        return;
      }
      final entry = _cache[_cacheKeyFor(userId)];
      if (entry != null) {
        entry.fetchedAt = null;
      }
      return;
    }

    if (userId == null) {
      for (final entry in _cache.values) {
        entry.fetchedAt = timestamp;
      }
      return;
    }

    final entry = _cache[_cacheKeyFor(userId)];
    if (entry != null) {
      entry.fetchedAt = timestamp;
    }
  }

  void _invalidateCurrentUserCache({ScheduleChangeType? changeType, int? classId}) {
    final userId = UserScope.currentUserId();
    final key = _cacheKeyFor(userId);
    _cache.remove(key);

    // Broadcast the change
    DataSync.instance.notifyScheduleChanged(
      type: changeType ?? ScheduleChangeType.cacheInvalidated,
      classId: classId,
      userId: userId,
    );
  }

  @visibleForTesting
  static String dayIntToDbString(int day) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (day >= 1 && day <= 7) {
      return dayNames[day - 1];
    }
    return 'Mon';
  }

  Future<void> _runOrQueueMutation({
    required String type,
    required Map<String, dynamic> payload,
    required Future<void> Function() action,
    ScheduleChangeType? changeType,
    int? classId,
  }) async {
    if (ConnectionMonitor.instance.isOnline) {
      await action();
      _invalidateCurrentUserCache(
        changeType: changeType,
        classId: classId,
      );
      return;
    }

    await OfflineQueue.instance.enqueue(
      QueuedMutation.create(type: type, payload: payload),
    );
    _invalidateCurrentUserCache(
      changeType: changeType ?? ScheduleChangeType.cacheInvalidated,
      classId: classId,
    );
  }
}

class _ScheduleCacheEntry {
  _ScheduleCacheEntry(this.classes, this.fetchedAt);

  List<ClassItem> classes;
  DateTime? fetchedAt;
}
