import '../../services/reminders_api.dart';

extension ReminderEntryJson on ReminderEntry {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'details': details,
      'due_at': dueAt.toIso8601String(),
      'status': reminderStatusToString(status),
      'snooze_until': snoozeUntil?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
