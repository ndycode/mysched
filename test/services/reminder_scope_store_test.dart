import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mysched/models/reminder_scope.dart';
import 'package:mysched/services/reminder_scope_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    ReminderScopeStore.instance.resetForTest();
  });

  test('initialize loads persisted scope', () async {
    SharedPreferences.setMockInitialValues(const {
      'reminder_scope.selected': 'week',
    });
    ReminderScopeStore.instance.resetForTest();

    await ReminderScopeStore.instance.initialize();

    expect(ReminderScopeStore.instance.value, ReminderScope.week);
  });

  test('update persists scope', () async {
    await ReminderScopeStore.instance.initialize();
    ReminderScopeStore.instance.update(ReminderScope.all);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('reminder_scope.selected'), 'all');
  });
}
