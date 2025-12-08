import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../test_helpers/supabase_stub.dart';
import 'package:mysched/screens/schedules/add_class_screen.dart';
import 'package:mysched/services/schedule_repository.dart' as sched;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await SupabaseTestBootstrap.ensureInitialized();
  });

  testWidgets('custom instructor field stays available on lookup failure',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final api = _ThrowingScheduleApi();

    await tester.pumpWidget(
      MaterialApp(
        home: AddClassPage(
          api: api,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Failed to load instructors. Tap to retry.'),
      findsOneWidget,
    );

    final finder = find.widgetWithText(TextFormField, 'Custom instructor name');
    expect(finder, findsOneWidget);

    final textFieldFinder =
        find.descendant(of: finder, matching: find.byType(TextField));
    final textField = tester.widget<TextField>(textFieldFinder);
    expect(textField.keyboardType, TextInputType.name);
    expect(textField.textCapitalization, TextCapitalization.words);
    expect(textField.autocorrect, isFalse);
    expect(textField.enableSuggestions, isFalse);
    expect(textField.autofillHints?.contains(AutofillHints.name), isTrue);
  });

  testWidgets('prevents overlapping custom class save', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final today = DateTime.now().weekday;
    final api = _OverlapGuardApi(today);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AddClassPage(api: api)),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Class title'), 'Physics');

    await tester.tap(find.text('Add class'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(api.addCalled, isFalse);
    expect(find.textContaining('overlaps with'), findsOneWidget);
  });
}

class _ThrowingScheduleApi extends sched.ScheduleApi {
  _ThrowingScheduleApi() : super(client: Supabase.instance.client);

  @override
  Future<List<sched.InstructorOption>> fetchInstructors({String? search}) {
    throw Exception('Failed to reach Supabase');
  }
}

class _OverlapGuardApi extends sched.ScheduleApi {
  _OverlapGuardApi(int day) : _day = day, super(client: Supabase.instance.client);

  final int _day;
  bool addCalled = false;

  @override
  List<sched.ClassItem>? getCachedClasses() {
    return [
      sched.ClassItem(
        id: 99,
        day: _day,
        start: '08:00',
        end: '09:00',
        title: 'Existing',
        code: 'EX-1',
        units: null,
        room: 'R1',
        instructor: 'Prof',
        enabled: true,
        isCustom: true,
      ),
    ];
  }

  @override
  Future<void> addCustomClass({
    required int day,
    required String startTime,
    required String endTime,
    required String title,
    String? room,
    String? instructor,
    String? instructorAvatar,
  }) async {
    addCalled = true;
  }
}
