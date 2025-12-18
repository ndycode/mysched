import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/stats_service.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';

/// Shows the stats as a modal sheet.
Future<void> showStatsSheet(BuildContext context) {
  return AppModal.sheet(
    context: context,
    builder: (context) => const StatsSheet(),
  );
}

/// Statistics dashboard modal sheet matching ClassDetailsSheet design.
class StatsSheet extends StatefulWidget {
  const StatsSheet({super.key});

  @override
  State<StatsSheet> createState() => _StatsSheetState();
}

class _StatsSheetState extends State<StatsSheet> {
  @override
  void initState() {
    super.initState();
    StatsService.instance.addListener(_onStatsChanged);
    StatsService.instance.refresh();
  }

  @override
  void dispose() {
    StatsService.instance.removeListener(_onStatsChanged);
    super.dispose();
  }

  void _onStatsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    final stats = StatsService.instance.stats;

    return DetailShell(
      useBubbleShadow: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header - identical to class details
          SheetHeaderRow(
            title: 'Study Statistics',
            subtitle: 'Track your progress',
            icon: Icons.bar_chart_rounded,
            onClose: () => Navigator.of(context).pop(),
          ),

          SizedBox(height: spacing.xl * spacingScale),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status badges - same as class details
                  if (stats.currentStreak > 0 || stats.todayMinutes > 0)
                    Wrap(
                      spacing: spacing.sm * spacingScale,
                      runSpacing: spacing.sm * spacingScale,
                      children: [
                        if (stats.currentStreak > 0)
                          StatusInfoChip(
                            icon: Icons.local_fire_department_rounded,
                            label: '${stats.currentStreak} day streak',
                            color: Colors.orange,
                          ),
                        if (stats.todayMinutes > 0)
                          StatusInfoChip(
                            icon: Icons.check_circle_outline_rounded,
                            label: 'Active today',
                            color: colors.primary,
                          ),
                      ],
                    ),

                  if (stats.currentStreak > 0 || stats.todayMinutes > 0)
                    SizedBox(height: spacing.lg * spacingScale),

                  // Main stats container - matching class details info section
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
                        DetailRow(
                          icon: Icons.today_rounded,
                          label: 'Today',
                          value: StudyStats.formatMinutes(stats.todayMinutes),
                          accentIcon: true,
                        ),
                        _buildDivider(context, spacingScale),
                        DetailRow(
                          icon: Icons.date_range_rounded,
                          label: 'This Week',
                          value: StudyStats.formatMinutes(stats.weekMinutes),
                          accentIcon: true,
                        ),
                        _buildDivider(context, spacingScale),
                        DetailRow(
                          icon: Icons.calendar_month_rounded,
                          label: 'This Month',
                          value: StudyStats.formatMinutes(stats.monthMinutes),
                          accentIcon: true,
                        ),
                        _buildDivider(context, spacingScale),
                        DetailRow(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Total Sessions',
                          value: '${stats.totalSessions}',
                          accentIcon: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: spacing.lg * spacingScale),

                  // Weekly chart container
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last 7 Days',
                          style: AppTokens.typography.captionScaled(scale).copyWith(
                            color: isDark
                                ? AppTokens.darkColors.muted
                                : AppTokens.lightColors.muted,
                            fontWeight: AppTokens.fontWeight.semiBold,
                          ),
                        ),
                        SizedBox(height: spacing.lg * spacingScale),
                        _WeeklyChart(dailyData: stats.dailyData),
                      ],
                    ),
                  ),

                  SizedBox(height: spacing.lg * spacingScale),

                  // Streaks container - matching class details info section
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
                          icon: Icons.local_fire_department_rounded,
                          label: 'Current Streak',
                          value:
                              '${stats.currentStreak} day${stats.currentStreak == 1 ? '' : 's'}',
                          accentIcon: true,
                        ),
                        _buildDivider(context, spacingScale),
                        DetailRow(
                          icon: Icons.emoji_events_rounded,
                          label: 'Best Streak',
                          value:
                              '${stats.longestStreak} day${stats.longestStreak == 1 ? '' : 's'}',
                          accentIcon: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: spacing.lg * spacingScale),

                  // Study tip - like helper text in class details
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
                    child: DetailRow(
                      icon: Icons.lightbulb_outline_rounded,
                      label: 'Study Tip',
                      value: _getStudyTip(stats),
                      accentIcon: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context, double spacingScale) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.lg * spacingScale),
      child: Divider(
        height: AppTokens.componentSize.divider,
        color: isDark
            ? colors.outline.withValues(alpha: AppOpacity.medium)
            : colors.primary.withValues(alpha: AppOpacity.dim),
      ),
    );
  }

  String _getStudyTip(StudyStats stats) {
    if (stats.todayMinutes == 0) {
      return 'Start your first study session today to build your streak!';
    } else if (stats.currentStreak >= 3) {
      return 'Great streak! Keep it up to build lasting study habits.';
    } else if (stats.todayMinutes < 25) {
      return 'Try completing a full 25-minute focus session for better retention.';
    } else {
      return 'Excellent progress! Consistent daily study builds long-term knowledge.';
    }
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.dailyData});

  final List<DailyStudyData> dailyData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    // Find max for scaling
    final maxMinutes = dailyData.isEmpty
        ? 60
        : dailyData.map((d) => d.minutes).reduce((a, b) => a > b ? a : b).clamp(30, 300);

    return SizedBox(
      height: 80 * scale,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: dailyData.map((data) {
          final height = maxMinutes > 0 ? (data.minutes / maxMinutes) * 60 * scale : 0.0;
          final isToday = data.date.day == DateTime.now().day;

          return Expanded(
            child: Padding(
              padding:
                  spacing.edgeInsetsSymmetric(horizontal: spacing.xs * spacingScale),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Bar
                  Container(
                    width: double.infinity,
                    height: height.clamp(4.0, 60 * scale),
                    decoration: BoxDecoration(
                      color: isToday
                          ? colors.primary
                          : data.hasStudied
                              ? colors.primary.withValues(alpha: AppOpacity.dim)
                              : colors.outline.withValues(alpha: AppOpacity.faint),
                      borderRadius: AppTokens.radius.sm,
                    ),
                  ),
                  SizedBox(height: spacing.xs * spacingScale),
                  // Day label
                  Text(
                    DateFormat('E').format(data.date).substring(0, 1),
                    style: AppTokens.typography.captionScaled(scale).copyWith(
                      fontWeight: isToday
                          ? AppTokens.fontWeight.bold
                          : AppTokens.fontWeight.regular,
                      color: isToday
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Keep old screen for backward compatibility - redirects to modal
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Show the modal and pop when done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showStatsSheet(context).then((_) {
        if (context.mounted) Navigator.of(context).pop();
      });
    });
    return const SizedBox.shrink();
  }
}
