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

enum _TestFilter { all, active, completed }

void main() {
  group('SegmentedPills', () {
    testWidgets('renders all options with correct labels', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: SegmentedPills<_TestFilter>(
          value: _TestFilter.all,
          options: _TestFilter.values,
          onChanged: (_) {},
          labelBuilder: (option) => option.name.toUpperCase(),
        ),
      );

      expect(find.text('ALL'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
    });

    testWidgets('triggers onChanged when tapped', (tester) async {
      _TestFilter? selectedValue;

      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: SegmentedPills<_TestFilter>(
          value: _TestFilter.all,
          options: _TestFilter.values,
          onChanged: (value) => selectedValue = value,
          labelBuilder: (option) => option.name.toUpperCase(),
        ),
      );

      await tester.tap(find.text('ACTIVE'));
      await tester.pumpAndSettle();

      expect(selectedValue, _TestFilter.active);
    });

    testWidgets('works in dark theme', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.dark(),
        child: SegmentedPills<_TestFilter>(
          value: _TestFilter.completed,
          options: _TestFilter.values,
          onChanged: (_) {},
          labelBuilder: (option) => option.name.toUpperCase(),
        ),
      );

      final context = tester.element(find.byType(SegmentedPills<_TestFilter>));
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(find.text('COMPLETED'), findsOneWidget);
    });

    testWidgets('works in void theme', (tester) async {
      await _pumpThemed(
        tester,
        theme: AppTheme.voidTheme(),
        child: SegmentedPills<_TestFilter>(
          value: _TestFilter.all,
          options: _TestFilter.values,
          onChanged: (_) {},
          labelBuilder: (option) => option.name,
        ),
      );

      final context = tester.element(find.byType(SegmentedPills<_TestFilter>));
      expect(Theme.of(context).brightness, Brightness.dark);
    });

    testWidgets('renders with String type options', (tester) async {
      const options = ['Today', 'This week', 'All'];
      String? selected;

      await _pumpThemed(
        tester,
        theme: AppTheme.light(),
        child: SegmentedPills<String>(
          value: 'Today',
          options: options,
          onChanged: (value) => selected = value,
          labelBuilder: (option) => option,
        ),
      );

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(selected, 'All');
    });
  });
}
