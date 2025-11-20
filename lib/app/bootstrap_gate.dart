import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:go_router/go_router.dart';

import '../env.dart';
import '../services/notif_scheduler.dart';
import '../ui/kit/kit.dart';
import '../utils/app_log.dart';
import '../ui/theme/tokens.dart';
import 'routes.dart';

class BootstrapGate extends StatefulWidget {
  const BootstrapGate({super.key});

  /// When true (typically under widget tests), skips the permission dialogs
  /// so FakeAsync timers do not linger.
  static bool debugBypassPermissions = false;

  @override
  State<BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<BootstrapGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    if (!BootstrapGate.debugBypassPermissions) {
      try {
        await _requestPermissionFlow().timeout(
          const Duration(seconds: 5),
          onTimeout: () => Future<void>.value(),
        );
      } catch (_) {
        // ignore and continue
      }
    }
    if (!mounted) return;
    final signedIn =
        Env.isInitialized && Env.supa.auth.currentSession != null;
    context.go(signedIn ? AppRoutes.app : AppRoutes.login);
  }

  Future<void> _requestPermissionFlow() async {
    if (!mounted) return;
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
    final allow = await showDialog<bool>(
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
      await showDialog<void>(
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

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'MySched',
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A5DFF),
            ),
          ),
          SizedBox(height: 16),
          CircularProgressIndicator(color: Color(0xFF1A5DFF)),
        ],
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
    final badgeColor = widget.accent.withValues(alpha: isDark ? 0.28 : 0.14);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xl),
      backgroundColor: colors.surface,
      insetPadding: spacing.edgeInsetsSymmetric(horizontal: spacing.xxl),
      contentPadding: spacing.edgeInsetsAll(spacing.xxl),
      actionsPadding: EdgeInsets.fromLTRB(
        spacing.xxl,
        spacing.md,
        spacing.xxl,
        spacing.md,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            width: 52,
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
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(bottom: spacing.sm),
          child: Row(
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
                  expanded: true,
                  minHeight: 48,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ),
      ],
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
      shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xl),
      backgroundColor: colors.surface,
      insetPadding: spacing.edgeInsetsSymmetric(horizontal: spacing.xxl),
      contentPadding: spacing.edgeInsetsAll(spacing.xxl),
      actionsPadding: EdgeInsets.fromLTRB(
        spacing.xxl,
        spacing.md,
        spacing.xxl,
        spacing.md,
      ),
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
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(bottom: spacing.sm),
          child: Row(
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
                  expanded: true,
                  minHeight: 48,
                  onPressed: () {
                    Navigator.of(context).pop();
                    openAppSettings();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
