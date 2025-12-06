import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../services/admin_service.dart';
import '../ui/kit/kit.dart';

import '../ui/theme/tokens.dart';
import 'admin_reports_controller.dart';

class ClassIssueReportsPage extends StatefulWidget {
  const ClassIssueReportsPage({super.key});

  @override
  State<ClassIssueReportsPage> createState() => _ClassIssueReportsPageState();
}

class _ClassIssueReportsPageState extends State<ClassIssueReportsPage> {
  late final AdminReportsController _controller;

  static const List<String> _filters = <String>[
    'all',
    'new',
    'in_review',
    'resolved',
  ];

  static const Map<String, String> _statusLabels = <String, String>{
    'new': 'New',
    'in_review': 'In review',
    'resolved': 'Resolved',
  };

  final DateFormat _timestampFormat = DateFormat('MMM d, yyyy at h:mm a');

  @override
  void initState() {
    super.initState();
    _controller = AdminReportsController();
    _controller.bootstrap();
  }

  void _toast(
    String message,
    {
    AppSnackBarType type = AppSnackBarType.info,
  }
  ) {
    if (!mounted) return;
    showAppSnackBar(context, message, type: type);
  }

  Future<void> _changeStatus(ClassIssueReport report, String status) async {
    if (status == report.status) return;

    String? resolutionNote = report.resolutionNote;

    if (status == 'resolved') {
      final note = await _promptResolutionNote(report);
      if (note == null) return; // User cancelled
      resolutionNote = note;
    }

    final success = await _controller.changeStatus(
      report,
      status,
      resolutionNote: resolutionNote,
    );

    if (success) {
      _toast(
        'Marked as ${_statusLabels[status] ?? status}.',
        type: AppSnackBarType.success,
      );
    } else {
      _toast(
        'Failed to update status. Please try again.',
        type: AppSnackBarType.error,
      );
    }
  }

  Future<String?> _promptResolutionNote(ClassIssueReport report) {
    return AppModal.alert<String>(
      context: context,
      dismissible: false,
      builder: (context) => _ResolutionNoteDialog(
        initialValue: report.resolutionNote,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final media = MediaQuery.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    final backButton = PressableScale(
      onTap: () {
        if (context.canPop()) {
          context.pop();
        }
      },
      child: Container(
        padding: EdgeInsets.all(spacing.sm),
        decoration: BoxDecoration(
          color: colors.onSurface.withValues(alpha: AppOpacity.faint),
          borderRadius: AppTokens.radius.md,
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          size: AppTokens.iconSize.md,
          color: palette.muted,
        ),
      ),
    );

    final hero = ScreenBrandHeader(
      leading: backButton,
      showChevron: false,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.loading &&
            _controller.reports.isEmpty &&
            _controller.error == null) {
          return ScreenShell(
            screenName: 'admin_issue_reports',
            hero: hero,
            sections: [
              const ScreenSection(
                decorated: false,
                child: SkeletonAdminIssueReports(reportCount: 3),
              ),
            ],
            padding: EdgeInsets.fromLTRB(
              spacing.xl,
              media.padding.top + spacing.xxxl,
              spacing.xl,
              spacing.quad + AppLayout.bottomNavSafePadding,
            ),
            onRefresh: _controller.loadReports,
            refreshColor: colors.primary,
            safeArea: false,
          );
        }

        final sections = <Widget>[];

        // Hero card
        sections.add(
          ScreenSection(
            decorated: false,
            child: ValueListenableBuilder<int>(
              valueListenable: _controller.newReportCount,
              builder: (context, count, _) => _buildHeroCard(theme, count),
            ),
          ),
        );

        // Error state
        if (_controller.error != null) {
          sections.add(
            ScreenSection(
              decorated: false,
              child: StateDisplay(
                variant: StateVariant.error,
                title: 'Something went wrong',
                message: _controller.error!,
                primaryActionLabel: 'Retry',
                onPrimaryAction: _controller.loadReports,
                compact: true,
              ),
            ),
          );
        }

        // Filter chips
        sections.add(
          ScreenSection(
            title: 'Status filters',
            subtitle: 'Narrow the list to reports that need your attention.',
            decorated: false,
            child: _buildFilterChips(theme),
          ),
        );

        // Reports section
        if (_controller.error == null) {
          if (_controller.reports.isEmpty) {
            sections.add(
              ScreenSection(
                title: 'Reports',
                subtitle: 'Keep students in sync by reviewing flagged classes here.',
                decorated: false,
                child: StateDisplay(
                  variant: StateVariant.empty,
                  icon: Icons.flag_outlined,
                  title: 'No reports yet',
                  message:
                      'Students haven\'t flagged any synced classes. Check back later.',
                  primaryActionLabel: 'Retry',
                  onPrimaryAction: _controller.loadReports,
                  compact: true,
                ),
              ),
            );
          } else {
            sections.add(
              ScreenSection(
                title: 'Reports',
                subtitle: 'Use the overflow menu to update status or add resolution notes.',
                decorated: false,
                child: Column(
                  children: _controller.reports
                      .map((report) => Padding(
                            padding: EdgeInsets.only(bottom: spacing.lg),
                            child: _buildReportCard(theme, report),
                          ))
                      .toList(),
                ),
              ),
            );
          }
        }

        return ScreenShell(
          screenName: 'admin_issue_reports',
          hero: hero,
          sections: sections,
          padding: EdgeInsets.fromLTRB(
            spacing.xl,
            media.padding.top + spacing.xxxl,
            spacing.xl,
            spacing.quad + AppLayout.bottomNavSafePadding,
          ),
          onRefresh: _controller.loadReports,
          refreshColor: colors.primary,
          safeArea: false,
        );
      },
    );
  }

