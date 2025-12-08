// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../services/reminder_scope_store.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scope = ReminderScopeStore.instance.value;
      context.go(
        AppRoutes.app,
        extra: {'reminderScope': scope.name},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      screenName: 'home_loading',
      hero: const ScreenHeroCard(
        title: 'Loading MySched',
        subtitle: 'Preparing your dashboard...',
      ),
      sections: const [
        ScreenSection(
          decorated: false,
          child: SkeletonDashboardCard(),
        ),
      ],
      padding: EdgeInsets.fromLTRB(
        AppTokens.spacing.xl,
        MediaQuery.of(context).padding.top + AppTokens.spacing.xxxl,
        AppTokens.spacing.xl,
        AppTokens.spacing.xl,
      ),
      safeArea: false,
    );
  }
}
