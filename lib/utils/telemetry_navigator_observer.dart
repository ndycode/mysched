import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/telemetry_service.dart';

/// Navigator observer that tracks route changes for telemetry.
class TelemetryNavigatorObserver extends NavigatorObserver {
  TelemetryNavigatorObserver();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRouteChange('route_pushed', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logRouteChange('route_popped', route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _logRouteChange('route_removed', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _logRouteChange('route_replaced', newRoute, oldRoute);
    }
  }

  void _logRouteChange(
    String event,
    Route<dynamic>? currentRoute,
    Route<dynamic>? previousRoute,
  ) {
    final routeName = currentRoute?.settings.name;
    final previousRouteName = previousRoute?.settings.name;

    TelemetryService.instance.recordEvent(
      'navigation_$event',
      data: {
        if (routeName != null) 'route': routeName,
        if (previousRouteName != null) 'previous_route': previousRouteName,
        if (currentRoute is GoRoute) 'is_go_route': true,
      },
    );
  }
}


