import 'package:go_router/go_router.dart';

import '../models/reminder_scope.dart';
import '../screens/account/account_screen.dart';
import '../screens/account/change_email_screen.dart';
import '../screens/account/change_password_screen.dart';
import '../screens/account/delete_account_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/account/verify_email_screen.dart';
import '../screens/reminders_page.dart';
import '../screens/style_guide_page.dart';
import '../utils/nav.dart';
import '../utils/telemetry_navigator_observer.dart';
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
        if (extra is VerifyEmailScreenArgs) {
          return VerifyEmailScreen(
            email: extra.email,
            intent: extra.intent,
            fromLogin: extra.fromLogin,
            onVerified: extra.onVerified,
          );
        }
        final email = state.uri.queryParameters['email'] ?? '';
        return VerifyEmailScreen(email: email);
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
      pageBuilder: (context, state) => const NoTransitionPage(
        child: AccountOverviewPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.changeEmail,
      builder: (context, state) {
        final extra = state.extra;
        String currentEmail = '';
        if (extra is ChangeEmailScreenArgs) {
          currentEmail = extra.currentEmail;
        } else {
          currentEmail = state.uri.queryParameters['currentEmail'] ?? '';
        }
        return ChangeEmailScreen(currentEmail: currentEmail);
      },
    ),
    GoRoute(
      path: AppRoutes.changePassword,
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.deleteAccount,
      builder: (context, state) => const DeleteAccountScreen(),
    ),
    GoRoute(
      path: AppRoutes.styleGuide,
      builder: (context, state) => const StyleGuidePage(),
    ),
  ],
);
