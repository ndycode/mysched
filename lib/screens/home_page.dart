// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../services/reminder_scope_store.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return AppScaffold(
      screenName: 'home_loading',
      safeArea: false,
      body: AppBackground(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppTokens.spacing.xl,
            MediaQuery.of(context).padding.top + AppTokens.spacing.xxxl,
            AppTokens.spacing.xl,
            AppTokens.spacing.xl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: const SkeletonDashboardCard(),
            ),
          ),
        ),
      ),
    );
  }
}
