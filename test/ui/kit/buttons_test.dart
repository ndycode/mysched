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
  group('SecondaryButton', () {
    testWidgets('triggers callback when tapped', (tester) async {
      var tapped = false;
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: SecondaryButton(
          label: 'Cancel',
          onPressed: () => tapped = true,
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders with icon', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: SecondaryButton(
          label: 'Back',
          icon: Icons.arrow_back,
          onPressed: () {},
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('disabled state prevents tap', (tester) async {
      final tapped = false;
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: SecondaryButton(
          label: 'Disabled',
          onPressed: null,
        ),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });

    testWidgets('works in dark theme', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.dark(),
        child: SecondaryButton(
          label: 'Dark',
          onPressed: () {},
        ),
      );

      final context = tester.element(find.byType(SecondaryButton));
      expect(Theme.of(context).brightness, Brightness.dark);
    });
  });

  group('TertiaryButton', () {
    testWidgets('triggers callback when tapped', (tester) async {
      var tapped = false;
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: TertiaryButton(
          label: 'Learn more',
          onPressed: () => tapped = true,
        ),
      );

      await tester.tap(find.text('Learn more'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders with icon', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: TertiaryButton(
          label: 'Resolve',
          icon: Icons.check,
          onPressed: () {},
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('Resolve'), findsOneWidget);
    });
  });

  group('DestructiveButton', () {
    testWidgets('triggers callback when tapped', (tester) async {
      var tapped = false;
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: DestructiveButton(
          label: 'Delete',
          onPressed: () => tapped = true,
        ),
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders in warning style', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: DestructiveButton(
          label: 'Remove',
          onPressed: () {},
        ),
      );

      expect(find.text('Remove'), findsOneWidget);
    });
  });
}
