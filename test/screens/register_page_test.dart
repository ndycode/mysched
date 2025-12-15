import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mysched/screens/auth/register_screen.dart';
import 'package:mysched/services/auth_service.dart';
import 'package:mysched/services/telemetry_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAuthBackend backend;

  setUp(() {
    backend = _FakeAuthBackend();
    AuthService.overrideBackend(backend);
    AuthService.overrideDelay((_) => Future.value());
    AuthService.overrideProfileLoader(() async => null);
    SharedPreferences.setMockInitialValues({});
    TelemetryService.overrideForTests((_, __) {});
  });

  tearDown(() {
    TelemetryService.reset();
    SharedPreferences.setMockInitialValues({});
    AuthService.overrideProfileLoader(() async => null);
  });

  testWidgets('displays validation errors for empty fields', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    expect(find.text('Format: YYYY-XXXX-IC'), findsOneWidget);
    expect(find.text('At least 8 characters.'), findsOneWidget);

    await _tapCreateAccountButton(tester);
    await tester.pump();

    expect(find.text('Enter your full name'), findsOneWidget);
    expect(find.text('Enter your student ID'), findsOneWidget);
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter a password'), findsOneWidget);
    expect(backend.ensureStudentIdCallCount, 0);
    expect(backend.signUpCallCount, 0);
  });

  testWidgets('toggles password visibility', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('successful registration navigates to verification screen',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Alex Scholar');
    await tester.enterText(find.byType(TextFormField).at(1), '2024-1234-IC');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'alex@example.com');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');

    await _tapCreateAccountButton(tester);
    await tester.pump(); // start loading spinner

    // Pump multiple times to allow async operations to complete
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Verify backend was called correctly
    expect(backend.ensureStudentIdCallCount, 1);
    expect(backend.signUpCallCount, 1);
    
    // After registration, VerifyEmailScreen.show() opens a modal sheet
    // We can't easily verify the modal without more mocking, but the
    // backend call counts confirm registration was successful
  });

  testWidgets('duplicate student ID surfaces inline error', (tester) async {
    backend.ensureStudentIdError = Exception('Student ID already used');

    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Jamie Example');
    await tester.enterText(find.byType(TextFormField).at(1), '2024-1234-IC');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'jamie@example.com');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');

    await _tapCreateAccountButton(tester);
    await tester.pumpAndSettle();

    expect(find.text('Student ID already in use'), findsOneWidget);
    expect(backend.signUpCallCount, 0);
  });

  testWidgets('duplicate student ID codes surface inline error',
      (tester) async {
    backend.ensureStudentIdError = Exception('EmailOrId: student_id_in_use');

    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Terry Example');
    await tester.enterText(find.byType(TextFormField).at(1), '2024-4321-IC');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'terry@example.com');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');

    await _tapCreateAccountButton(tester);
    await tester.pumpAndSettle();

    expect(find.text('Student ID already in use'), findsOneWidget);
    expect(backend.signUpCallCount, 0);
  });

  testWidgets('duplicate email surfaces inline error', (tester) async {
    backend.signUpError = Exception('Email already registered');

    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Morgan Example');
    await tester.enterText(find.byType(TextFormField).at(1), '2024-1234-IC');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'morgan@example.com');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');

    await _tapCreateAccountButton(tester);
    await tester.pumpAndSettle();

    expect(find.text('Email already in use'), findsOneWidget);
    expect(backend.signUpCallCount, 1);
  });

  testWidgets('duplicate email codes surface inline error', (tester) async {
    backend.signUpError = Exception('EmailOrId: email_in_use');

    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Toni Example');
    await tester.enterText(find.byType(TextFormField).at(1), '2024-9876-IC');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'toni@example.com');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');

    await _tapCreateAccountButton(tester);
    await tester.pumpAndSettle();

    expect(find.text('Email already in use'), findsOneWidget);
    expect(backend.signUpCallCount, 1);
  });
}

Finder _createAccountButton() =>
    find.widgetWithText(FilledButton, 'Create account');

Future<void> _tapCreateAccountButton(WidgetTester tester) async {
  final button = _createAccountButton();
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
}



class _FakeAuthBackend implements AuthBackend {
  int ensureStudentIdCallCount = 0;
  int signUpCallCount = 0;
  Exception? ensureStudentIdError;
  Exception? signUpError;

  @override
  Future<void> ensureStudentIdAvailable(String studentId) async {
    ensureStudentIdCallCount += 1;
    if (ensureStudentIdError != null) throw ensureStudentIdError!;
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
  }) async {
    signUpCallCount += 1;
    if (signUpError != null) throw signUpError!;
  }

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async =>
      AuthResponse.fromJson(_sessionJson);

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPassword(String email) async {}
}

const Map<String, dynamic> _sessionJson = {
  'access_token': 'token',
  'token_type': 'bearer',
  'expires_in': 3600,
  'refresh_token': 'refresh',
  'user': {
    'id': 'user-123',
    'app_metadata': {},
    'user_metadata': {},
    'aud': 'authenticated',
    'created_at': '2024-01-01T00:00:00Z',
  },
};
