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
  group('StatusBadge', () {
    testWidgets('renders live variant with correct label', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: const StatusBadge(
          label: 'LIVE',
          variant: StatusBadgeVariant.live,
        ),
      );

      expect(find.text('LIVE'), findsOneWidget);
    });

    testWidgets('renders next variant', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: const StatusBadge(
          label: 'NEXT',
          variant: StatusBadgeVariant.next,
        ),
      );

      expect(find.text('NEXT'), findsOneWidget);
    });

    testWidgets('renders done variant', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: const StatusBadge(
          label: 'DONE',
          variant: StatusBadgeVariant.done,
        ),
      );

      expect(find.text('DONE'), findsOneWidget);
    });

    testWidgets('renders disabled variant', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: const StatusBadge(
          label: 'DISABLED',
          variant: StatusBadgeVariant.disabled,
        ),
      );

      expect(find.text('DISABLED'), findsOneWidget);
    });

    testWidgets('renders overdue variant', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: const StatusBadge(
          label: 'OVERDUE',
          variant: StatusBadgeVariant.overdue,
        ),
      );

      expect(find.text('OVERDUE'), findsOneWidget);
    });

    testWidgets('renders custom variant', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: const StatusBadge(
          label: 'CUSTOM',
          variant: StatusBadgeVariant.custom,
        ),
      );

      expect(find.text('CUSTOM'), findsOneWidget);
    });

    testWidgets('compact mode renders smaller badge', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: const StatusBadge(
          label: 'LIVE',
          variant: StatusBadgeVariant.live,
          compact: true,
        ),
      );

      expect(find.text('LIVE'), findsOneWidget);
    });

    testWidgets('works in dark theme', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.dark(),
        child: const StatusBadge(
          label: 'NEXT',
          variant: StatusBadgeVariant.next,
        ),
      );

      final context = tester.element(find.byType(StatusBadge));
      expect(Theme.of(context).brightness, Brightness.dark);
    });
  });
}
