import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/screens/settings/settings_screen.dart';
import 'package:mysched/services/user_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers/supabase_stub.dart';

void main() {
  setUpAll(() async {
    await SupabaseTestBootstrap.ensureInitialized();
    UserScope.overrideForTests(() => 'test-user');
  });

  tearDownAll(() {
    UserScope.overrideForTests(null);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsPage renders without crashing', (WidgetTester tester) async {
    // Wrap in MaterialApp and Scaffold
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsPage(),
      ),
    );

    // Allow animations to settle
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
  });
}
