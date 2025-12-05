import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:go_router/go_router.dart';

import '../env.dart';
import '../services/notif_scheduler.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';
import '../utils/app_log.dart';
import '../utils/local_notifs.dart';
import 'constants.dart';
import 'routes.dart';

class BootstrapGate extends StatefulWidget {
  const BootstrapGate({super.key});

  /// When true (typically under widget tests), skips the permission dialogs
  /// so FakeAsync timers do not linger.
  static bool debugBypassPermissions = true;
  static bool _alarmPromptCompleted = false;

  @override
  State<BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<BootstrapGate> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
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

  void _goNext() {
    if (_navigated || !mounted) return;
    final signedIn =
        Env.isInitialized && Env.supa.auth.currentSession != null;
    _navigated = true;
    context.go(signedIn ? AppRoutes.app : AppRoutes.login);
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
    // Skip if critical permissions are ready (battery optimization is optional).
    final readiness = await LocalNotifs.alarmReadiness();
    final alreadyReady = readiness.exactAlarmAllowed &&
        readiness.notificationsAllowed;
    if (alreadyReady) {
      BootstrapGate._alarmPromptCompleted = true;
      return;
    }
    if (!mounted) return;
    await showSmoothDialog<void>(
      context: context,
      barrierDismissible: false,
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
    final allow = await showSmoothDialog<bool>(
          context: context,
          barrierDismissible: false,
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
      await showSmoothDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _PermissionSettingsDialog(title: title),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
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
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
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
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;
    final colors = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;

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
                    color: colors.brand,
                    letterSpacing: AppLetterSpacing.tight,
                  ),
                ),
                SizedBox(height: spacing.sm),
                // Clean Tagline
                Text(
                  'Your Schedule, Simplified',
                  style: AppTokens.typography.body.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: spacing.xxxl),
                // Minimalist Loader (Apple style)
                SizedBox(
                  width: AppInteraction.loaderSizeLarge,
                  height: AppInteraction.loaderSizeLarge,
                  child: CircularProgressIndicator(
                    strokeWidth: AppInteraction.progressStrokeWidthLarge,
                    color: colors.brand.withValues(alpha: AppOpacity.prominent),
                    backgroundColor: colors.brand.withValues(alpha: AppOpacity.overlay),
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
    final badgeColor = widget.accent.withValues(alpha: isDark ? 0.28 : AppOpacity.statusBg);

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
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            widget.message,
            style: AppTokens.typography.bodySecondary.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.xxl),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: colors.onSurfaceVariant,
                ),
                child: const Text('Not now'),
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
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            'You denied this permission. You can enable it later from system settings.',
            style: AppTokens.typography.bodySecondary.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.xxl),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: colors.onSurfaceVariant,
                ),
                child: const Text('Close'),
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
    if (!mounted) return;
    setState(() {
      _readiness = readiness;
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

  Future<void> _openBatterySettings({bool preferAppInfo = true}) async {
    setState(() => _busy = true);
    await LocalNotifs.openBatteryOptimizationSettings(preferAppInfo: preferAppInfo);
    await _refresh();
    if (!mounted) return;
    setState(() => _busy = false);
    _openedBatteryOnce = true;
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
    return r.exactAlarmAllowed &&
        r.notificationsAllowed &&
        r.ignoringBatteryOptimizations;
  }

  bool get _exactAllowed => _readiness?.exactAlarmAllowed ?? false;
  bool get _notificationsAllowed => _readiness?.notificationsAllowed ?? false;
  bool get _canAdvanceToGuide => _exactAllowed && _notificationsAllowed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xl),
      backgroundColor: isDark ? colors.surface : colors.surfaceContainerLowest,
      insetPadding: spacing.edgeInsetsSymmetric(horizontal: spacing.lg),
      child: Container(
        constraints: BoxConstraints(maxWidth: AppLayout.dialogMaxWidth),
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
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Turn on these settings so class reminders fire on time.',
            style: AppTokens.typography.bodySecondary.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: AppTokens.typography.bodySecondary.fontSize,
            ),
          ),
          SizedBox(height: spacing.xxl),
          StatusRow(
            icon: Icons.alarm_on_rounded,
            label: 'Exact alarms',
            description: 'Required for time-sensitive reminders.',
            status: _readiness?.exactAlarmAllowed,
            onTap: _busy ? null : _openExactAlarms,
          ),
          SizedBox(height: spacing.sm),
          StatusRow(
            icon: Icons.notifications_active_outlined,
            label: 'Notifications',
            description: 'Backup alert if full-screen alarms are blocked.',
            status: _readiness?.notificationsAllowed,
            onTap: _busy ? null : _requestNotifications,
          ),
          SizedBox(height: spacing.md),
          StatusRow(
            icon: Icons.battery_alert_rounded,
            label: 'Battery optimization (recommended)',
            description: 'Set MySched to Unrestricted so alarms are not killed.',
            status: _readiness?.ignoringBatteryOptimizations,
            optional: true,
            onTap: _busy ? null : _openBatterySettings,
          ),
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
                    color: colors.onSurfaceVariant,
                    fontSize: AppTokens.typography.caption.fontSize,
                  ),
                ),
              ],
            )
          else
            Text(
              'Status updates automatically after you return.',
              style: AppTokens.typography.bodySecondary.copyWith(
                color: colors.onSurfaceVariant,
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
                    : () {
                        widget.onComplete();
                        Navigator.of(context).pop();
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
    );
  }

  Future<void> _showBatteryGuide(BuildContext context) async {
    await LocalNotifs.openBatteryOptimizationDialog(context);
  }
}

// _StatusRow and _StatusPill removed - using global StatusRow from kit.dart
