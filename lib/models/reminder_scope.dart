/// Shared scope filter for reminders across dashboard and detail screens.
enum ReminderScope {
  today,
  week,
  all,
}

extension ReminderScopeLabels on ReminderScope {
  String get label {
    switch (this) {
      case ReminderScope.today:
        return 'Today';
      case ReminderScope.week:
        return 'This week';
      case ReminderScope.all:
        return 'All';
    }
  }

  /// Returns true when [due] should be shown for this scope relative to [reference].
  bool includes(DateTime due, DateTime reference) {
    final localDue = DateTime(due.year, due.month, due.day);
    final localRef = DateTime(reference.year, reference.month, reference.day);
    switch (this) {
      case ReminderScope.today:
        return localDue == localRef;
      case ReminderScope.week:
        final startOfWeek =
            localRef.subtract(Duration(days: localRef.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return !localDue.isBefore(startOfWeek) && localDue.isBefore(endOfWeek);
      case ReminderScope.all:
        return true;
    }
  }
}
