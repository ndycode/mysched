import 'package:flutter/material.dart';

import '../../services/study_timer_service.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';

/// Shows the study timer as a modal sheet.
Future<void> showStudyTimerSheet(BuildContext context) {
  return AppModal.sheet(
    context: context,
    builder: (context) => const StudyTimerSheet(),
  );
}

/// A Pomodoro-style study timer modal sheet matching ClassDetailsSheet design.
class StudyTimerSheet extends StatefulWidget {
  const StudyTimerSheet({super.key});

  @override
  State<StudyTimerSheet> createState() => _StudyTimerSheetState();
}

class _StudyTimerSheetState extends State<StudyTimerSheet> {
  final _timer = StudyTimerService.instance;

  @override
  void initState() {
    super.initState();
    _timer.addListener(_onTimerChanged);
  }

  @override
  void dispose() {
    _timer.removeListener(_onTimerChanged);
    super.dispose();
  }

  void _onTimerChanged() {
    if (mounted) setState(() {});
  }

  String _sessionTypeLabel(SessionType type) {
    switch (type) {
      case SessionType.work:
        return 'Focus Time';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  Color _sessionColor(BuildContext context, SessionType type) {
    final colors = Theme.of(context).colorScheme;
    switch (type) {
      case SessionType.work:
        return colors.primary;
      case SessionType.shortBreak:
        return colors.tertiary;
      case SessionType.longBreak:
        return colors.secondary;
    }
  }

  IconData _sessionIcon(SessionType type) {
    switch (type) {
      case SessionType.work:
        return Icons.timer_outlined;
      case SessionType.shortBreak:
        return Icons.coffee_outlined;
      case SessionType.longBreak:
        return Icons.self_improvement_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    final sessionColor = _sessionColor(context, _timer.sessionType);

    return DetailShell(
      useBubbleShadow: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header - identical to class details
          SheetHeaderRow(
            title: 'Study Timer',
            subtitle: '${_timer.completedSessions} ${_timer.completedSessions == 1 ? 'session' : 'sessions'} today',
            icon: Icons.timer_outlined,
            onClose: () => Navigator.of(context).pop(),
          ),

          SizedBox(height: spacing.xl * spacingScale),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Session type badge - same as StatusInfoChip in class details
                  Wrap(
                    spacing: spacing.sm * spacingScale,
                    runSpacing: spacing.sm * spacingScale,
                    children: [
                      StatusInfoChip(
                        icon: _sessionIcon(_timer.sessionType),
                        label: _sessionTypeLabel(_timer.sessionType),
                        color: sessionColor,
                      ),
                      if (_timer.linkedClassTitle != null)
                        StatusInfoChip(
                          icon: Icons.book_outlined,
                          label: _timer.linkedClassTitle!,
                          color: colors.outline,
                        ),
                    ],
                  ),

                  SizedBox(height: spacing.lg * spacingScale),

                  // Timer display in main container - matching class details container
                  Container(
                    padding: EdgeInsets.all(spacing.xl * spacingScale),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colors.surfaceContainerHighest
                              .withValues(alpha: AppOpacity.ghost)
                          : colors.primary.withValues(alpha: AppOpacity.micro),
                      borderRadius: AppTokens.radius.lg,
                      border: Border.all(
                        color: isDark
                            ? colors.outline.withValues(alpha: AppOpacity.overlay)
                            : colors.primary.withValues(alpha: AppOpacity.dim),
                        width: AppTokens.componentSize.divider,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Timer display
                        Text(
                          _timer.formattedTime,
                          style: AppTokens.typography.display.copyWith(
                            fontSize: 56 * scale,
                            fontWeight: AppTokens.fontWeight.bold,
                            color: colors.onSurface,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: spacing.md * spacingScale),
                        // Progress indicator
                        ClipRRect(
                          borderRadius: AppTokens.radius.sm,
                          child: LinearProgressIndicator(
                            value: _timer.progress,
                            minHeight: 6 * scale,
                            backgroundColor:
                                colors.outline.withValues(alpha: AppOpacity.faint),
                            valueColor: AlwaysStoppedAnimation(sessionColor),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: spacing.lg * spacingScale),

                  // Stats container - matching class details info section
                  Container(
                    padding: EdgeInsets.all(spacing.lg * spacingScale),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colors.surfaceContainerHighest
                              .withValues(alpha: AppOpacity.ghost)
                          : colors.surface,
                      borderRadius: AppTokens.radius.lg,
                      border: Border.all(
                        color: isDark
                            ? colors.outline.withValues(alpha: AppOpacity.overlay)
                            : colors.outlineVariant,
                        width: AppTokens.componentSize.divider,
                      ),
                    ),
                    child: Column(
                      children: [
                        DetailRow(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Sessions',
                          value: '${_timer.completedSessions}',
                          accentIcon: true,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: spacing.lg * spacingScale),
                          child: Divider(
                            height: AppTokens.componentSize.divider,
                            color: isDark
                                ? colors.outline.withValues(alpha: AppOpacity.medium)
                                : colors.primary.withValues(alpha: AppOpacity.dim),
                          ),
                        ),
                        DetailRow(
                          icon: Icons.schedule_rounded,
                          label: 'Study time today',
                          value:
                              '${(_timer.todayStudyMinutes / 60).toStringAsFixed(1)}h',
                          accentIcon: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: spacing.xl * spacingScale),

                  // Action buttons - matching class details button layout
                  _buildControls(context, sessionColor, spacingScale),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(
      BuildContext context, Color sessionColor, double spacingScale) {
    final spacing = AppTokens.spacing;

    switch (_timer.state) {
      case TimerState.idle:
        return PrimaryButton(
          label: 'Start Timer',
          icon: Icons.play_arrow_rounded,
          onPressed: _timer.start,
          minHeight: AppTokens.componentSize.buttonMd,
          expanded: true,
        );

      case TimerState.running:
        return Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Stop',
                icon: Icons.stop_rounded,
                onPressed: _timer.stop,
                minHeight: AppTokens.componentSize.buttonMd,
              ),
            ),
            SizedBox(width: spacing.md * spacingScale),
            Expanded(
              child: PrimaryButton(
                label: 'Pause',
                icon: Icons.pause_rounded,
                onPressed: _timer.pause,
                minHeight: AppTokens.componentSize.buttonMd,
              ),
            ),
          ],
        );

      case TimerState.paused:
        return Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Stop',
                icon: Icons.stop_rounded,
                onPressed: _timer.stop,
                minHeight: AppTokens.componentSize.buttonMd,
              ),
            ),
            SizedBox(width: spacing.md * spacingScale),
            Expanded(
              child: PrimaryButton(
                label: 'Resume',
                icon: Icons.play_arrow_rounded,
                onPressed: _timer.resume,
                minHeight: AppTokens.componentSize.buttonMd,
              ),
            ),
          ],
        );

      case TimerState.completed:
        return Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Skip',
                icon: Icons.skip_next_rounded,
                onPressed: _timer.skip,
                minHeight: AppTokens.componentSize.buttonMd,
              ),
            ),
            SizedBox(width: spacing.md * spacingScale),
            Expanded(
              child: PrimaryButton(
                label: 'Continue',
                icon: Icons.play_arrow_rounded,
                onPressed: _timer.start,
                minHeight: AppTokens.componentSize.buttonMd,
              ),
            ),
          ],
        );
    }
  }
}

// Keep old screen for backward compatibility - redirects to modal
class StudyTimerScreen extends StatelessWidget {
  const StudyTimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Show the modal and pop when done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showStudyTimerSheet(context).then((_) {
        if (context.mounted) Navigator.of(context).pop();
      });
    });
    return const SizedBox.shrink();
  }
}
