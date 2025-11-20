import 'dart:async';

import 'telemetry_service.dart';

class AnalyticsService {
  const AnalyticsService();

  static const AnalyticsService instance = AnalyticsService();

  Future<void> logEvent(String eventName,
      {Map<String, dynamic>? params}) async {
    try {
      TelemetryService.instance.recordEvent(eventName, data: params);
    } catch (_) {
      // Swallow errors to avoid crashing callers if telemetry is unavailable.
    }
  }
}
