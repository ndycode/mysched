import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/screens/schedules/add_class_screen.dart';
import 'package:mysched/services/schedule_repository.dart';
import 'package:mysched/ui/kit/modals.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_helpers/supabase_stub.dart';

class _FakeScheduleApi extends ScheduleApi {
  _FakeScheduleApi() : super(client: Supabase.instance.client);

  @override
  Future<List<InstructorOption>> fetchInstructors({String? search}) async {
    return const [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await SupabaseTestBootstrap.ensureInitialized();
  });

  testWidgets('day picker dialog appears', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final api = _FakeScheduleApi();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  AppModal.sheet(
                    context: context,
                    builder: (_) => AddClassSheet(api: api),
                  );
                },
                child: const Text('Open add class'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Open add class'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byIcon(Icons.arrow_drop_down_rounded).first,
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(find.text('Select day'), findsOneWidget);
  });
}
