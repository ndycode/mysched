// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../services/reminder_scope_store.dart';
import '../ui/kit/kit.dart';

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
    return const AppScaffold(
      screenName: 'home_loading',
      body: AppBackground(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
