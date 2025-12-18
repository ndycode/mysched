import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mysched/ui/kit/kit.dart';
import 'package:mysched/ui/theme/app_theme.dart';

Future<void> _pumpThemed(
  WidgetTester tester, {
  required ThemeData theme,
  required Widget child,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('PrimaryButton', () {
    testWidgets('triggers callback in light mode', (tester) async {
      var tapped = false;
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: PrimaryButton(
          label: 'Proceed',
          onPressed: () => tapped = true,
        ),
      );

      await tester.tap(find.text('Proceed'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('inherits light theme context', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: PrimaryButton(
          label: 'Continue',
          onPressed: () {},
        ),
      );

      final context = tester.element(find.byType(PrimaryButton));
      expect(Theme.of(context).brightness, Brightness.light);
    });
  });

  group('StateDisplay.empty', () {
    testWidgets('renders message and icon in light mode', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: StateDisplay.empty(
          title: 'No schedules yet',
          message: 'Add your first class to get started.',
        ),
      );

      expect(find.text('No schedules yet'), findsOneWidget);
      expect(find.text('Add your first class to get started.'), findsOneWidget);
    });

    testWidgets('respects light theme typography', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: StateDisplay.empty(
          title: 'Nothing here',
          message: 'Try syncing again later.',
        ),
      );

      final context = tester.element(find.byType(StateDisplay));
      expect(Theme.of(context).brightness, Brightness.light);
    });
  });

  group('StateDisplay.error', () {
    testWidgets('invokes retry callback', (tester) async {
      var retried = false;
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: StateDisplay.error(
          title: 'Oops',
          message: 'Something went wrong.',
          retryLabel: 'Try again',
          onRetry: () => retried = true,
        ),
      );

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(retried, isTrue);
    });

    testWidgets('renders in light theme', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: StateDisplay.error(
          title: 'Network error',
          message: 'Please reconnect.',
          retryLabel: 'Retry',
          onRetry: () {},
        ),
      );

      final context = tester.element(find.byType(StateDisplay));
      expect(Theme.of(context).brightness, Brightness.light);
    });
  });
}
