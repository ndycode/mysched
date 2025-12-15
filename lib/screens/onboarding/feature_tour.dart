import 'package:flutter/material.dart';

import '../../services/onboarding_service.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';

/// Full-screen onboarding tour showing app features.
class FeatureTourScreen extends StatefulWidget {
  const FeatureTourScreen({
    super.key,
    this.onComplete,
  });

  /// Called when the tour is completed or skipped.
  final VoidCallback? onComplete;

  @override
  State<FeatureTourScreen> createState() => _FeatureTourScreenState();
}

class _FeatureTourScreenState extends State<FeatureTourScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < TourSteps.mainTour.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTour();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeTour() async {
    await OnboardingService.instance.completeTour();
    widget.onComplete?.call();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _skipTour() {
    _completeTour();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    final steps = TourSteps.mainTour;
    final isLastPage = _currentPage == steps.length - 1;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with skip button
            Padding(
              padding: spacing.edgeInsetsSymmetric(
                horizontal: spacing.xl * spacingScale,
                vertical: spacing.md * spacingScale,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress indicator
                  Text(
                    '${_currentPage + 1} / ${steps.length}',
                    style: AppTokens.typography.captionScaled(scale).copyWith(
                      color: palette.muted,
                    ),
                  ),
                  // Skip button
                  if (!isLastPage)
                    TextButton(
                      onPressed: _skipTour,
                      child: Text(
                        'Skip',
                        style: AppTokens.typography.label.copyWith(
                          color: palette.muted,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 50),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return _TourPage(step: step);
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: spacing.edgeInsetsAll(spacing.lg * spacingScale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(steps.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 4 * spacingScale),
                    width: isActive ? 24 * scale : 8 * scale,
                    height: 8 * scale,
                    decoration: BoxDecoration(
                      color: isActive
                          ? colors.primary
                          : colors.primary.withValues(alpha: AppOpacity.faint),
                      borderRadius: AppTokens.radius.pill,
                    ),
                  );
                }),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: spacing.edgeInsetsAll(spacing.xl * spacingScale),
              child: Row(
                children: [
                  // Back button
                  if (_currentPage > 0) ...[
                    Expanded(
                      child: SecondaryButton(
                        label: 'Back',
                        onPressed: _previousPage,
                      ),
                    ),
                    SizedBox(width: spacing.md * spacingScale),
                  ],
                  // Next/Done button
                  Expanded(
                    flex: _currentPage > 0 ? 2 : 1,
                    child: PrimaryButton(
                      label: isLastPage ? 'Get Started' : 'Next',
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourPage extends StatelessWidget {
  const _TourPage({required this.step});

  final TourStep step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return Padding(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.xxl * spacingScale,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120 * scale,
            height: 120 * scale,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: AppOpacity.overlay),
              borderRadius: AppTokens.radius.xl,
            ),
            child: Icon(
              IconData(step.icon, fontFamily: 'MaterialIcons'),
              size: 60 * scale,
              color: colors.primary,
            ),
          ),

          SizedBox(height: spacing.xxl * spacingScale),

          // Title
          Text(
            step.title,
            style: AppTokens.typography.headlineScaled(scale).copyWith(
              fontWeight: AppTokens.fontWeight.bold,
              color: colors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: spacing.lg * spacingScale),

          // Description
          Text(
            step.description,
            style: AppTokens.typography.bodyScaled(scale).copyWith(
              color: palette.muted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
