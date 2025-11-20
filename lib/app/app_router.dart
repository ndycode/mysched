import 'package:go_router/go_router.dart';

import '../models/reminder_scope.dart';
import '../screens/account_overview_page.dart';
import '../screens/change_email_page.dart';
import '../screens/change_password_page.dart';
import '../screens/delete_account_page.dart';
import '../screens/login_page.dart';
import '../screens/register_page.dart';
import '../screens/verify_email_page.dart';
import '../screens/reminders_page.dart';
import '../ui/theme/motion.dart';
import '../utils/nav.dart';
import 'bootstrap_gate.dart';
import 'root_nav.dart';
import 'routes.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: navKey,
  initialLocation: AppRoutes.splash,
  observers: [
    TelemetryNavigatorObserver(),
    routeObserver,
  ],
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const BootstrapGate(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.verify,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is VerifyEmailPageArgs) {
          return VerifyEmailPage(
            email: extra.email,
            intent: extra.intent,
            fromLogin: extra.fromLogin,
            onVerified: extra.onVerified,
          );
        }
        final email = state.uri.queryParameters['email'] ?? '';
        return VerifyEmailPage(email: email);
      },
    ),
    GoRoute(
      path: AppRoutes.app,
      builder: (context, state) {
        final extra = state.extra;
        int? tab;
        bool fromScan = false;
        ReminderScope? scope;
        if (extra is Map) {
          tab = extra['tab'] as int?;
          fromScan = extra['fromScan'] == true;
          final scopeName = extra['reminderScope'] as String?;
          if (scopeName != null) {
            scope = ReminderScope.values.firstWhere(
              (value) => value.name == scopeName,
              orElse: () => ReminderScope.today,
            );
          }
        }
        return RootNav(
          initialTab: tab,
          fromScan: fromScan,
          reminderScopeOverride: scope,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.reminders,
      builder: (context, state) {
        ReminderScope scope = ReminderScope.today;
        final name = state.uri.queryParameters['scope'];
        if (name != null) {
          scope = ReminderScope.values.firstWhere(
            (value) => value.name == name,
            orElse: () => ReminderScope.today,
          );
        }
        return RemindersPage(initialScope: scope);
      },
    ),
    GoRoute(
      path: AppRoutes.account,
      builder: (context, state) => const AccountOverviewPage(),
    ),
    GoRoute(
      path: AppRoutes.changeEmail,
      builder: (context, state) {
        final extra = state.extra;
        String currentEmail = '';
        if (extra is ChangeEmailPageArgs) {
          currentEmail = extra.currentEmail;
        } else {
          currentEmail = state.uri.queryParameters['currentEmail'] ?? '';
        }
        return ChangeEmailPage(currentEmail: currentEmail);
      },
    ),
    GoRoute(
      path: AppRoutes.changePassword,
      builder: (context, state) => const ChangePasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.deleteAccount,
      builder: (context, state) => const DeleteAccountPage(),
    ),
  ],
);
