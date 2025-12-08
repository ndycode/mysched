import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';
import 'admin_reports_controller.dart';

/// Filter options for issue reports.
enum ReportFilter {
  all('All'),
  pending('Pending'),
  resolved('Resolved'),
  ignored('Ignored');

  const ReportFilter(this.label);
  final String label;
}

class IssueReportsScreen extends StatefulWidget {
  const IssueReportsScreen({super.key});

  @override
  State<IssueReportsScreen> createState() => _IssueReportsScreenState();
}

class _IssueReportsScreenState extends State<IssueReportsScreen> {
  late final AdminReportsController _controller;
  ReportFilter _currentFilter = ReportFilter.all;

  @override
  void initState() {
    super.initState();
    _controller = AdminReportsController();
    _loadReports();
  }

  Future<void> _loadReports() async {
    await _controller.bootstrap();
  }

  void _setFilter(ReportFilter filter) {
    setState(() => _currentFilter = filter);
    _controller.setFilter(filter.name);
  }

  Future<void> _updateStatus(ClassIssueReport report, String newStatus) async {
    final success = await _controller.changeStatus(report, newStatus);
    if (success && mounted) {
      showAppSnackBar(
        context,
        'Report marked as $newStatus',
        type: AppSnackBarType.success,
      );
    } else if (mounted) {
      showAppSnackBar(
        context,
        'Failed to update status',
        type: AppSnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final media = MediaQuery.of(context);

    final heroContent = ScreenBrandHeader(
      leading: const NavBackButton(),
      showChevron: false,
    );

    final shellPadding = EdgeInsets.fromLTRB(
      spacing.xl,
      media.padding.top + spacing.xxxl,
      spacing.xl,
      spacing.quad + AppLayout.bottomNavSafePadding,
    );

    return ScreenShell(
      screenName: 'issue_reports',
      hero: heroContent,
      sections: [
        // Summary card
        ScreenSection(
          decorated: false,
          child: _buildSummaryCard(colors, isDark, palette),
        ),
        // Filter pills
        ScreenSection(
          decorated: false,
          child: SegmentedPills<ReportFilter>(
            value: _currentFilter,
            options: ReportFilter.values,
            onChanged: _setFilter,
            labelBuilder: (option) => option.label,
          ),
        ),
        // Reports list
        ScreenSection(
          decorated: false,
          child: _buildReportsList(colors, isDark, palette),
        ),
      ],
      padding: shellPadding,
      safeArea: false,
      onRefresh: _loadReports,
      refreshColor: colors.primary,
    );
  }

  Widget _buildSummaryCard(
      ColorScheme colors, bool isDark, ColorPalette palette) {
    final spacing = AppTokens.spacing;

    return CardX(
      variant: CardVariant.elevated,
      padding: spacing.edgeInsetsAll(spacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: AppTokens.componentSize.avatarXl,
                width: AppTokens.componentSize.avatarXl,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary.withValues(alpha: AppOpacity.medium),
                      colors.primary.withValues(alpha: AppOpacity.dim),
                    ],
                  ),
                  borderRadius: AppTokens.radius.md,
                  border: Border.all(
                    color: colors.primary
                        .withValues(alpha: AppOpacity.borderEmphasis),
                    width: AppTokens.componentSize.dividerThick,
                  ),
                ),
                child: Icon(
                  Icons.report_problem_outlined,
                  color: colors.primary,
                  size: AppTokens.iconSize.xl,
                ),
              ),
              SizedBox(width: spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Issue Reports',
                      style: AppTokens.typography.title.copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                        letterSpacing: AppLetterSpacing.snug,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      'Manage user-reported schedule issues',
                      style: AppTokens.typography.bodySecondary.copyWith(
                        color: palette.muted,
                        fontWeight: AppTokens.fontWeight.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(
      ColorScheme colors, bool isDark, ColorPalette palette) {
    final spacing = AppTokens.spacing;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.loading) {
          return const Center(
            child: SkeletonListCard(itemCount: 3, showFilterChips: false),
          );
        }

        if (_controller.reports.isEmpty) {
          return CardX(
            variant: CardVariant.elevated,
            padding: spacing.edgeInsetsAll(spacing.xxl),
            child: EmptyHeroPlaceholder(
              icon: Icons.inbox_outlined,
              title: 'No reports found',
              subtitle: 'All caught up! No issues to review.',
            ),
          );
        }

        return CardX(
          variant: CardVariant.elevated,
          padding: spacing.edgeInsetsAll(spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pending review',
                style: AppTokens.typography.subtitle.copyWith(
                  fontWeight: AppTokens.fontWeight.semiBold,
                  color: colors.onSurface,
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                'Review and manage reported issues below.',
                style: AppTokens.typography.bodySecondary.copyWith(
                  color: palette.muted,
                ),
              ),
              SizedBox(height: spacing.lg),
              ...List.generate(_controller.reports.length, (index) {
                final report = _controller.reports[index];
                return Column(
                  children: [
                    _ReportTile(
                      report: report,
                      onUpdateStatus: _updateStatus,
                    ),
                    if (index < _controller.reports.length - 1)
                      SizedBox(height: spacing.md),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.report,
    required this.onUpdateStatus,
  });

  final ClassIssueReport report;
  final Function(ClassIssueReport, String) onUpdateStatus;

  StatusBadgeVariant _getStatusVariant(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return StatusBadgeVariant.overdue;
      case 'resolved':
        return StatusBadgeVariant.done;
      case 'ignored':
        return StatusBadgeVariant.disabled;
      default:
        return StatusBadgeVariant.next;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    final statusVariant = _getStatusVariant(report.status);
    final dateLabel = DateFormat.yMMMd().add_jm().format(report.createdAt);

    return Container(
      padding: spacing.edgeInsetsAll(spacing.lg),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: colors.outline.withValues(alpha: AppOpacity.overlay),
          width: AppTokens.componentSize.dividerThin,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: AppOpacity.faint),
                  blurRadius: AppTokens.shadow.sm,
                  offset: AppShadowOffset.xs,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(
                label: report.status.toUpperCase(),
                variant: statusVariant,
              ),
              Text(
                dateLabel,
                style: AppTokens.typography.caption.copyWith(
                  color: palette.muted,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),

          // Class info
          Text(
            'Class ID: ${report.classId}',
            style: AppTokens.typography.subtitle.copyWith(
              fontWeight: AppTokens.fontWeight.bold,
              letterSpacing: AppLetterSpacing.compact,
              color: colors.onSurface,
            ),
          ),

          if (report.title != null) ...[
            SizedBox(height: spacing.xs),
            Text(
              report.title!,
              style: AppTokens.typography.body.copyWith(
                color: colors.onSurface,
              ),
            ),
          ],

          if (report.note != null) ...[
            SizedBox(height: spacing.xs),
            Text(
              'Note: ${report.note!}',
              style: AppTokens.typography.bodySecondary.copyWith(
                color: palette.muted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          SizedBox(height: spacing.lg),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (report.status != 'resolved')
                TertiaryButton(
                  label: 'Resolve',
                  icon: Icons.check_rounded,
                  onPressed: () => onUpdateStatus(report, 'resolved'),
                  expanded: false,
                ),
              if (report.status != 'resolved' && report.status != 'ignored')
                SizedBox(width: spacing.sm),
              if (report.status != 'ignored')
                TertiaryButton(
                  label: 'Ignore',
                  icon: Icons.close_rounded,
                  onPressed: () => onUpdateStatus(report, 'ignored'),
                  expanded: false,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
