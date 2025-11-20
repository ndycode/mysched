import 'package:supabase_flutter/supabase_flutter.dart';

const _noValue = Object();

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
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const int _titleMaxChars = 160;

  void _assertValidTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw Exception('Title is required.');
    }
    if (trimmed.length > _titleMaxChars) {
      throw Exception('Title too long (max $_titleMaxChars characters).');
    }
  }

  Future<List<ReminderEntry>> fetchReminders({
    bool includeCompleted = true,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

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
  }

  Future<ReminderEntry> createReminder({
    required String title,
    required DateTime dueAt,
    String? details,
  }) async {
    _assertValidTitle(title);

    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final payload = <String, dynamic>{
      'user_id': userId,
      'title': title,
      'details': (details ?? '').trim().isEmpty ? null : details,
      'due_at': dueAt.toUtc().toIso8601String(),
    };

    final data =
        await _client.from('reminders').insert(payload).select().single();
    return ReminderEntry.fromMap(Map<String, dynamic>.from(data));
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
  }

  Future<ReminderEntry> toggleCompleted(
    ReminderEntry entry,
    bool completed,
  ) async {
    final now = DateTime.now();
    return updateReminder(
      entry.id,
      status: completed ? ReminderStatus.completed : ReminderStatus.pending,
      completedAt: completed ? now : null,
      snoozeUntil: completed ? null : entry.snoozeUntil,
    );
  }

  Future<ReminderEntry> snoozeReminder(int id, Duration duration) async {
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
    await _client.from('reminders').delete().eq('id', id);
  }
}
