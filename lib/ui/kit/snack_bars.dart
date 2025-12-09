import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/tokens.dart';

enum AppSnackBarType { info, success, error }

/// Global key for snackbar overlay management.
final _snackbarOverlayKey = GlobalKey<_SnackbarOverlayState>();

/// Current snackbar overlay entry.
OverlayEntry? _currentSnackbar;

/// Shows a premium custom snackbar with global design tokens and proper shadow.
void showAppSnackBar(
  BuildContext context,
  String message, {
  AppSnackBarType type = AppSnackBarType.info,
  String? actionLabel,
  VoidCallback? onAction,
  Duration? duration,
  bool replaceQueue = true,
  bool useRootScaffold = true,
}) {
  // Dismiss any existing snackbar first
  if (replaceQueue) {
    hideAppSnackBars(context);
  }

  final overlay = Overlay.of(context, rootOverlay: useRootScaffold);
  final effectiveDuration = duration ?? AppTokens.durations.snackbarDuration;

  _currentSnackbar = OverlayEntry(
    builder: (context) => _SnackbarOverlay(
      key: _snackbarOverlayKey,
      message: message,
      type: type,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: effectiveDuration,
      onDismiss: () {
        _currentSnackbar?.remove();
        _currentSnackbar = null;
      },
    ),
  );

  overlay.insert(_currentSnackbar!);
}

/// Hides all current snackbars.
void hideAppSnackBars(BuildContext context) {
  _snackbarOverlayKey.currentState?.dismiss();
  _currentSnackbar?.remove();
  _currentSnackbar = null;
}

class _SnackbarOverlay extends StatefulWidget {
  const _SnackbarOverlay({
    super.key,
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final AppSnackBarType type;
  final Duration duration;
  final VoidCallback onDismiss;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  State<_SnackbarOverlay> createState() => _SnackbarOverlayState();
}

class _SnackbarOverlayState extends State<_SnackbarOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotionSystem.quick,
      reverseDuration: AppMotionSystem.fast,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppMotionSystem.easeOut,
      reverseCurve: AppMotionSystem.easeIn,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: AppMotionSystem.easeOut),
      reverseCurve: const Interval(0.5, 1.0, curve: AppMotionSystem.easeIn),
    ));

    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final media = MediaQuery.of(context);
    final spacing = AppTokens.spacing;

    late final Color accent;
    late final IconData icon;
    late final Color background;
    late final Color borderColor;
    late final Color contentColor;
    late final Color badgeFill;

    switch (widget.type) {
      case AppSnackBarType.success:
        accent = colors.tertiary;
        background =
            isDark ? colors.surfaceContainerHigh : colors.surface;
        borderColor = isDark
            ? colors.outline.withValues(alpha: AppOpacity.overlay)
            : colors.outlineVariant;
        contentColor = colors.onSurface;
        badgeFill = accent.withValues(alpha: AppOpacity.overlay);
        icon = Icons.check_circle_rounded;
        break;
      case AppSnackBarType.error:
        accent = palette.danger;
        background =
            isDark ? colors.surfaceContainerHigh : colors.surface;
        borderColor = isDark
            ? colors.outline.withValues(alpha: AppOpacity.overlay)
            : colors.outlineVariant;
        contentColor = colors.onSurface;
        badgeFill = accent.withValues(alpha: AppOpacity.overlay);
        icon = Icons.error_outline_rounded;
        break;
      case AppSnackBarType.info:
        accent = colors.primary;
        background =
            isDark ? colors.surfaceContainerHigh : colors.surface;
        borderColor = isDark
            ? colors.outline.withValues(alpha: AppOpacity.overlay)
            : colors.outlineVariant;
        contentColor = colors.onSurface;
        badgeFill = accent.withValues(alpha: AppOpacity.overlay);
        icon = Icons.info_outline_rounded;
        break;
    }

    return Positioned(
      left: spacing.xl,
      right: spacing.xl,
      // Position above nav bar: safe area + nav bar height (~80) + spacing
      bottom: media.padding.bottom + 80 + spacing.lg,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 100) {
                dismiss();
              }
            },
            onTap: dismiss,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.xl,
                  vertical: spacing.lg,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: AppTokens.radius.xl,
                  border: Border.all(
                    color: borderColor,
                    width: isDark
                        ? AppTokens.componentSize.divider
                        : AppTokens.componentSize.dividerThin,
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          AppTokens.shadow.modal(
                            colors.shadow.withValues(alpha: AppOpacity.border),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: AppTokens.componentSize.avatarMd,
                      height: AppTokens.componentSize.avatarMd,
                      decoration: BoxDecoration(
                        color: badgeFill,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child:
                          Icon(icon, color: accent, size: AppTokens.iconSize.sm),
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: AppTokens.fontWeight.semiBold,
                          color: contentColor,
                        ),
                      ),
                    ),
                    if (widget.actionLabel != null && widget.onAction != null) ...[
                      SizedBox(width: spacing.md),
                      GestureDetector(
                        onTap: () {
                          widget.onAction?.call();
                          dismiss();
                        },
                        child: Text(
                          widget.actionLabel!,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: AppTokens.fontWeight.bold,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
