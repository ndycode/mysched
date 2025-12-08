import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/screens/settings_page.dart';
import 'package:mysched/services/notification_scheduler.dart';
import 'package:mysched/services/user_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers/supabase_stub.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const basePrefs = {
    'notifLeadMinutes': 20,
    'snoozeMinutes': 15,
    'class_alarms': true,
    'app_notifs': true,
    'quiet_week_enabled': false,
    'alarm_verbose_logging': false,
  };

  setUpAll(() async {
    await SupabaseTestBootstrap.ensureInitialized();
    UserScope.overrideForTests(() => 'test-user');
  });

  tearDownAll(() {
    UserScope.overrideForTests(null);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(basePrefs);
  });

  testWidgets('Settings shows saved values', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Heads-up before class'), findsOneWidget);
    expect(find.text('20 minutes before class'), findsOneWidget);
    expect(find.text('Snooze length'), findsOneWidget);
    expect(find.text('15 minutes'), findsOneWidget);
  });

  testWidgets('Changing lead time persists and is restored', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.pumpAndSettle();

    final leadTimeTile = find.text('Heads-up before class');
    await tester.ensureVisible(leadTimeTile);
    await tester.pumpAndSettle();
    await tester.tap(leadTimeTile);
    await tester.pumpAndSettle();

    expect(find.text('Heads-up before class'), findsWidgets);
    // The picker uses ListWheelScrollView - scroll to the desired option
    // Options are: [5, 10, 15, 20, 30, 45, 60], currently at 20 (index 3)
    // Need to scroll to 10 (index 1), which is 2 items up
    final scrollWheel = find.byType(ListWheelScrollView);
    expect(scrollWheel, findsOneWidget);
    // Scroll up to select 10 minutes (each item is 50px tall, scroll 2 items up)
    await tester.drag(scrollWheel, const Offset(0, 100));
    await tester.pumpAndSettle();

    // Tap OK to confirm selection
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('notifLeadMinutes'), 10);

    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.pumpAndSettle();

    expect(find.text('10 minutes before class'), findsOneWidget);
  });

  testWidgets('Shows quiet week banner when enabled', (tester) async {
    SharedPreferences.setMockInitialValues(const {
      'notifLeadMinutes': 20,
      'snoozeMinutes': 15,
      'class_alarms': true,
      'app_notifs': true,
      'quiet_week_enabled': true,
      'alarm_verbose_logging': false,
    });

    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.pumpAndSettle();

    expect(
      find.text(
          'Quiet week is on. Alarm reminders are paused until you turn it off.'),
      findsOneWidget,
    );
  });

  testWidgets('Quiet week toggle updates preference', (tester) async {
    SharedPreferences.setMockInitialValues(const {
      'notifLeadMinutes': 20,
      'snoozeMinutes': 15,
      'class_alarms': false,
      'app_notifs': true,
      'quiet_week_enabled': false,
      'alarm_verbose_logging': false,
    });

    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quiet week'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('quiet_week_enabled'), isTrue);
  });

  testWidgets('Verbose logging toggle updates preference', (tester) async {
    if (!Platform.isAndroid) {
      return;
    }
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.pumpAndSettle();

    final toggleFinder = find.text('Verbose alarm logging (debug)');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('alarm_verbose_logging'), isTrue);
  });

  testWidgets('Shows snackbar when snooze feedback fires', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.pumpAndSettle();

    NotifScheduler.onSnoozed?.call(1, 3);
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Reminder snoozed for 3 minutes.'), findsOneWidget);
  });
}
