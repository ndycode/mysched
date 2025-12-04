import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/screens/settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Initialize singletons/services if needed
    // ThemeController is a singleton, might need mocking or initialization
    // ProfileCache, AdminService etc.
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