  Widget _buildHeroCard(ThemeData theme, int newCount) {
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final bool isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final Color background = isDark
        ? colors.primary.withValues(alpha: AppOpacity.border)
        : Color.alphaBlend(
            colors.primary.withValues(alpha: AppOpacity.overlay),
            colors.surface,
          );

    final badgeText = newCount == 0
        ? 'All caught up'
        : '$newCount new report${newCount == 1 ? '' : 's'}';

    return Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? colors.outline.withValues(alpha: AppOpacity.overlay)
              : colors.outline,
          width: theme.brightness == Brightness.dark
              ? AppTokens.componentSize.divider
              : AppTokens.componentSize.dividerThin,
        ),
        boxShadow: theme.brightness == Brightness.dark
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
          Container(
            height: AppTokens.componentSize.listItemSm,
            width: AppTokens.componentSize.listItemSm,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: isDark ? AppOpacity.fieldBorder : AppOpacity.border),
              borderRadius: AppTokens.radius.lg,
            ),
            child: Icon(
              Icons.flag_rounded,
              color: colors.primary,
              size: AppTokens.iconSize.xl,
            ),
          ),
          SizedBox(height: spacing.lg),
          Text(
            'Class issue reports',
            style: AppTokens.typography.title.copyWith(
              color: colors.onSurface,
              fontSize: AppTokens.typography.headline.fontSize,
              fontWeight: AppTokens.fontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            'Track what students are flagging and keep every synced class accurate.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.muted,
            ),
          ),
          SizedBox(height: spacing.lg),
          Container(
            padding: spacing.edgeInsetsSymmetric(
              horizontal: spacing.smMd,
              vertical: spacing.xsPlus,
            ),
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: isDark ? AppOpacity.border : AppOpacity.highlight),
              borderRadius: AppTokens.radius.md,
            ),
            child: Text(
              badgeText,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: AppTokens.fontWeight.semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        expandedInsets: EdgeInsets.zero,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            spacing.edgeInsetsSymmetric(
              horizontal: spacing.md,
              vertical: spacing.md,
            ),
          ),
          side: WidgetStateProperty.resolveWith(
            (states) => BorderSide(
              color: states.contains(WidgetState.selected)
                  ? colors.primary
                  : colors.outline.withValues(alpha: AppOpacity.barrier),
              width: AppTokens.componentSize.dividerMedium,
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? colors.primary.withValues(alpha: AppOpacity.statusBg)
                : colors.surfaceContainerHighest
                    .withValues(alpha: AppOpacity.barrier),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? colors.primary
                : palette.muted
                    .withValues(alpha: AppOpacity.prominent),
          ),
        ),
        segments: _filters.map((value) {
          return ButtonSegment<String>(
            value: value,
            label: Text(
              _filterLabel(value),
              softWrap: false,
            ),
          );
        }).toList(),
        selected: <String>{_controller.filter},
        onSelectionChanged: (value) {
          if (value.isNotEmpty) _controller.setFilter(value.first);
        },
      ),
    );
  }

  Widget _buildReportCard(ThemeData theme, ClassIssueReport report) {
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    final String statusLabel = _statusLabels[report.status] ?? report.status;
    final Color statusColor = _statusColor(report.status, colors);
    final String? scheduleLabel = _scheduleLabel(report);
    final String reporterLabel = _reporterLabel(report);
    final String timestampLabel =
        _timestampFormat.format(report.createdAt.toLocal());

    final List<Widget> metadataChips = <Widget>[];
    if (report.code != null && report.code!.isNotEmpty) {
      metadataChips.add(
        _infoChip(theme, Icons.confirmation_number_outlined, report.code!),
      );
    }
    final String? sectionLabel = _sectionLabel(report);
    if (sectionLabel != null && sectionLabel.isNotEmpty) {
      metadataChips.add(
        _infoChip(theme, Icons.view_agenda_outlined, sectionLabel),
      );
    }
    if (report.room != null && report.room!.isNotEmpty) {
      metadataChips.add(
        _infoChip(theme, Icons.location_on_outlined, report.room!),
      );
    }
    if (report.instructorName != null && report.instructorName!.isNotEmpty) {
      metadataChips.add(
        _infoChip(theme, Icons.person_outline, report.instructorName!),
      );
    }

    return Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colors.surfaceContainerHigh
            : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? colors.outline.withValues(alpha: AppOpacity.overlay)
              : colors.outline,
          width: theme.brightness == Brightness.dark
              ? AppTokens.componentSize.divider
              : AppTokens.componentSize.dividerThin,
        ),
        boxShadow: theme.brightness == Brightness.dark
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title ?? 'Class #${report.classId}',
                      style: AppTokens.typography.subtitle.copyWith(
                        color: colors.onSurface,
                        fontWeight: AppTokens.fontWeight.bold,
                        fontSize: AppTokens.typography.subtitle.fontSize,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Container(
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: AppOpacity.medium),
                        borderRadius: AppTokens.radius.md,
                        border: Border.all(
                          color: statusColor.withValues(alpha: AppOpacity.divider),
                        ),
                      ),
                      padding: AppTokens.spacing.edgeInsetsSymmetric(
                        horizontal: AppTokens.spacing.smMd,
                        vertical: AppTokens.spacing.xsPlus,
                      ),
                      child: Text(
                        statusLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: statusColor,
                          fontWeight: AppTokens.fontWeight.semiBold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: (value) => _changeStatus(report, value),
                itemBuilder: (context) => _filters
                    .where((status) => status != 'all')
                    .map(
                      (status) => PopupMenuItem<String>(
                        enabled: status != report.status,
                        value: status,
                        child: Text(_statusLabels[status] ?? status),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          if (scheduleLabel != null) ...[
            SizedBox(height: spacing.md),
            Text(
              scheduleLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.muted,
                fontWeight: AppTokens.fontWeight.semiBold,
              ),
            ),
          ],
          if (metadataChips.isNotEmpty) ...[
            SizedBox(height: spacing.md),
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: metadataChips,
            ),
          ],
          if (report.note != null && report.note!.trim().isNotEmpty) ...[
            SizedBox(height: spacing.lg),
            Text(
              'Reporter note',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: AppTokens.fontWeight.semiBold,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              report.note!.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.muted,
              ),
            ),
          ],
          if (report.resolutionNote != null &&
              report.resolutionNote!.trim().isNotEmpty) ...[
            SizedBox(height: spacing.lg),
            Text(
              'Resolution note',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: AppTokens.fontWeight.semiBold,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              report.resolutionNote!.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.muted,
                fontWeight: AppTokens.fontWeight.semiBold,
              ),
            ),
          ],
          SizedBox(height: spacing.lg),
          Text(
            '$reporterLabel | $timestampLabel',
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(ThemeData theme, IconData icon, String label) {
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.smMd,
        vertical: spacing.xsPlus,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: AppOpacity.track),
        borderRadius: AppTokens.radius.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTokens.iconSize.sm, color: palette.muted),
          SizedBox(width: AppTokens.spacing.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: palette.muted,
              fontWeight: AppTokens.fontWeight.semiBold,
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(String value) {
    if (value == 'all') return 'All';
    return _statusLabels[value] ?? value;
  }

  Color _statusColor(String status, ColorScheme colors) {
    switch (status) {
      case 'in_review':
        return AppTokens.lightColors.warning;
      case 'resolved':
        return AppTokens.lightColors.positive;
      case 'new':
      default:
        return AppTokens.lightColors.info;
    }
  }

  String? _scheduleLabel(ClassIssueReport report) {
    final String? start = _formatTime(report.start);
    final String? end = _formatTime(report.end);
    final String? dayName = _weekdayName(report.day);

    if (start == null && end == null) return dayName;
    final String range = [
      if (start != null) start,
      if (end != null) end,
    ].join(' - ');
    if (dayName == null) return range.isEmpty ? null : range;
    if (range.isEmpty) return dayName;
    return '$dayName | $range';
  }

  String? _sectionLabel(ClassIssueReport report) {
    final List<String> parts = <String>[];
    if (report.sectionCode != null && report.sectionCode!.isNotEmpty) {
      parts.add(report.sectionCode!);
    }
    if (report.sectionNumber != null && report.sectionNumber!.isNotEmpty) {
      parts.add('Section ${report.sectionNumber!}');
    }
    return parts.isEmpty ? null : parts.join(' | ');
  }

  String _reporterLabel(ClassIssueReport report) {
    final String? name = report.reporterName?.trim();
    final String? email = report.reporterEmail?.trim();
    if (name != null && name.isNotEmpty && email != null && email.isNotEmpty) {
      return '$name | $email';
    }
    if (name != null && name.isNotEmpty) return name;
    if (email != null && email.isNotEmpty) return email;
    final String id = report.userId;
    final String short = id.length > 8 ? id.substring(0, 8) : id;
    return 'User $short';
  }

  String? _weekdayName(int? day) {
    if (day == null) return null;
    const List<String> names = <String>[
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    if (day >= 1 && day <= 7) return names[day];
    return null;
  }

  String? _formatTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    final int hour = int.tryParse(parts.first) ?? 0;
    final int minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final DateTime time = DateTime(0, 1, 1, hour, minute);
    return DateFormat('h:mm a').format(time);
  }
}

