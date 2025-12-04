import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mysched/screens/verify_email_page.dart';
import 'package:mysched/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(AuthService.resetTestOverrides);

  Widget wrapWithApp(Widget child) {
    return MaterialApp(
      routes: {
        '/home': (_) => const Scaffold(body: Text('home')),
        '/login': (_) => const Scaffold(body: Text('login')),
      },
      home: child,
    );
  }


  test('overrideVerifyOtp intercepts auth service call', () async {
    String? capturedEmail;
    AuthService.overrideVerifyOtp(({required email, required token}) async {
      capturedEmail = email;
    });

    await AuthService.instance.verifySignupCode(
      email: 'check@example.com',
      token: '000000',
    );

    expect(capturedEmail, equals('check@example.com'));
  });

  testWidgets('submits when valid code is entered', (tester) async {
    String? capturedEmail;
    String? capturedToken;
    AuthService.overrideVerifyOtp(({required email, required token}) async {
      capturedEmail = email;
      capturedToken = token;
    });

    await tester.pumpWidget(
      wrapWithApp(const VerifyEmailPage(email: 'student@example.com')),
    );

    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(capturedEmail, equals('student@example.com'));
    expect(capturedToken, equals('123456'));
  });

  testWidgets('shows validation message when submitting empty form',
      (tester) async {
    await tester.pumpWidget(
      wrapWithApp(const VerifyEmailPage(email: 'validate@example.com')),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Verify email'));
    await tester.pump();

    expect(find.text('Enter the 6-digit code'), findsOneWidget);
  });

  testWidgets('resend button triggers cooldown and handler', (tester) async {
    var resendCalled = false;
    AuthService.overrideResendOtp(({required email}) async {
      resendCalled = true;
    });

    await tester.pumpWidget(
      wrapWithApp(const VerifyEmailPage(email: 'resend@example.com')),
    );

    final resendButton =
        find.widgetWithText(FilledButton, 'Send another code');
    await tester.ensureVisible(resendButton);
    await tester.pumpAndSettle();
    await tester.tap(resendButton);
    await tester.pump();

    expect(resendCalled, isTrue);
    expect(find.textContaining('Resend code in'), findsOneWidget);
  });

  testWidgets('email change intent verifies via change OTP', (tester) async {
    String? capturedEmail;
    AuthService.overrideVerifyEmailChangeOtp((
        {required email, required token}) async {
      capturedEmail = email;
    });

    await tester.pumpWidget(
      wrapWithApp(const VerifyEmailPage(
        email: 'change@example.com',
        intent: VerificationIntent.emailChange,
      )),
    );

    await tester.enterText(find.byType(TextFormField), '654321');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(capturedEmail, equals('change@example.com'));
  });

  testWidgets('email change resend uses dedicated handler', (tester) async {
    var resendCalled = false;
    AuthService.overrideResendEmailChangeOtp(({required email}) async {
      resendCalled = true;
    });

    await tester.pumpWidget(
      wrapWithApp(const VerifyEmailPage(
        email: 'change@example.com',
        intent: VerificationIntent.emailChange,
      )),
    );

    final resendButton =
        find.widgetWithText(FilledButton, 'Send another code');
    await tester.ensureVisible(resendButton);
    await tester.pumpAndSettle();
    await tester.tap(resendButton);
    await tester.pump();

    expect(resendCalled, isTrue);
  });
}
