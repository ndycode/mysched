import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:go_router/go_router.dart';

import '../env.dart';
import '../services/instructor_service.dart';
import '../services/notification_scheduler.dart';
import '../services/theme_controller.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/motion.dart';
import '../ui/theme/tokens.dart';
import '../utils/app_log.dart';
import '../utils/local_notifs.dart';
import 'constants.dart';
import 'routes.dart';

class BootstrapGate extends StatefulWidget {
  const BootstrapGate({super.key});

  /// When true (typically under widget tests), skips the permission dialogs
  /// so FakeAsync timers do not linger.
  static bool debugBypassPermissions = false;
  static bool _alarmPromptCompleted = false;

  @override
  State<BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<BootstrapGate> {
  bool _navigated = false;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;
    
    // Ensure splash branding is visible for minimum display time (cancellable for tests)
    final completer = Completer<void>();
    _splashTimer = Timer(AppTokens.durations.splashMinDisplay, () {
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
    if (!mounted) return;
    
    try {
      await _requestPermissionFlow();
    } catch (error, stackTrace) {
      AppLog.warn(
        'BootstrapGate',
        'Permission flow failed; continuing bootstrap',
        error: error,
        data: {'stack': stackTrace.toString()},
      );
    }
    if (Platform.isAndroid &&
        mounted &&
        !BootstrapGate._alarmPromptCompleted) {
      await _showAlarmPrompt();
    }
    _goNext();
  }

  Future<void> _goNext() async {
    if (_navigated || !mounted) return;
    
    // Check if we have a session
    final hasSession =
        Env.isInitialized && Env.supa.auth.currentSession != null;
    
    bool signedIn = false;
    if (hasSession) {
      // Try to validate the session by attempting a refresh
      // This catches stale sessions BEFORE the app spams API calls
      try {
        final response = await Env.supa.auth.refreshSession();
        signedIn = response.session != null;
        if (signedIn) {
          AppLog.info('BootstrapGate', 'Session refreshed successfully');
        }
      } catch (e) {
        // Session is stale/invalid - force logout
        AppLog.warn(
          'BootstrapGate',
          'Session refresh failed - forcing logout',
          error: e,
        );
        try {
          await Env.supa.auth.signOut();
        } catch (_) {
          // Ignore signOut errors - session is already invalid
        }
        signedIn = false;
      }
    }
    
    // Check instructor status for validated signed-in users
    if (signedIn) {
      await InstructorService.instance.checkInstructorStatus();
    }
    
    _navigated = true;
    if (!mounted) return;
    
    context.pushReplacement(signedIn ? AppRoutes.app : AppRoutes.login);
  }

  Future<void> _requestPermissionFlow() async {
    if (!mounted) return;
    if (BootstrapGate.debugBypassPermissions) return;
    try {
      final colors = Theme.of(context).colorScheme;

      await _ensurePermission(
        permission: Permission.camera,
        accent: colors.primary,
        icon: Icons.camera_alt_outlined,
        title: 'Allow camera access',
        message:
            'MySched uses your camera to scan student ID cards and schedules quickly.',
      );

      await _ensurePermission(
        permission: Permission.notification,
        accent: colors.secondary,
        icon: Icons.notifications_active_outlined,
        title: 'Enable notifications',
        message:
            'Turn on class reminders so you get heads-up alerts before anything starts.',
        onGranted: () async {
          await NotifScheduler.resync();
        },
      );
    } catch (error, stackTrace) {
      AppLog.error(
        'BootstrapGate',
        'Permission bootstrap failed',
        error: error,
        stack: stackTrace,
      );
    }
  }

  Future<void> _showAlarmPrompt() async {
    if (!mounted) return;
    if (BootstrapGate.debugBypassPermissions) return;
    // Skip only if ALL permissions are ready (including battery optimization and fullscreen intent).
    final readiness = await LocalNotifs.alarmReadiness();
    final fullScreenReady = readiness.sdkInt < 34 || readiness.fullScreenIntentAllowed;
    final alreadyReady = readiness.exactAlarmAllowed &&
        readiness.notificationsAllowed &&
        readiness.ignoringBatteryOptimizations &&
        fullScreenReady;
    if (alreadyReady) {
      BootstrapGate._alarmPromptCompleted = true;
      return;
    }
    if (!mounted) return;
    await AppModal.alert<void>(
      context: context,
      dismissible: false,
      builder: (_) => _AlarmPromptDialog(
        onComplete: () {
          BootstrapGate._alarmPromptCompleted = true;
        },
      ),
    );
  }

  Future<void> _ensurePermission({
    required Permission permission,
    required IconData icon,
    required Color accent,
    required String title,
    required String message,
    Future<void> Function()? onGranted,
  }) async {
    var status = await permission.status;
    if (status.isGranted || status.isLimited) {
      if (onGranted != null) {
        await onGranted();
      }
      return;
    }

    if (!mounted) return;
    final allow = await AppModal.alert<bool>(
          context: context,
          dismissible: false,
          builder: (context) => _PermissionDialog(
            icon: icon,
            accent: accent,
            title: title,
            message: message,
          ),
        ) ??
        false;

    if (!allow) {
      return;
    }

    status = await permission.request();
    if (status.isGranted || status.isLimited) {
      if (onGranted != null) {
        await onGranted();
      }
      return;
    }

    if (status.isPermanentlyDenied && mounted) {
      await AppModal.alert<void>(
        context: context,
        dismissible: false,
        builder: (context) => _PermissionSettingsDialog(title: title),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      screenName: 'splash',
      safeArea: false,
      body: AppBackground(
        child: _SplashContent(),
      ),
    );
  }
}

class _LifecycleObserver extends WidgetsBindingObserver {
  _LifecycleObserver({required this.onResume});

  final Future<void> Function() onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}

class _SplashContent extends StatefulWidget {
  const _SplashContent();

  @override
  State<_SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<_SplashContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTokens.motion.slower * 1.6,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    
    _scaleAnimation = Tween<double>(begin: AppMotionSystem.scaleEntry, end: AppMotionSystem.scaleNone).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platformBrightness = MediaQuery.of(context).platformBrightness;
    final themeMode = ThemeController.instance.currentMode;
    // Resolve actual brightness based on user's theme preference
    final bool isDark;
    switch (themeMode) {
      case AppThemeMode.dark:
      case AppThemeMode.voidMode:
        isDark = true;
        break;
      case AppThemeMode.light:
        isDark = false;
        break;
      case AppThemeMode.system:
        isDark = platformBrightness == Brightness.dark;
        break;
    }
    final colors = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    // Use custom accent color if set, otherwise default brand color
    final accent = ThemeController.instance.accentColor.value ?? colors.brand;

    return Container(
      color: colors.surface, // Clean solid background
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minimalist Brand Text
                Text(
                  AppConstants.appName,
                  style: AppTokens.typography.brand.copyWith(
                    color: accent,
                    letterSpacing: AppLetterSpacing.tight,
                  ),
                ),
                SizedBox(height: spacing.sm),
                // Clean Tagline
                Text(
                  'Your Schedule, Simplified',
                  style: AppTokens.typography.body.copyWith(
                    color: colors.muted,
                    fontWeight: AppTokens.fontWeight.regular,
                  ),
                ),
                SizedBox(height: spacing.xxxl),
                // Minimalist Loader (Apple style)
                SizedBox(
                  width: AppInteraction.loaderSizeLarge,
                  height: AppInteraction.loaderSizeLarge,
                  child: CircularProgressIndicator(
                    strokeWidth: AppInteraction.progressStrokeWidthLarge,
                    color: accent.withValues(alpha: AppOpacity.prominent),
                    backgroundColor: accent.withValues(alpha: AppOpacity.overlay),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _PermissionDialog extends StatefulWidget {
  const _PermissionDialog({
    required this.icon,
    required this.accent,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String message;

  @override
  State<_PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<_PermissionDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final badgeColor = widget.accent.withValues(alpha: isDark ? AppOpacity.shadowAction : AppOpacity.statusBg);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sheet),
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: spacing.edgeInsetsSymmetric(horizontal: spacing.xxl),
      contentPadding: spacing.edgeInsetsAll(spacing.xxl),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: AppTokens.componentSize.avatarXl,
            width: AppTokens.componentSize.avatarXl,
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: AppTokens.radius.lg,
            ),
            child: Icon(widget.icon, color: widget.accent),
          ),
          SizedBox(height: spacing.xl),
          Text(
            widget.title,
            style: AppTokens.typography.title.copyWith(
              color: colors.onSurface,
              fontWeight: AppTokens.fontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            widget.message,
            style: AppTokens.typography.bodySecondary.copyWith(
              color: palette.muted,
            ),
          ),
          SizedBox(height: spacing.xxl),
          Row(
            children: [
              TertiaryButton(
                label: 'Not now',
                onPressed: () => Navigator.of(context).pop(false),
                expanded: false,
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: PrimaryButton(
                  label: 'Allow',
                  expanded: false,
                  minHeight: AppTokens.componentSize.buttonMd,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PermissionSettingsDialog extends StatelessWidget {
  const _PermissionSettingsDialog({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sheet),
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: spacing.edgeInsetsSymmetric(horizontal: spacing.xxl),
      contentPadding: spacing.edgeInsetsAll(spacing.xxl),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title required',
            style: AppTokens.typography.title.copyWith(
              color: colors.onSurface,
              fontWeight: AppTokens.fontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            'You denied this permission. You can enable it later from system settings.',
            style: AppTokens.typography.bodySecondary.copyWith(
              color: palette.muted,
            ),
          ),
          SizedBox(height: spacing.xxl),
          Row(
            children: [
              TertiaryButton(
                label: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                expanded: false,
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: PrimaryButton(
                  label: 'Open settings',
                  expanded: false,
                  minHeight: AppTokens.componentSize.buttonMd,
                  onPressed: () {
                    Navigator.of(context).pop();
                    openAppSettings();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlarmPromptDialog extends StatefulWidget {
  const _AlarmPromptDialog({required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<_AlarmPromptDialog> createState() => _AlarmPromptDialogState();
}

class _AlarmPromptDialogState extends State<_AlarmPromptDialog> {
  AlarmReadiness? _readiness;
  bool _loading = true;
  bool _busy = false;
  _LifecycleObserver? _observer;
  bool _openedBatteryOnce = false;
  bool _needsAutoStart = false;
  String _manufacturer = '';

  @override
  void initState() {
    super.initState();
    _refresh();
    _observer = _LifecycleObserver(onResume: _refresh);
    WidgetsBinding.instance.addObserver(_observer!);
  }

  @override
  void dispose() {
    final obs = _observer;
    if (obs != null) {
      WidgetsBinding.instance.removeObserver(obs);
    }
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
    });
    final readiness = await LocalNotifs.alarmReadiness();
    final needsAutoStart = await LocalNotifs.needsAutoStartPermission();
    final manufacturer = await LocalNotifs.getDeviceManufacturer();
    if (!mounted) return;
    setState(() {
      _readiness = readiness;
      _needsAutoStart = needsAutoStart;
      _manufacturer = manufacturer;
      _loading = false;
    });
  }

  Future<void> _openExactAlarms() async {
    setState(() => _busy = true);
    await LocalNotifs.openExactAlarmSettings();
    await _refresh();
    if (!mounted) return;
    setState(() => _busy = false);
  }

  Future<void> _requestNotifications() async {
    setState(() => _busy = true);
    final status = await Permission.notification.status;
    if (status.isPermanentlyDenied) {
      await LocalNotifs.openNotificationSettings();
    } else {
      await Permission.notification.request();
    }
    await _refresh();
    if (!mounted) return;
    setState(() => _busy = false);
  }

  bool get _ready {
    final r = _readiness;
    if (_loading || r == null) return false;
    // Exact alarms + notifications required; fullscreen intent required on Android 14+
    final fullScreenReady = r.sdkInt < 34 || r.fullScreenIntentAllowed;
    return r.exactAlarmAllowed && r.notificationsAllowed && fullScreenReady;
  }

  bool get _exactAllowed => _readiness?.exactAlarmAllowed ?? false;
  bool get _notificationsAllowed => _readiness?.notificationsAllowed ?? false;
  bool get _fullScreenIntentAllowed => _readiness?.fullScreenIntentAllowed ?? true;
  bool get _isAndroid14Plus => (_readiness?.sdkInt ?? 0) >= 34;
  bool get _canAdvanceToGuide => _exactAllowed && _notificationsAllowed && (_fullScreenIntentAllowed || !_isAndroid14Plus);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xl),
      backgroundColor: isDark ? colors.surface : colors.surfaceContainerLowest,
      insetPadding: spacing.edgeInsetsSymmetric(horizontal: spacing.lg),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppLayout.dialogMaxWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: spacing.edgeInsetsAll(spacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enable reliable alarms',
                style: AppTokens.typography.title.copyWith(
                  color: colors.onSurface,
                  fontSize: AppTokens.typography.title.fontSize,
                  fontWeight: AppTokens.fontWeight.bold,
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                'Turn on these settings so class reminders fire on time.',
                style: AppTokens.typography.bodySecondary.copyWith(
                  color: palette.muted,
                  fontSize: AppTokens.typography.bodySecondary.fontSize,
                ),
              ),
              SizedBox(height: spacing.xxl),
              StatusRow(
                icon: Icons.alarm_on_rounded,
                label: 'Exact alarms',
                description: 'Required for time-sensitive reminders.',
                status: _readiness?.exactAlarmAllowed,
              ),
              SizedBox(height: spacing.sm),
              StatusRow(
                icon: Icons.notifications_active_outlined,
                label: 'Notifications',
                description: 'Backup alert if full-screen alarms are blocked.',
                status: _readiness?.notificationsAllowed,
              ),
              // Fullscreen intent permission (Android 14+ only)
              if (_isAndroid14Plus) ...[
                SizedBox(height: spacing.sm),
                StatusRow(
                  icon: Icons.fullscreen_rounded,
                  label: 'Full-screen alarms',
                  description: 'Required on Android 14+ to wake screen for alarms.',
                  status: _readiness?.fullScreenIntentAllowed,
                  onTap: !(_readiness?.fullScreenIntentAllowed ?? true)
                      ? () => LocalNotifs.openFullScreenIntentSettings()
                      : null,
                ),
              ],
              SizedBox(height: spacing.md),
              StatusRow(
                icon: Icons.battery_alert_rounded,
                label: 'Battery optimization (recommended)',
                description: 'Set MySched to Unrestricted so alarms are not killed.',
                status: _readiness?.ignoringBatteryOptimizations,
                optional: true,
              ),
              if (_needsAutoStart) ...[
                SizedBox(height: spacing.md),
                StatusRow(
                  icon: Icons.launch_rounded,
                  label: 'Auto-start permission',
                  description: 'Required for ${_manufacturer.isNotEmpty ? _manufacturer.substring(0, 1).toUpperCase() + _manufacturer.substring(1) : "this device"}. Tap to enable.',
                  status: null, // We can't detect if granted, so show as action
                  optional: true,
                  onTap: () => LocalNotifs.openAutoStartSettings(),
                ),
              ],
              SizedBox(height: spacing.xl),
              if (_loading)
                Row(
                  children: [
                    SizedBox(
                      width: AppInteraction.loaderSizeSmall,
                      height: AppInteraction.loaderSizeSmall,
                      child: CircularProgressIndicator(
                        strokeWidth: AppInteraction.progressStrokeWidth,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    Text(
                      'Checking status...',
                      style: AppTokens.typography.bodySecondary.copyWith(
                        color: palette.muted,
                        fontSize: AppTokens.typography.caption.fontSize,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'Status updates automatically after you return.',
                  style: AppTokens.typography.bodySecondary.copyWith(
                    color: palette.muted,
                    fontSize: AppTokens.typography.caption.fontSize,
                  ),
                ),
              SizedBox(height: spacing.xxl),
              if (_ready)
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Continue',
                    expanded: true,
                    minHeight: AppTokens.componentSize.buttonLg,
                    onPressed: _busy
                        ? null
                        : () async {
                            // Show battery guide first if not yet optimized
                            if (!(_readiness?.ignoringBatteryOptimizations ?? false)) {
                              await _showBatteryGuide(context);
                              await _refresh();
                              if (!mounted) return;
                            }
                            widget.onComplete();
                            if (mounted && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                  ),
                )
              else if (!_canAdvanceToGuide)
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Open settings',
                    expanded: true,
                    minHeight: AppTokens.componentSize.buttonLg,
                    onPressed: _busy
                        ? null
                        : () {
                            if (!_exactAllowed) {
                              _openExactAlarms();
                            } else {
                              _requestNotifications();
                            }
                          },
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Next',
                    expanded: true,
                    minHeight: AppTokens.componentSize.buttonLg,
                    onPressed: _busy
                        ? null
                        : () async {
                            await _showBatteryGuide(context);
                            await _refresh();
                            if (!mounted || !context.mounted) return;
                            final allowed =
                                (_readiness?.ignoringBatteryOptimizations ?? false) &&
                                    _openedBatteryOnce;
                            if (allowed) {
                              Navigator.of(context).pop();
                            }
                          },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBatteryGuide(BuildContext context) async {
    await LocalNotifs.openBatteryOptimizationDialog(context);
    _openedBatteryOnce = true;
  }
}

// _StatusRow and _StatusPill removed - using global StatusRow from kit.dart
