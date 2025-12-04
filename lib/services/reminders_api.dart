import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/app_exceptions.dart';
import '../utils/pagination.dart';
import 'connection_monitor.dart';
import 'data_sync.dart';
import 'offline_queue.dart';
import '../utils/extensions/reminder_entry_ext.dart';

const _noValue = Object();
const _maxRetries = 3;
const _initialDelay = Duration(milliseconds: 300);

enum ReminderStatus { pending, completed }

ReminderStatus reminderStatusFromString(String value) {
  switch (value) {
    case 'completed':
      return ReminderStatus.completed;
    case 'pending':
    default:
      return ReminderStatus.pending;
  }
}

String reminderStatusToString(ReminderStatus status) {
  switch (status) {
    case ReminderStatus.completed:
      return 'completed';
    case ReminderStatus.pending:
      return 'pending';
  }
}

class ReminderEntry {
  ReminderEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.dueAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.details,
    this.snoozeUntil,
    this.completedAt,
  });

  final int id;
  final String userId;
  final String title;
  final String? details;
  final DateTime dueAt;
  final ReminderStatus status;
  final DateTime? snoozeUntil;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCompleted => status == ReminderStatus.completed;
  bool get isOverdue => !isCompleted && dueAt.isBefore(DateTime.now());
  bool get isSnoozed =>
      !isCompleted &&
      snoozeUntil != null &&
      snoozeUntil!.isAfter(DateTime.now());

  ReminderEntry copyWith({
    String? title,
    String? details,
    DateTime? dueAt,
    ReminderStatus? status,
    DateTime? snoozeUntil,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderEntry(
      id: id,
      userId: userId,
      title: title ?? this.title,
      details: details ?? this.details,
      dueAt: dueAt ?? this.dueAt,
      status: status ?? this.status,
      snoozeUntil: snoozeUntil ?? this.snoozeUntil,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static ReminderEntry fromMap(Map<String, dynamic> map) {
    return ReminderEntry(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      details: map['details'] as String?,
      dueAt: DateTime.parse(map['due_at'] as String),
      status: reminderStatusFromString(map['status'] as String),
      snoozeUntil: map['snooze_until'] == null
          ? null
          : DateTime.parse(map['snooze_until'] as String),
      completedAt: map['completed_at'] == null
          ? null
          : DateTime.parse(map['completed_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class RemindersApi {
  RemindersApi({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client {
    _registerQueueHandlers();
  }

  final SupabaseClient _client;
  static const int _titleMaxChars = 160;
  static bool _queueHandlersRegistered = false;

  void _registerQueueHandlers() {
    if (_queueHandlersRegistered) return;
    OfflineQueue.registerHandler(
      'reminder_create',
      (payload) async {
        final api = RemindersApi(client: Supabase.instance.client);
        await api.createReminder(
          title: payload['title'] as String,
          dueAt: DateTime.parse(payload['due_at'] as String),
          details: payload['details'] as String?,
        );
      },
    );
    OfflineQueue.registerHandler(
      'reminder_update',
      (payload) async {
        final api = RemindersApi(client: Supabase.instance.client);
        final id = payload['id'] as int;
        await api.updateReminder(
          id,
          title: payload['title'] as String?,
          details: payload['details'] as String?,
          dueAt: payload['due_at'] == null
              ? null
              : DateTime.parse(payload['due_at'] as String),
          status: payload['status'] == null
              ? null
              : reminderStatusFromString(payload['status'] as String),
          snoozeUntil: payload['snooze_until'] == null
              ? _noValue
              : DateTime.parse(payload['snooze_until'] as String),
          completedAt: payload['completed_at'] == null
              ? _noValue
              : DateTime.parse(payload['completed_at'] as String),
        );
      },
    );
    OfflineQueue.registerHandler(
      'reminder_toggle',
      (payload) async {
        final api = RemindersApi(client: Supabase.instance.client);
        final entry = ReminderEntry.fromMap(payload['entry'] as Map<String, dynamic>);
        final completed = payload['completed'] as bool;
        await api.toggleCompleted(entry, completed);
      },
    );
    OfflineQueue.registerHandler(
      'reminder_snooze',
      (payload) async {
        final api = RemindersApi(client: Supabase.instance.client);
        final id = payload['id'] as int;
        final minutes = payload['minutes'] as int;
        await api.snoozeReminder(id, Duration(minutes: minutes));
      },
    );
    OfflineQueue.registerHandler(
      'reminder_delete',
      (payload) async {
        final api = RemindersApi(client: Supabase.instance.client);
        final id = payload['id'] as int;
        await api.deleteReminder(id);
      },
    );
    _queueHandlersRegistered = true;
  }

  void _assertValidTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Title is required.', field: 'title');
    }
    if (trimmed.length > _titleMaxChars) {
      throw ValidationException(
        'Title too long (max $_titleMaxChars characters).',
        field: 'title',
      );
    }
  }

  String? _currentUserId() => _client.auth.currentUser?.id;

  void _assertAuthenticated() {
    if (_currentUserId() == null) {
      throw const NotAuthenticatedException();
    }
  }

  /// Retry wrapper with exponential backoff for transient failures.
  Future<T> _withRetry<T>(
    Future<T> Function() operation, {
    bool Function(Object error)? shouldRetry,
  }) async {
    var attempt = 0;
    var delay = _initialDelay;

    while (true) {
      attempt++;
      try {
        return await operation();
      } catch (e) {
        final canRetry = shouldRetry?.call(e) ?? _isRetryableError(e);
        if (!canRetry || attempt >= _maxRetries) rethrow;
        await Future.delayed(delay);
        delay *= 2;
      }
    }
  }

  bool _isRetryableError(Object error) {
    final msg = error.toString().toLowerCase();
    // Don't retry auth, validation, or conflict errors
    if (msg.contains('not authenticated') ||
        msg.contains('validation') ||
        msg.contains('already exists') ||
        msg.contains('duplicate')) {
      return false;
    }
    // Retry network/timeout errors
    return msg.contains('timeout') ||
        msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection');
  }

  /// Expose retry logic for tests.
  @visibleForTesting
  Future<T> debugRetry<T>(
    Future<T> Function() operation, {
    bool Function(Object error)? shouldRetry,
  }) {
    return _withRetry(operation, shouldRetry: shouldRetry);
  }

  /// Expose retryable classification for tests.
  @visibleForTesting
  bool debugIsRetryable(Object error) => _isRetryableError(error);

  Future<List<ReminderEntry>> fetchReminders({
    bool includeCompleted = true,
  }) async {
    _assertAuthenticated();
    final userId = _currentUserId()!;

    return _withRetry(() async {
      final builder = _client
          .from('reminders')
          .select()
          .eq('user_id', userId)
          .order('due_at', ascending: true);

      final results = await builder;
      final entries = results
          .map<ReminderEntry>(
            (row) => ReminderEntry.fromMap(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList();

      if (!includeCompleted) {
        return entries.where((entry) => !entry.isCompleted).toList();
      }

      return entries;
    });
  }

  /// Fetch reminders with pagination support.
  /// 
  /// Returns a [Page] of reminders with metadata for infinite scrolling.
  Future<Page<ReminderEntry>> fetchRemindersPaginated({
    PageRequest request = const PageRequest(),
    bool includeCompleted = true,
    ReminderStatus? status,
  }) async {
    _assertAuthenticated();
    final userId = _currentUserId()!;

    return _withRetry(() async {
      // Build the query with all filters first, then sort and paginate
      final sortBy = request.sortBy ?? 'due_at';

      final List<dynamic> results;
      if (status != null) {
        results = await _client
            .from('reminders')
            .select()
            .eq('user_id', userId)
            .eq('status', reminderStatusToString(status))
            .order(sortBy, ascending: request.sortAscending)
            .range(request.offset, request.offset + request.pageSize - 1);
      } else if (!includeCompleted) {
        results = await _client
            .from('reminders')
            .select()
            .eq('user_id', userId)
            .neq('status', 'completed')
            .order(sortBy, ascending: request.sortAscending)
            .range(request.offset, request.offset + request.pageSize - 1);
      } else {
        results = await _client
            .from('reminders')
            .select()
            .eq('user_id', userId)
            .order(sortBy, ascending: request.sortAscending)
            .range(request.offset, request.offset + request.pageSize - 1);
      }

      final entries = results
          .map<ReminderEntry>(
            (row) => ReminderEntry.fromMap(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList();

      // Determine if there are more items
      final hasMore = entries.length == request.pageSize;

      return Page<ReminderEntry>(
        items: entries,
        page: request.page,
        pageSize: request.pageSize,
        totalCount: -1, // Unknown without an extra count query
        hasMore: hasMore,
      );
    });
  }

  /// Get count of reminders by status.
  Future<Map<ReminderStatus, int>> fetchReminderCounts() async {
    _assertAuthenticated();
    final userId = _currentUserId()!;

    return _withRetry(() async {
      final results = await _client
          .from('reminders')
          .select('status')
          .eq('user_id', userId);

      final counts = <ReminderStatus, int>{
        ReminderStatus.pending: 0,
        ReminderStatus.completed: 0,
      };

      for (final row in results) {
        final status = reminderStatusFromString(row['status'] as String);
        counts[status] = (counts[status] ?? 0) + 1;
      }

      return counts;
    });
  }

  Future<ReminderEntry> createReminder({
    required String title,
    required DateTime dueAt,
    String? details,
  }) async {
    _assertValidTitle(title);
    _assertAuthenticated();
    final userId = _currentUserId()!;

    if (!ConnectionMonitor.instance.isOnline) {
      final tempId = DateTime.now().millisecondsSinceEpoch & 0x7fffffff;
      final payload = <String, dynamic>{
        'temp_id': tempId,
        'user_id': userId,
        'title': title,
        'details': (details ?? '').trim().isEmpty ? null : details,
        'due_at': dueAt.toUtc().toIso8601String(),
      };
      await OfflineQueue.instance.enqueue(
        QueuedMutation.create(type: 'reminder_create', payload: payload),
      );
      final now = DateTime.now().toUtc();
      final pending = ReminderEntry(
        id: tempId,
        userId: userId,
        title: title,
        details: details,
        dueAt: dueAt,
        status: ReminderStatus.pending,
        snoozeUntil: null,
        completedAt: null,
        createdAt: now,
        updatedAt: now,
      );
      DataSync.instance.notifyRemindersChanged(
        type: RemindersChangeType.reminderAdded,
        reminderId: pending.id,
        userId: userId,
      );
      return pending;
    }

    final payload = <String, dynamic>{
      'user_id': userId,
      'title': title,
      'details': (details ?? '').trim().isEmpty ? null : details,
      'due_at': dueAt.toUtc().toIso8601String(),
    };

    return _withRetry(() async {
      final data =
          await _client.from('reminders').insert(payload).select().single();
      return ReminderEntry.fromMap(Map<String, dynamic>.from(data));
    });
  }

  Future<ReminderEntry> updateReminder(
    int id, {
    String? title,
    String? details,
    DateTime? dueAt,
    ReminderStatus? status,
    Object? snoozeUntil = _noValue,
    Object? completedAt = _noValue,
  }) async {
    if (title != null) {
      _assertValidTitle(title);
    }
    _assertAuthenticated();
    final userId = _currentUserId()!;

    final payload = <String, dynamic>{};
    if (title != null) payload['title'] = title;
    if (details != null) {
      payload['details'] = details.trim().isEmpty ? null : details;
    }
    if (dueAt != null) payload['due_at'] = dueAt.toUtc().toIso8601String();
    if (status != null) payload['status'] = reminderStatusToString(status);
    if (snoozeUntil != _noValue) {
      final value = snoozeUntil as DateTime?;
      payload['snooze_until'] = value?.toUtc().toIso8601String();
    }
    if (completedAt != _noValue) {
      final value = completedAt as DateTime?;
      payload['completed_at'] = value?.toUtc().toIso8601String();
    }

    if (!ConnectionMonitor.instance.isOnline) {
      final queued = Map<String, dynamic>.from(payload)
        ..addAll({
          'id': id,
          'user_id': userId,
          'status': status == null ? null : reminderStatusToString(status),
          'snooze_until': snoozeUntil is DateTime
              ? snoozeUntil.toUtc().toIso8601String()
              : null,
          'completed_at': completedAt is DateTime
              ? completedAt.toUtc().toIso8601String()
              : null,
        });
      await OfflineQueue.instance.enqueue(
        QueuedMutation.create(type: 'reminder_update', payload: queued),
      );
      DataSync.instance.notifyRemindersChanged(
        type: RemindersChangeType.reminderUpdated,
        reminderId: id,
        userId: userId,
      );
      return ReminderEntry(
        id: id,
        userId: userId,
        title: title ?? 'Reminder',
        details: payload['details'] as String?,
        dueAt: dueAt ?? DateTime.now(),
        status: status ?? ReminderStatus.pending,
        snoozeUntil: snoozeUntil is DateTime ? snoozeUntil : null,
        completedAt: completedAt is DateTime ? completedAt : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return _withRetry(() async {
      if (payload.isEmpty) {
        final data =
            await _client.from('reminders').select().eq('id', id).single();
        return ReminderEntry.fromMap(Map<String, dynamic>.from(data));
      }

      final data = await _client
          .from('reminders')
          .update(payload)
          .eq('id', id)
          .select()
          .single();
      return ReminderEntry.fromMap(Map<String, dynamic>.from(data));
    });
  }

  Future<ReminderEntry> toggleCompleted(
    ReminderEntry entry,
    bool completed,
  ) async {
    if (!ConnectionMonitor.instance.isOnline) {
      await OfflineQueue.instance.enqueue(
        QueuedMutation.create(
          type: 'reminder_toggle',
          payload: {
            'entry': entry.toJson(),
            'completed': completed,
          },
        ),
      );
      final updated = entry.copyWith(
        status: completed ? ReminderStatus.completed : ReminderStatus.pending,
        completedAt: completed ? DateTime.now() : null,
        snoozeUntil: completed ? null : entry.snoozeUntil,
      );
      DataSync.instance.notifyRemindersChanged(
        type: completed
            ? RemindersChangeType.reminderCompleted
            : RemindersChangeType.reminderUpdated,
        reminderId: entry.id,
        userId: entry.userId,
      );
      return updated;
    }

    final now = DateTime.now();
    return updateReminder(
      entry.id,
      status: completed ? ReminderStatus.completed : ReminderStatus.pending,
      completedAt: completed ? now : null,
      snoozeUntil: completed ? null : entry.snoozeUntil,
    );
  }

  Future<ReminderEntry> snoozeReminder(int id, Duration duration) async {
    if (!ConnectionMonitor.instance.isOnline) {
      await OfflineQueue.instance.enqueue(
        QueuedMutation.create(
          type: 'reminder_snooze',
          payload: {
            'id': id,
            'minutes': duration.inMinutes,
          },
        ),
      );
      final now = DateTime.now().add(duration);
      final pending = ReminderEntry(
        id: id,
        userId: _currentUserId() ?? '',
        title: '',
        details: null,
        dueAt: now,
        status: ReminderStatus.pending,
        snoozeUntil: now,
        completedAt: null,
        createdAt: now,
        updatedAt: now,
      );
      DataSync.instance.notifyRemindersChanged(
        type: RemindersChangeType.reminderSnoozed,
        reminderId: id,
        userId: pending.userId,
      );
      return pending;
    }

    _assertAuthenticated();
    final target = DateTime.now().add(duration);
    return updateReminder(
      id,
      dueAt: target,
      status: ReminderStatus.pending,
      snoozeUntil: target,
      completedAt: null,
    );
  }

  Future<void> deleteReminder(int id) async {
    _assertAuthenticated();
    if (!ConnectionMonitor.instance.isOnline) {
      await OfflineQueue.instance.enqueue(
        QueuedMutation.create(
          type: 'reminder_delete',
          payload: {'id': id},
        ),
      );
      DataSync.instance.notifyRemindersChanged(
        type: RemindersChangeType.reminderDeleted,
        reminderId: id,
        userId: _currentUserId(),
      );
      return;
    }

    await _withRetry(() async {
      await _client.from('reminders').delete().eq('id', id);
    });
    DataSync.instance.notifyRemindersChanged(
      type: RemindersChangeType.reminderDeleted,
      reminderId: id,
      userId: _currentUserId(),
    );
  }

  Future<void> resetReminders() async {
    _assertAuthenticated();
    final userId = _currentUserId()!;
    await _withRetry(() async {
      await _client.from('reminders').delete().eq('user_id', userId);
    });
    DataSync.instance.notifyRemindersChanged(
      type: RemindersChangeType.reminderDeleted,
      reminderId: -1,
      userId: userId,
    );
  }
}
