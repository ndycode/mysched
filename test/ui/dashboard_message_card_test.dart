import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/ui/kit/kit.dart';

void main() {
  testWidgets('MessageCard triggers callbacks', (tester) async {
    var primaryCalled = false;
    var secondaryCalled = false;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MessageCard(
            icon: Icons.info_outline,
            title: 'Test title',
            message: 'Test message',
            primaryLabel: 'Primary',
            secondaryLabel: 'Secondary',
            onPrimary: null,
            onSecondary: null,
          ),
        ),
      ),
    );

    // Rebuild with callbacks
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageCard(
            icon: Icons.info_outline,
            title: 'Test title',
            message: 'Test message',
            primaryLabel: 'Primary',
            secondaryLabel: 'Secondary',
            onPrimary: () => primaryCalled = true,
            onSecondary: () => secondaryCalled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Primary'));
    await tester.tap(find.text('Secondary'));
    expect(primaryCalled, isTrue);
    expect(secondaryCalled, isTrue);
  });
}
