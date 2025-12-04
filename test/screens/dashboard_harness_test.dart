// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/auth_service.dart';
import 'package:mysched/services/schedule_api.dart' as sched;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_helpers/supabase_stub.dart';

/// Minimal harness that isolates the schedule error card and retry.
class DashboardHarness extends StatelessWidget {
  const DashboardHarness({
    super.key,
    required this.scheduleLoader,
  });

  final Future<List<sched.ClassItem>> Function() scheduleLoader;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder<List<sched.ClassItem>>(
          future: scheduleLoader(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Column(
                children: [
                  const Text('Schedules not refreshed'),
                  TextButton(
                    key: const ValueKey('harness-retry'),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => DashboardHarness(scheduleLoader: scheduleLoader),
                        ),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              );
            }
            return const Text('OK');
          },
        ),
      ),
    );
  }
}

class _FakeScheduleApi extends sched.ScheduleApi {
  _FakeScheduleApi() : super(client: Supabase.instance.client);
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
        'full_name': 'Harness User',
        'email': 'harness@example.com',
      },
    );
  });

  tearDown(() {
    AuthService.resetTestOverrides();
  });

  testWidgets('harness clears schedule error on retry', (tester) async {
    var fail = true;
    Future<List<sched.ClassItem>> loader() async {
      if (fail) {
        fail = false;
        throw Exception('boom');
      }
      return const <sched.ClassItem>[];
    }

    await tester.pumpWidget(DashboardHarness(scheduleLoader: loader));
    await tester.pumpAndSettle();

    expect(find.text('Schedules not refreshed'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('harness-retry')));
    await tester.pumpAndSettle();
    expect(find.text('Schedules not refreshed'), findsNothing);
    expect(find.text('OK'), findsOneWidget);
  });
}
