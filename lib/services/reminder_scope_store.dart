import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reminder_scope.dart';

/// Shared controller that keeps the selected reminder scope in sync across
/// dashboard cards, the reminders tab, and any future widgets.
class ReminderScopeStore extends ValueNotifier<ReminderScope> {
  ReminderScopeStore._() : super(ReminderScope.today);

  static final ReminderScopeStore instance = ReminderScopeStore._();
  static const _prefKey = 'reminder_scope.selected';

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKey);
    if (stored != null) {
      final scope = ReminderScope.values.firstWhere(
        (value) => value.name == stored,
        orElse: () => ReminderScope.today,
      );
      if (scope != value) {
        value = scope;
      }
    }
    _initialized = true;
  }

  void update(ReminderScope scope) {
    if (value == scope) return;
    value = scope;
    unawaited(_persist(scope));
  }

  Future<void> _persist(ReminderScope scope) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, scope.name);
  }

  @visibleForTesting
  void resetForTest() {
    _initialized = false;
    value = ReminderScope.today;
  }
}
