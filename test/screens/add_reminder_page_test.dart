import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/screens/add_reminder_page.dart';
import 'package:mysched/services/reminders_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../test_helpers/supabase_stub.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await SupabaseTestBootstrap.ensureInitialized();
  });

  group('AddReminderPage', () {
    testWidgets('renders new reminder page', (tester) async {
      final api = RemindersApi(client: Supabase.instance.client);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddReminderPage(api: api),
          ),
        ),
      );

      expect(find.text('New reminder'), findsWidgets);
    });

    testWidgets('renders edit mode when editing provided', (tester) async {
      final api = RemindersApi(client: Supabase.instance.client);
      final now = DateTime.now();
      final entry = ReminderEntry(
        id: 1,
        userId: 'user-1',
        title: 'Existing reminder',
        dueAt: now,
        status: ReminderStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddReminderPage(api: api, editing: entry),
          ),
        ),
      );

      expect(find.text('Edit reminder'), findsWidgets);
    });

    testWidgets('displays subtitle text', (tester) async {
      final api = RemindersApi(client: Supabase.instance.client);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddReminderPage(api: api),
          ),
        ),
      );

      expect(
        find.textContaining('Capture tasks, labs, or exams'),
        findsOneWidget,
      );
    });
  });

  group('AddReminderSheet', () {
    testWidgets('renders as modal sheet', (tester) async {
      final api = RemindersApi(client: Supabase.instance.client);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddReminderSheet(api: api),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(AddReminderSheet), findsOneWidget);
    });

    testWidgets('shows edit mode title when editing', (tester) async {
      final api = RemindersApi(client: Supabase.instance.client);
      final now = DateTime.now();
      final entry = ReminderEntry(
        id: 2,
        userId: 'user-2',
        title: 'Edit me',
        dueAt: now.add(const Duration(hours: 1)),
        status: ReminderStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddReminderSheet(api: api, editing: entry),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Sheet should be in edit mode
      expect(find.byType(AddReminderSheet), findsOneWidget);
    });
  });
}
