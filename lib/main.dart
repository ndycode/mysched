// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'app/app_router.dart';
import 'env.dart';
import 'services/analytics_service.dart';
import 'services/theme_controller.dart';
import 'services/telemetry_service.dart';
import 'services/navigation_channel.dart';
import 'services/reminder_scope_store.dart';
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
    await Env.init();
    await ReminderScopeStore.instance.initialize();
    await NavigationChannel.instance.init();
    await ThemeController.instance.init();
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

class MySchedApp extends StatelessWidget {
  const MySchedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, mode, _) {
        return AnimatedSwitcher(
          duration: AppTokens.motion.slow,
          switchInCurve: AppTokens.motion.ease,
          switchOutCurve: AppTokens.motion.ease,
          child: _ThemedApp(
            key: ValueKey<ThemeMode>(mode),
            themeMode: mode,
          ),
        );
      },
    );
  }
}

class _ThemedApp extends StatelessWidget {
  const _ThemedApp({required this.themeMode, super.key});

  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      key: key,
      title: 'MySched',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
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
          child: content,
        );
      },
      routerConfig: appRouter,
    );
  }
}
