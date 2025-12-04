import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/analytics_service.dart';
import 'package:mysched/services/telemetry_service.dart';

void main() {
  group('AnalyticsService', () {
    setUp(() {
      TelemetryService.reset();
    });

    tearDown(() {
      TelemetryService.reset();
    });

    test('instance is constant', () {
      const service1 = AnalyticsService.instance;
      const service2 = AnalyticsService.instance;
      expect(identical(service1, service2), true);
    });

    test('logEvent does not throw when telemetry unavailable', () async {
      // This should not throw even if telemetry is not properly configured
      await expectLater(
        AnalyticsService.instance.logEvent('test_event'),
        completes,
      );
    });

    test('logEvent accepts params', () async {
      await expectLater(
        AnalyticsService.instance.logEvent(
          'test_event_with_params',
          params: {'key': 'value', 'count': 42},
        ),
        completes,
      );
    });

    test('logEvent handles null params', () async {
      await expectLater(
        AnalyticsService.instance.logEvent('test_event', params: null),
        completes,
      );
    });

    test('multiple logEvent calls complete', () async {
      await expectLater(
        Future.wait([
          AnalyticsService.instance.logEvent('event_1'),
          AnalyticsService.instance.logEvent('event_2'),
          AnalyticsService.instance.logEvent('event_3'),
        ]),
        completes,
      );
    });
  });
}
