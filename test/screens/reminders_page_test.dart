import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/screens/reminders_page.dart';
import 'package:mysched/services/auth_service.dart';
import 'package:mysched/services/offline_cache_service.dart';
import 'package:mysched/services/profile_cache.dart';
import 'package:mysched/services/reminders_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_helpers/supabase_stub.dart';

ReminderEntry buildReminder({
  required int id,
  String title = 'Reminder',
  String? details,
  ReminderStatus status = ReminderStatus.pending,
  DateTime? dueAt,
  DateTime? snoozeUntil,
}) {
  final due = dueAt ?? DateTime.now().add(const Duration(hours: 1));
  return ReminderEntry(
    id: id,
    userId: 'test-user',
    title: title,
    details: details,
    dueAt: due,
    status: status,
    snoozeUntil: snoozeUntil,
    completedAt: status == ReminderStatus.completed ? due : null,
    createdAt: due.subtract(const Duration(days: 1)),
    updatedAt: due.subtract(const Duration(hours: 1)),
  );
}

class FakeRemindersApi extends RemindersApi {
  FakeRemindersApi({
    List<ReminderEntry>? seed,
    this.fetcher,
    this.onToggle,
  })  : _items = seed ?? <ReminderEntry>[],
        super(client: Supabase.instance.client);

  final List<ReminderEntry> _items;
  final Future<List<ReminderEntry>> Function(bool includeCompleted)? fetcher;
  final Future<ReminderEntry> Function(ReminderEntry entry, bool completed)?
      onToggle;

  @override
  Future<List<ReminderEntry>> fetchReminders({bool includeCompleted = true}) {
    if (fetcher != null) return fetcher!(includeCompleted);
    final list = List<ReminderEntry>.from(_items);
    if (includeCompleted) return Future.value(list);
    return Future.value(list.where((entry) => !entry.isCompleted).toList());
  }

  @override
  Future<ReminderEntry> toggleCompleted(
    ReminderEntry entry,
    bool completed,
  ) async {
    if (onToggle != null) return onToggle!(entry, completed);
    final idx = _items.indexWhere((item) => item.id == entry.id);
    final updated = entry.copyWith(
      status: completed ? ReminderStatus.completed : ReminderStatus.pending,
      completedAt: completed ? DateTime.now() : null,
    );
    if (idx == -1) {
      _items.add(updated);
    } else {
      _items[idx] = updated;
    }
    return updated;
  }

  @override
  Future<void> deleteReminder(int id) async {
    _items.removeWhere((entry) => entry.id == id);
  }

  @override
  Future<ReminderEntry> snoozeReminder(int id, Duration duration) async {
    final idx = _items.indexWhere((entry) => entry.id == id);
    if (idx == -1) throw Exception('missing reminder');
    final entry = _items[idx];
    final target = DateTime.now().add(duration);
    final updated = entry.copyWith(
      dueAt: target,
      snoozeUntil: target,
      status: ReminderStatus.pending,
    );
    _items[idx] = updated;
    return updated;
  }
}

Future<void> _pumpReminders(
  WidgetTester tester,
  RemindersApi api,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: RemindersPage(api: api),
    ),
  );
}

void main() {
  setUpAll(() async {
    await SupabaseTestBootstrap.ensureInitialized();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    OfflineCacheService.resetForTests();
    ProfileCache.clear();
    AuthService.overrideProfileLoader(
      () async => {
        'full_name': 'Remy Reminder',
        'email': 'remy@example.com',
      },
    );
  });

  tearDown(() {
    AuthService.resetTestOverrides();
  });

  testWidgets('shows error card when reminders fail to load', (tester) async {
    final api = FakeRemindersApi(
      fetcher: (_) => Future<List<ReminderEntry>>.error('boom'),
    );

    await _pumpReminders(tester, api);
    await tester.pumpAndSettle();

    expect(find.text('Reminders not refreshed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('toggle button switches completed visibility label',
      (tester) async {
    final today = DateTime.now();
    final active = buildReminder(
      id: 1,
      title: 'Study session',
      dueAt: DateTime(today.year, today.month, today.day, 9),
    );
    final api = FakeRemindersApi(seed: [active]);

    await _pumpReminders(tester, api);
    await tester.pumpAndSettle();

    final showCompletedButton =
        find.widgetWithText(OutlinedButton, 'Show completed');
    expect(showCompletedButton, findsOneWidget);
    await tester.tap(showCompletedButton);
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(OutlinedButton, 'Hide completed'),
      findsOneWidget,
    );
  });

  // Additional behavioural coverage can be extended here as more
  // reminder-specific utilities are extracted for easier testing.
}
