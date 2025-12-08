import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mysched/screens/dashboard/dashboard_screen.dart';
import 'package:mysched/screens/reminders_page.dart';
import 'package:mysched/screens/schedules_page.dart';
import 'package:mysched/screens/settings_page.dart';
import 'package:mysched/services/offline_cache_service.dart';
import 'package:mysched/services/schedule_repository.dart' as sched;
import 'package:mysched/services/reminders_repository.dart';
import 'package:mysched/ui/theme/app_theme.dart';

import '../test_helpers/supabase_stub.dart';

class _FakeScheduleApi extends sched.ScheduleApi {
  _FakeScheduleApi() : super(client: Supabase.instance.client);

  final List<sched.ClassItem> _items = <sched.ClassItem>[];

  @override
  List<sched.ClassItem>? getCachedClasses() => List.unmodifiable(_items);

  @override
  Future<List<sched.ClassItem>> refreshMyClasses() async =>
      List.unmodifiable(_items);

  @override
  Future<void> resetAllForCurrentUser() async {}

  @override
  Future<void> deleteCustomClass(int id) async {}

  @override
  Future<void> setClassEnabled(sched.ClassItem c, bool enable) async {}
}

class _FakeRemindersApi extends RemindersApi {
  _FakeRemindersApi() : super(client: Supabase.instance.client);

  final List<ReminderEntry> _items = <ReminderEntry>[
    ReminderEntry(
      id: 1,
      userId: 'test-user',
      title: 'Mock reminder',
      details: 'Review notes',
      dueAt: DateTime.now().add(const Duration(hours: 2)),
      status: ReminderStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<ReminderEntry>> fetchReminders(
      {bool includeCompleted = true}) async {
    if (includeCompleted) return List.unmodifiable(_items);
    return List.unmodifiable(_items.where((entry) => !entry.isCompleted));
  }

  @override
  Future<ReminderEntry> toggleCompleted(
      ReminderEntry entry, bool completed) async {
    final updated = entry.copyWith(
      status: completed ? ReminderStatus.completed : ReminderStatus.pending,
      completedAt: completed ? DateTime.now() : null,
    );
    _replace(updated);
    return updated;
  }

  @override
  Future<void> deleteReminder(int id) async {
    _items.removeWhere((entry) => entry.id == id);
  }

  @override
  Future<ReminderEntry> snoozeReminder(int id, Duration duration) async {
    final entry = _items.firstWhere((item) => item.id == id);
    final target = DateTime.now().add(duration);
    final updated = entry.copyWith(
      dueAt: target,
      snoozeUntil: target,
      status: ReminderStatus.pending,
    );
    _replace(updated);
    return updated;
  }

  void _replace(ReminderEntry entry) {
    final index = _items.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      _items.add(entry);
    } else {
      _items[index] = entry;
    }
  }
}

Future<void> _pumpThemed(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
        child: child,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await SupabaseTestBootstrap.ensureInitialized();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    OfflineCacheService.resetForTests();
  });

  testWidgets('Dashboard renders without crashing', (tester) async {
    await _pumpThemed(
      tester,
      DashboardScreen(api: _FakeScheduleApi()),
    );
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('SchedulesPage renders without crashing', (tester) async {
    await _pumpThemed(
      tester,
      SchedulesPage(api: _FakeScheduleApi()),
    );
    expect(find.byType(SchedulesPage), findsOneWidget);
  });

  testWidgets('RemindersPage renders without crashing', (tester) async {
    await _pumpThemed(
      tester,
      RemindersPage(api: _FakeRemindersApi()),
    );
    expect(find.byType(RemindersPage), findsOneWidget);
  });

  testWidgets('SettingsPage renders without crashing', (tester) async {
    await _pumpThemed(
      tester,
      const SettingsPage(),
    );
    expect(find.byType(SettingsPage), findsOneWidget);
  });
}
