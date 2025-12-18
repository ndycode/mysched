import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';

/// Lightweight, dashboard-aligned onboarding with two steps focused on
/// permissions and app value. Spacing/typography mirror dashboard specs.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    this.onFinished,
  });

  /// Called when the flow completes with required permissions granted.
  final VoidCallback? onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;
  bool _requesting = false;

  static const _pages = [
    _OnboardingPageData(
      title: 'Stay ahead of your day',
      subtitle: 'See classes and reminders together with clean, glanceable cards.',
      chips: ['Classes', 'Reminders', 'Widgets'],
      icon: Icons.dashboard_customize_rounded,
    ),
    _OnboardingPageData(
      title: "Don't miss a thing",
      subtitle:
          'Enable camera to scan schedules and allow notifications so alarms always reach you.',
      chips: ['Camera access', 'Live alerts'],
      icon: Icons.notifications_active_rounded,
      highlightPermissions: true,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
        duration: AppTokens.motion.page,
        curve: Curves.easeOut,
      );
      return;
    }
    await _requestRequiredPermissions();
  }

  Future<void> _requestRequiredPermissions() async {
    if (_requesting) return;
    setState(() => _requesting = true);

    final requests = <Permission>[
      Permission.camera,
      if (Platform.isAndroid) Permission.notification,
    ];

    final results = await requests.request();
    final granted = results.values.every((status) => status.isGranted);

    if (!mounted) return;
    setState(() => _requesting = false);

    if (granted) {
      widget.onFinished?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please allow camera and notifications to continue.'),
          duration: AppTokens.durations.snackbarDuration,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final spacing = AppTokens.spacing;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);
    
    final shellPadding = EdgeInsets.fromLTRB(
      spacing.xl,
      media.padding.top + spacing.xxxl,
      spacing.xl,
      spacing.quad,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: shellPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AppLayout.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, scale, spacingScale),
                  SizedBox(height: spacing.xl * spacingScale),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _pages.length,
                      onPageChanged: (value) {
                        setState(() => _index = value);
                      },
                      itemBuilder: (context, index) {
                        final page = _pages[index];
                        return _OnboardingCard(page: page);
                      },
                    ),
                  ),
                  SizedBox(height: spacing.lg),
                  _ProgressDots(count: _pages.length, activeIndex: _index),
                  SizedBox(height: spacing.lg),
                  _buildActions(context, scale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double scale, double spacingScale) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    
    return Row(
      children: [
        Container(
          padding: spacing.edgeInsetsAll(spacing.md * spacingScale),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: AppOpacity.highlight),
            borderRadius: AppTokens.radius.lg,
          ),
          child: Icon(
            Icons.calendar_today_rounded,
            color: colors.primary,
            size: AppTokens.iconSize.lg * scale,
          ),
        ),
        SizedBox(width: spacing.md * spacingScale),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MySched',
              style: AppTokens.typography.subtitleScaled(scale).copyWith(
                fontWeight: AppTokens.fontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              'Plan • Scan • Notify',
              style: AppTokens.typography.captionScaled(scale).copyWith(
                color: palette.muted,
                fontWeight: AppTokens.fontWeight.semiBold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, double scale) {
    final isLast = _index == _pages.length - 1;
    final spacing = AppTokens.spacing;
    
    return Row(
      children: [
        TertiaryButton(
          label: 'Skip',
          onPressed: _requesting ? null : widget.onFinished,
          expanded: false,
        ),
        const Spacer(),
        PrimaryButton(
          label: isLast ? 'Enable & continue' : 'Next',
          onPressed: _requesting ? null : _next,
          loading: _requesting,
          loadingLabel: 'Enabling...',
          expanded: false,
          minHeight: AppTokens.componentSize.buttonMd,
          padding: spacing.edgeInsetsSymmetric(
            horizontal: spacing.xl,
            vertical: spacing.md,
          ),
        ),
      ],
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({required this.page});

  final _OnboardingPageData page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);
    
    return Container(
      padding: spacing.edgeInsetsAll(spacing.xxl * spacingScale),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: isDark
              ? colors.outline.withValues(alpha: AppOpacity.overlay)
              : colors.outline,
          width: isDark
              ? AppTokens.componentSize.divider
              : AppTokens.componentSize.dividerThin,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: AppOpacity.veryFaint),
                  blurRadius: AppTokens.shadow.lg,
                  offset: AppShadowOffset.sm,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Icon(
              page.icon,
              size: AppTokens.iconSize.display * scale,
              color: colors.primary,
            ),
          ),
          SizedBox(height: spacing.lg),
          Text(
            page.title,
            style: AppTokens.typography.headlineScaled(scale).copyWith(
              fontWeight: AppTokens.fontWeight.extraBold,
              letterSpacing: AppLetterSpacing.snug,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            page.subtitle,
            style: AppTokens.typography.bodyScaled(scale).copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.lg),
          Wrap(
            spacing: spacing.md,
            runSpacing: spacing.sm,
            children: page.chips
                .map(
                  (chip) => Container(
                    padding: spacing.edgeInsetsSymmetric(
                      horizontal: spacing.md,
                      vertical: spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: AppOpacity.highlight),
                      borderRadius: AppTokens.radius.lg,
                    ),
                    child: Text(
                      chip,
                      style: AppTokens.typography.captionScaled(scale).copyWith(
                        color: colors.primary,
                        fontWeight: AppTokens.fontWeight.semiBold,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          if (page.highlightPermissions) ...[
            SizedBox(height: spacing.xl),
            _PermissionCallout(),
          ],
        ],
      ),
    );
  }
}

class _PermissionCallout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);
    
    return Container(
      padding: spacing.edgeInsetsAll(spacing.lg * spacingScale),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: AppOpacity.highlight),
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: colors.primary.withValues(alpha: AppOpacity.medium),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.security_rounded,
            color: colors.primary,
            size: AppTokens.iconSize.md * scale,
          ),
          SizedBox(width: spacing.md * spacingScale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permissions needed',
                  style: AppTokens.typography.subtitleScaled(scale).copyWith(
                    fontWeight: AppTokens.fontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  'Allow camera for schedule scans and notifications for reliable alarms.',
                  style: AppTokens.typography.bodyScaled(scale).copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: AppTokens.motion.medium,
          margin: spacing.edgeInsetsSymmetric(horizontal: spacing.xs),
          height: spacing.sm,
          width: index == activeIndex ? spacing.lg : spacing.md,
          decoration: BoxDecoration(
            color: index == activeIndex
                ? colors.primary
                : palette.muted.withValues(alpha: AppOpacity.medium),
            borderRadius: AppTokens.radius.pill,
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.icon,
    this.highlightPermissions = false,
  });

  final String title;
  final String subtitle;
  final List<String> chips;
  final IconData icon;
  final bool highlightPermissions;
}
