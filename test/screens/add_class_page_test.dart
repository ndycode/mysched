import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../test_helpers/supabase_stub.dart';
import 'package:mysched/screens/add_class_page.dart';
import 'package:mysched/services/schedule_api.dart' as sched;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await SupabaseTestBootstrap.ensureInitialized();
  });

  testWidgets('custom instructor field stays available on lookup failure',
      (tester) async {
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
}

class _ThrowingScheduleApi extends sched.ScheduleApi {
  _ThrowingScheduleApi() : super(client: Supabase.instance.client);

  @override
  Future<List<sched.InstructorOption>> fetchInstructors({String? search}) {
    throw Exception('Failed to reach Supabase');
  }
}
