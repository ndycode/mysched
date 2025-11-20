import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mysched/app/routes.dart';
import 'package:mysched/screens/login_page.dart';
import 'package:mysched/services/auth_service.dart';
import 'package:mysched/services/telemetry_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAuthBackend backend;

  setUp(() {
    backend = _FakeAuthBackend();
    AuthService.overrideBackend(backend);
    AuthService.overrideDelay((_) => Future.value());
    AuthService.overrideProfileLoader(() async => {
          'full_name': 'Test User',
          'student_id': '2020-0001-IC',
        });
    SharedPreferences.setMockInitialValues({});
    TelemetryService.overrideForTests((_, __) {});
  });

  tearDown(() {
    TelemetryService.reset();
    SharedPreferences.setMockInitialValues({});
    AuthService.overrideProfileLoader(() async => null);
  });

  testWidgets('shows validation messages when submitting empty form',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(backend.signInCallCount, 0);
  });

  testWidgets('toggle reveals password icon state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Password field starts obscured.
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('successful login navigates to /home and calls backend',
      (tester) async {
    await tester.pumpWidget(_wrapWithRouter(
      homeBuilder: (_) => const LoginPage(),
      routes: [
        GoRoute(
          path: AppRoutes.app,
          builder: (_, __) =>
              const Scaffold(body: Center(child: Text('Welcome Home'))),
        ),
      ],
    ));

    await tester.enterText(
        find.byType(TextFormField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'correct horse');

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(backend.signInCallCount, greaterThanOrEqualTo(1));
    expect(backend.lastLoginEmail, equals('user@example.com'));
    expect(find.text('Invalid email or password.'), findsNothing);
    expect(find.textContaining('Login failed.'), findsNothing);
  });

  testWidgets('invalid credentials show friendly error', (tester) async {
    backend.loginError = Exception('Login: invalid_credentials');

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.enterText(
        find.byType(TextFormField).at(0), 'wrong@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'badpass');

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump(); // start loading
    await tester.pumpAndSettle();

    expect(find.text('Invalid email or password.'), findsOneWidget);
    expect(backend.signInCallCount, greaterThanOrEqualTo(1));
  });

  testWidgets('confirm email error exposes verification shortcut',
      (tester) async {
    backend.loginError = Exception('Login: confirm_email');

    await tester.pumpWidget(_wrapWithRouter(
      homeBuilder: (_) => const LoginPage(),
      routes: [
        GoRoute(
          path: AppRoutes.verify,
          builder: (_, __) =>
              const Scaffold(body: Center(child: Text('OTP Screen'))),
        ),
      ],
    ));

    await tester.enterText(
        find.byType(TextFormField).at(0), 'pending@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    final verificationShortcut =
        find.widgetWithText(TextButton, 'Enter verification code');
    expect(verificationShortcut, findsOneWidget);

    await tester.ensureVisible(verificationShortcut);
    await tester.pumpAndSettle();
    await tester.tap(verificationShortcut);
    await tester.pumpAndSettle();

    expect(find.text('OTP Screen'), findsOneWidget);
  });
}

Widget _wrapWithRouter({
  required WidgetBuilder homeBuilder,
  List<GoRoute> routes = const [],
}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => homeBuilder(context),
      ),
      ...routes,
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

class _FakeAuthBackend implements AuthBackend {
  int signInCallCount = 0;
  String? lastLoginEmail;
  Exception? loginError;

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    signInCallCount += 1;
    lastLoginEmail = email;
    if (loginError != null) throw loginError!;
    return AuthResponse.fromJson(_sessionJson);
  }

  @override
  Future<void> ensureStudentIdAvailable(String studentId) async =>
      Future.value();

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
  }) async =>
      Future.value();

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