class _ResolutionNoteDialog extends StatefulWidget {
  const _ResolutionNoteDialog({this.initialValue});

  final String? initialValue;

  @override
  State<_ResolutionNoteDialog> createState() => _ResolutionNoteDialogState();
}

class _ResolutionNoteDialogState extends State<_ResolutionNoteDialog> {
  late final TextEditingController _controller;
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      setState(() => _showValidation = true);
      return;
    }
    Navigator.of(context).pop(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    return AlertDialog(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sheet),
      titlePadding: spacing.edgeInsetsOnly(
        left: spacing.xl,
        right: spacing.xl,
        top: spacing.xl,
        bottom: spacing.sm,
      ),
      contentPadding: spacing.edgeInsetsOnly(
        left: spacing.xl,
        right: spacing.xl,
        bottom: spacing.lg,
      ),
      actionsPadding: spacing.edgeInsetsAll(spacing.lg),
      title: Text(
        'Add a resolution note',
        style: AppTokens.typography.title.copyWith(
          fontWeight: AppTokens.fontWeight.bold,
          color: colors.onSurface,
        ),
      ),
      content: SizedBox(
        width: AppTokens.componentSize.alarmPreviewMinWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Let other admins know what you changed so everyone stays informed.',
              style: AppTokens.typography.body.copyWith(
                color: palette.muted,
              ),
            ),
            SizedBox(height: spacing.lg),
            TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 6,
              autofocus: true,
              onChanged: (_) {
                if (_showValidation && _controller.text.trim().isNotEmpty) {
                  setState(() => _showValidation = false);
                }
              },
              decoration: InputDecoration(
                hintText:
                    'Example: Updated instructor to Prof. Cruz and corrected time slot.',
                filled: true,
                fillColor: colors.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle),
                border: OutlineInputBorder(
                  borderRadius: AppTokens.radius.md,
                  borderSide: BorderSide(color: colors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppTokens.radius.md,
                  borderSide: BorderSide(color: colors.outline.withValues(alpha: AppOpacity.subtle)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppTokens.radius.md,
                  borderSide: BorderSide(color: colors.primary, width: AppTokens.componentSize.dividerThick),
                ),
                contentPadding: spacing.edgeInsetsAll(spacing.md),
                errorText: _showValidation
                    ? 'Please add a short summary before resolving.'
                    : null,
              ),
            ),
          ],
        ),
      ),
      actions: [
        SecondaryButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(null),
          minHeight: AppTokens.componentSize.buttonSm,
          expanded: false,
        ),
        PrimaryButton(
          label: 'Save note',
          onPressed: _handleSave,
          minHeight: AppTokens.componentSize.buttonSm,
          expanded: false,
        ),
      ],
    );
  }
}
