// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'app/app_router.dart';
import 'app/constants.dart';
import 'env.dart';
import 'services/analytics_service.dart';
import 'services/theme_controller.dart';
import 'services/telemetry_service.dart';
import 'services/navigation_channel.dart';
import 'services/reminder_scope_store.dart';
import 'services/offline_queue.dart';
import 'services/connection_monitor.dart';
import 'services/data_sync.dart';
import 'services/widget_service.dart';
import 'ui/kit/theme_transition_host.dart';
import 'ui/theme/app_theme.dart';
import 'ui/theme/tokens.dart';
import 'utils/app_log.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    final bootstrapStopwatch = Stopwatch()..start();
    final binding = WidgetsFlutterBinding.ensureInitialized();
    _installErrorHandlers();
    _installTelemetryRecorder();
    binding.addPostFrameCallback((_) {
      bootstrapStopwatch.stop();
      AnalyticsService.instance.logEvent(
        'ui_perf_bootstrap_ms',
        params: {'elapsed_ms': bootstrapStopwatch.elapsedMilliseconds},
      );
    });
    final envOk = await _initEnv();
    if (!envOk) {
      runApp(const _ConfigErrorApp());
      return;
    }
    ConnectionMonitor.instance.startMonitoring();
    await OfflineQueue.instance.init();
    await ReminderScopeStore.instance.initialize();
    await NavigationChannel.instance.init();
    await DataSync.instance.init();
    await ThemeController.instance.init();
    // Initialize and update home screen widget
    if (Platform.isAndroid) {
      await WidgetService.initialize();
      await WidgetService.updateWidgets();
    }
    runApp(const MySchedApp());
  }, (error, stack) {
    TelemetryService.instance.logError(
      'zone_unhandled_error',
      error: error,
      stack: stack,
    );
  });
}

void _installTelemetryRecorder() {
  TelemetryService.ensureRecorder(
    (name, data) {
      AppLog.info(
        'Telemetry',
        name,
        data: data ?? const <String, Object?>{},
      );
    },
  );
}

void _installErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    TelemetryService.instance.logError(
      'flutter_error',
      error: details.exception,
      stack: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    TelemetryService.instance.logError(
      'platform_error',
      error: error,
      stack: stack,
    );
    return false;
  };
}

Future<bool> _initEnv() async {
  try {
    await Env.init();
    return true;
  } catch (error, stack) {
    TelemetryService.instance.logError(
      'config_env_init_failed',
      error: error,
      stack: stack,
    );
    return false;
  }
}

class MySchedApp extends StatelessWidget {
  const MySchedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, mode, _) {
        return AnimatedSwitcher(
          duration: AppTokens.motion.slow,
          switchInCurve: AppTokens.motion.ease,
          switchOutCurve: AppTokens.motion.ease,
          child: _ThemedApp(
            key: ValueKey<AppThemeMode>(mode),
            mode: mode,
          ),
        );
      },
    );
  }
}

class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp();

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    return MaterialApp(
      title: AppConstants.appName,
      home: Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: Padding(
            padding: spacing.edgeInsetsSymmetric(horizontal: spacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppConstants.appName,
                  style: AppTokens.typography.headline.copyWith(
                    color: colors.brand,
                  ),
                ),
                SizedBox(height: spacing.xxl),
                Icon(Icons.cloud_off_rounded, size: AppTokens.iconSize.display, color: colors.danger),
                SizedBox(height: spacing.md),
                Text(
                  'Missing Supabase configuration.',
                  textAlign: TextAlign.center,
                  style: AppTokens.typography.subtitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  'Add SUPABASE_URL and SUPABASE_ANON_KEY to .env or pass them with --dart-define, then restart the app.',
                  textAlign: TextAlign.center,
                  style: AppTokens.typography.body,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemedApp extends StatelessWidget {
  const _ThemedApp({required this.mode, super.key});

  final AppThemeMode mode;

  @override
  Widget build(BuildContext context) {
    final themeMode = switch (mode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.voidMode => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };

    final lightTheme = AppTheme.light();
    final darkTheme =
        mode == AppThemeMode.voidMode ? AppTheme.voidTheme() : AppTheme.dark();

    return MaterialApp.router(
      key: key,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      themeAnimationDuration: Duration.zero,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final double scaleSample = media.textScaler.scale(10.0) / 10.0;
        final double clamped = scaleSample.clamp(1.0, 1.6);
        final responsiveChild = ResponsiveBreakpoints.builder(
          breakpoints: const [
            Breakpoint(start: 0, end: 450, name: MOBILE),
            Breakpoint(start: 451, end: 800, name: TABLET),
            Breakpoint(start: 801, end: 1920, name: DESKTOP),
          ],
          child: child ?? const SizedBox.shrink(),
        );
        final content = MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(clamped)),
          child: responsiveChild,
        );
        return ThemeTransitionHost(
          platformBrightness: media.platformBrightness,
          child: GestureDetector(
            onTap: () {
              // Global rule: Dismiss keyboard when tapping outside of inputs
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: content,
          ),
        );
      },
      routerConfig: appRouter,
    );
  }
}
