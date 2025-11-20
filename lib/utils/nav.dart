import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../models/reminder_scope.dart';
import '../services/reminder_scope_store.dart';
import '../services/root_nav_controller.dart';
import '../ui/kit/root_nav_config.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

String _remindersLocation(ReminderScope? scope) {
  if (scope == null) return AppRoutes.reminders;
  return '${AppRoutes.reminders}?scope=${scope.name}';
}

void goToReminders(BuildContext context, {ReminderScope? scope}) {
  context.go(_remindersLocation(scope));
}

void goToRemindersFromNavKey({ReminderScope? scope}) {
  final context = navKey.currentContext;
  if (context == null) return;
  goToReminders(context, scope: scope);
}

Future<void> openReminders({ReminderScope? scope}) async {
  final target = scope ?? ReminderScopeStore.instance.value;
  ReminderScopeStore.instance.update(target);
  if (RootNavController.handle != null) {
    await RootNavController.goToTab(RootNavTabs.reminders);
    return;
  }
  goToRemindersFromNavKey(scope: target);
}
