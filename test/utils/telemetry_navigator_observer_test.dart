import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/telemetry_service.dart';
import 'package:mysched/utils/telemetry_navigator_observer.dart';

void main() {
  setUp(() {
    TelemetryService.reset();
  });

  tearDown(() {
    TelemetryService.reset();
  });

  group('TelemetryNavigatorObserver', () {
    test('creates without error', () {
      expect(() => TelemetryNavigatorObserver(), returnsNormally);
    });

    testWidgets('didPush records telemetry event', (tester) async {
      final events = <String>[];
      TelemetryService.overrideForTests((name, data) => events.add(name));

      final observer = TelemetryNavigatorObserver();
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [observer],
          home: const Scaffold(body: Text('Home')),
          routes: {
            '/test': (context) => const Scaffold(body: Text('Test')),
          },
        ),
      );

      navigatorKey.currentState!.pushNamed('/test');
      await tester.pumpAndSettle();

      expect(events.contains('navigation_route_pushed'), isTrue);
    });

    testWidgets('didPop records telemetry event', (tester) async {
      final events = <String>[];
      TelemetryService.overrideForTests((name, data) => events.add(name));

      final observer = TelemetryNavigatorObserver();
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [observer],
          home: const Scaffold(body: Text('Home')),
          routes: {
            '/test': (context) => const Scaffold(body: Text('Test')),
          },
        ),
      );

      navigatorKey.currentState!.pushNamed('/test');
      await tester.pumpAndSettle();
      events.clear();

      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(events.contains('navigation_route_popped'), isTrue);
    });

    testWidgets('didReplace records telemetry event', (tester) async {
      final events = <String>[];
      TelemetryService.overrideForTests((name, data) => events.add(name));

      final observer = TelemetryNavigatorObserver();
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [observer],
          home: const Scaffold(body: Text('Home')),
          routes: {
            '/test': (context) => const Scaffold(body: Text('Test')),
            '/replacement': (context) => const Scaffold(body: Text('Replacement')),
          },
        ),
      );

      navigatorKey.currentState!.pushNamed('/test');
      await tester.pumpAndSettle();
      events.clear();

      navigatorKey.currentState!.pushReplacementNamed('/replacement');
      await tester.pumpAndSettle();

      expect(events.contains('navigation_route_replaced'), isTrue);
    });
  });
}
