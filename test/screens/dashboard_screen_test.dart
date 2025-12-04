// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/screens/dashboard/dashboard_screen.dart';
import 'package:mysched/services/auth_service.dart';
import 'package:mysched/services/reminders_api.dart';
import 'package:mysched/services/schedule_api.dart' as sched;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_helpers/supabase_stub.dart';

class _FakeScheduleApi extends sched.ScheduleApi {
  _FakeScheduleApi() : super(client: Supabase.instance.client);

  int refreshCalls = 0;

  @override
  List<sched.ClassItem>? getCachedClasses() => const <sched.ClassItem>[];

  @override
  Future<List<sched.ClassItem>> refreshMyClasses() async {
    refreshCalls++;
    return const <sched.ClassItem>[];
  }
}

class _FakeRemindersApi extends RemindersApi {
  _FakeRemindersApi() : super(client: Supabase.instance.client);

  int calls = 0;
  bool succeedAfterFirst = true;

  @override
  Future<List<ReminderEntry>> fetchReminders({bool includeCompleted = true}) async {
    calls++;
    if (calls == 1 && succeedAfterFirst) {
      throw Exception('fail');
    }
    final now = DateTime.now().add(const Duration(hours: 1));
    return <ReminderEntry>[
      ReminderEntry(
        id: 1,
        userId: 'u1',
        title: 'Test reminder',
        details: null,
        dueAt: now,
        status: ReminderStatus.pending,
        snoozeUntil: null,
        completedAt: null,
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
      ),
    ];
  }
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required sched.ScheduleApi scheduleApi,
  required RemindersApi remindersApi,
  Future<List<ClassItem>> Function()? scheduleLoader,
  Future<List<ReminderEntry>> Function()? remindersLoader,
  bool scheduleErrorOverride = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: DashboardScreen(
        api: scheduleApi,
        remindersApi: remindersApi,
        scheduleLoaderOverride: scheduleLoader,
        remindersLoaderOverride: remindersLoader,
        debugForceScheduleError: scheduleErrorOverride,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await SupabaseTestBootstrap.ensureInitialized();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthService.overrideProfileLoader(
      () async => {
        'full_name': 'Dash Tester',
        'email': 'dash@example.com',
      },
    );
  });

  tearDown(() {
    AuthService.resetTestOverrides();
  });

  testWidgets('shows reminders error and retries on tap', (tester) async {
    final scheduleApi = _FakeScheduleApi();
    final remindersApi = _FakeRemindersApi();

    await _pumpDashboard(tester, scheduleApi: scheduleApi, remindersApi: remindersApi);
    await tester.pumpAndSettle();

    expect(remindersApi.calls, 1);
    expect(find.text('Reminders not refreshed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(remindersApi.calls, greaterThanOrEqualTo(2));
    expect(find.text('Reminders not refreshed'), findsNothing);
  });

  testWidgets('shows schedule error and retries via loader override', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1200, 2400);
    binding.window.devicePixelRatioTestValue = 1.0;

    final scheduleApi = _FakeScheduleApi();

    await _pumpDashboard(
      tester,
      scheduleApi: scheduleApi,
      remindersApi: _FakeRemindersApi(),
      scheduleLoader: () async {
        throw Exception('boom');
      },
    );
    await tester.pumpAndSettle();

    expect(find.text('Schedules not refreshed'), findsOneWidget);

    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });
}
