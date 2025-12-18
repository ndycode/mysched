import 'package:flutter/material.dart';

import '../../services/connection_monitor.dart' as conn;
import '../../services/offline_queue.dart';
import '../theme/tokens.dart';

/// A banner that appears when the app is offline, showing pending mutation count.
/// 
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     // Your main content
///     Scaffold(...),
///     // Overlay the banner at the top
///     const Positioned(
///       top: 0,
///       left: 0,
///       right: 0,
///       child: SafeArea(child: OfflineBanner()),
///     ),
///   ],
/// )
/// ```
class GlobalOfflineBanner extends StatefulWidget {
  const GlobalOfflineBanner({
    super.key,
    this.onTap,
  });

  /// Called when the banner is tapped (optional).
  final VoidCallback? onTap;

  @override
  State<GlobalOfflineBanner> createState() => _GlobalOfflineBannerState();
}

class _GlobalOfflineBannerState extends State<GlobalOfflineBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  bool _isDismissed = false;
  conn.ConnectionState _lastState = conn.ConnectionState.unknown;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTokens.motion.medium,
    );
    
    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: AppTokens.motion.easeOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppTokens.motion.easeOut),
    );
    
    // Listen for connection changes
    conn.ConnectionMonitor.instance.state.addListener(_onConnectionChange);
    _lastState = conn.ConnectionMonitor.instance.state.value;
    
    // Initial state check
    if (_lastState == conn.ConnectionState.offline) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    conn.ConnectionMonitor.instance.state.removeListener(_onConnectionChange);
    _controller.dispose();
    super.dispose();
  }

  void _onConnectionChange() {
    final newState = conn.ConnectionMonitor.instance.state.value;
    
    if (newState == conn.ConnectionState.offline && _lastState != conn.ConnectionState.offline) {
      // Just went offline
      _isDismissed = false;
      _controller.forward();
    } else if (newState == conn.ConnectionState.online && _lastState == conn.ConnectionState.offline) {
      // Just came back online
      _controller.reverse();
    }
    
    _lastState = newState;
  }

  void _onDismiss() {
    setState(() {
      _isDismissed = true;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.value == 0 || _isDismissed) {
          return const SizedBox.shrink();
        }
        
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: child,
          ),
        );
      },
      child: _OfflineBannerContent(
        onDismiss: _onDismiss,
        onTap: widget.onTap,
      ),
    );
  }
}

class _OfflineBannerContent extends StatelessWidget {
  const _OfflineBannerContent({
    required this.onDismiss,
    this.onTap,
  });

  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final shadow = AppTokens.shadow;
    final componentSize = AppTokens.componentSize;
    
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.only(
          left: spacing.md,
          right: spacing.md,
          top: spacing.xs,
          bottom: spacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: AppTokens.radius.md,
          boxShadow: [
            shadow.elevation2(colors.shadow.withValues(alpha: AppOpacity.dim)),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTokens.radius.md,
          child: Padding(
            padding: spacing.edgeInsetsSymmetric(
              horizontal: spacing.md,
              vertical: spacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: AppTokens.iconSize.md,
                  color: colors.onErrorContainer,
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'You\'re offline',
                        style: AppTokens.typography.label.copyWith(
                          color: colors.onErrorContainer,
                          fontWeight: AppTokens.fontWeight.semiBold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: OfflineQueue.instance.pendingCount,
                        builder: (context, count, _) {
                          if (count == 0) {
                            return Text(
                              'Changes will sync when connected',
                              style: AppTokens.typography.caption.copyWith(
                                color: colors.onErrorContainer.withValues(alpha: AppOpacity.secondary),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          }
                          return Text(
                            '$count change${count == 1 ? '' : 's'} waiting to sync',
                            style: AppTokens.typography.caption.copyWith(
                              color: colors.onErrorContainer.withValues(alpha: AppOpacity.secondary),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: OfflineQueue.instance.isSyncing,
                  builder: (context, syncing, _) {
                    if (syncing) {
                      return SizedBox(
                        width: componentSize.spinnerSm,
                        height: componentSize.spinnerSm,
                        child: CircularProgressIndicator(
                          strokeWidth: componentSize.progressStroke,
                          valueColor: AlwaysStoppedAnimation(colors.onErrorContainer),
                        ),
                      );
                    }
                    return IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: AppTokens.iconSize.sm,
                        color: colors.onErrorContainer.withValues(alpha: AppOpacity.muted),
                      ),
                      onPressed: onDismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A wrapper widget that adds the offline banner at the top of any screen.
/// 
/// Usage:
/// ```dart
/// OfflineBannerWrapper(
///   child: Scaffold(...),
/// )
/// ```
class OfflineBannerWrapper extends StatelessWidget {
  const OfflineBannerWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: GlobalOfflineBanner(),
          ),
        ),
      ],
    );
  }
}
