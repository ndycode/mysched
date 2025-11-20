import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../services/analytics_service.dart';

/// Fade-through transition tuned to match MySched's navigation rhythm.
class AppFadeThroughPageTransitionsBuilder
    extends FadeThroughPageTransitionsBuilder {
  const AppFadeThroughPageTransitionsBuilder();
}

/// Navigator observer that forwards transition telemetry for UI audits.
class TelemetryNavigatorObserver extends NavigatorObserver {
  TelemetryNavigatorObserver();

  @override
  void didPush(Route route, Route? previousRoute) =>
      _track('push', route, previousRoute);

  @override
  void didPop(Route route, Route? previousRoute) =>
      _track('pop', previousRoute, route);

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) =>
      _track('replace', newRoute, oldRoute);

  void _track(String direction, Route? active, Route? adjacent) {
    final name = _describe(active);
    if (name == null) return;
    final params = {'direction': direction, 'route': name};
    final previous = _describe(adjacent);
    if (previous != null) params['previous_route'] = previous;
    AnalyticsService.instance.logEvent('ui_nav_transition', params: params);
  }

  String? _describe(Route? route) =>
      route?.settings.name ?? route?.runtimeType.toString();
}
