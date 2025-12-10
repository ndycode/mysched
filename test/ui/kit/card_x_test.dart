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
  group('CardX', () {
    testWidgets('renders elevated variant', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: const CardX(
          variant: CardVariant.elevated,
          child: Text('Elevated Card'),
        ),
      );

      expect(find.text('Elevated Card'), findsOneWidget);
      expect(find.byType(CardX), findsOneWidget);
    });

    testWidgets('renders outlined variant', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: const CardX(
          variant: CardVariant.outlined,
          child: Text('Outlined Card'),
        ),
      );

      expect(find.text('Outlined Card'), findsOneWidget);
    });

    testWidgets('applies custom padding', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: CardX(
          variant: CardVariant.elevated,
          padding: const EdgeInsets.all(32),
          child: const Text('Padded Card'),
        ),
      );

      expect(find.text('Padded Card'), findsOneWidget);
    });

    testWidgets('works in dark theme', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.dark(),
        child: const CardX(
          variant: CardVariant.elevated,
          child: Text('Dark Card'),
        ),
      );

      final context = tester.element(find.byType(CardX));
      expect(Theme.of(context).brightness, Brightness.dark);
    });

    testWidgets('works in void theme', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.voidTheme(),
        child: const CardX(
          variant: CardVariant.elevated,
          child: Text('Void Card'),
        ),
      );

      final context = tester.element(find.byType(CardX));
      expect(Theme.of(context).brightness, Brightness.dark);
    });

    testWidgets('renders with complex child content', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: CardX(
          variant: CardVariant.elevated,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Title'),
              Text('Subtitle'),
              Icon(Icons.check),
            ],
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
