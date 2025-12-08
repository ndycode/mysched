import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../ui/tokens.dart';

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
      title: 'Don’t miss a thing',
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
        duration: const Duration(milliseconds: 260),
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

    setState(() => _requesting = false);

    if (granted) {
      widget.onFinished?.call();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please allow camera and notifications to continue.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final shellPadding = EdgeInsets.fromLTRB(
      AppSpacing.xl,
      media.padding.top + AppSpacing.xxxl,
      AppSpacing.xl,
      AppSpacing.quad,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: shellPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: AppSpacing.xl),
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
                  const SizedBox(height: AppSpacing.lg),
                  _ProgressDots(count: _pages.length, activeIndex: _index),
                  const SizedBox(height: AppSpacing.lg),
                  _buildActions(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Icon(
            Icons.calendar_today_rounded,
            color: theme.colorScheme.primary,
            size: AppIconSize.lg,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MySched', style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.xs),
            Text('Plan • Scan • Notify', style: AppTypography.captionMuted),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _index == _pages.length - 1;
    return Row(
      children: [
        TextButton(
          onPressed: _requesting ? null : widget.onFinished,
          child: const Text('Skip'),
        ),
        const Spacer(),
        SizedBox(
          height: AppComponentSize.buttonMd,
          child: ElevatedButton(
            onPressed: _requesting ? null : _next,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: _requesting
                ? SizedBox(
                    width: AppIconSize.md,
                    height: AppIconSize.md,
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(isLast ? 'Enable & continue' : 'Next'),
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: AppShadow.md,
            offset: const Offset(0, 4),
            color: theme.colorScheme.onSurface.withOpacity(0.05),
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
              size: 56,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(page.title, style: AppTypography.headline),
          const SizedBox(height: AppSpacing.sm),
          Text(page.subtitle, style: AppTypography.body),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: page.chips
                .map(
                  (chip) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Text(
                      chip,
                      style: AppTypography.caption.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          if (page.highlightPermissions) ...[
            const SizedBox(height: AppSpacing.xl),
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Permissions needed', style: AppTypography.subtitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Allow camera for schedule scans and notifications for reliable alarms.',
                  style: AppTypography.body,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          height: AppSpacing.sm,
          width: index == activeIndex ? AppSpacing.lg : AppSpacing.md,
          decoration: BoxDecoration(
            color: index == activeIndex
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppRadius.full),
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
