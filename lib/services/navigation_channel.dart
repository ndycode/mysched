import 'package:flutter/services.dart';

import '../models/reminder_scope.dart';
import '../utils/nav.dart';

class NavigationChannel {
  NavigationChannel._();

  static final NavigationChannel instance = NavigationChannel._();
  static const MethodChannel _channel = MethodChannel('mysched/navigation');

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _channel.setMethodCallHandler(_handleCall);
    _initialized = true;
  }

  Future<dynamic> _handleCall(MethodCall call) async {
    switch (call.method) {
      case 'open_reminders':
        final Object? args = call.arguments;
        String? scopeName;
        if (args is Map) {
          final dynamic value = args['scope'];
          if (value is String) scopeName = value;
        }
        var scope = ReminderScope.today;
        if (scopeName != null) {
          scope = ReminderScope.values.firstWhere(
            (element) => element.name == scopeName,
            orElse: () => ReminderScope.today,
          );
        }
        await openReminders(scope: scope);
        return null;
      default:
        throw MissingPluginException(
          'Navigation method ${call.method} not implemented',
        );
    }
  }
}
