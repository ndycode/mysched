import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/admin_service.dart';
import '../services/telemetry_service.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';

class ClassIssueReportsPage extends StatefulWidget {
  const ClassIssueReportsPage({super.key});

  @override
  State<ClassIssueReportsPage> createState() => _ClassIssueReportsPageState();
}

class _ClassIssueReportsPageState extends State<ClassIssueReportsPage> {
  final AdminService _adminService = AdminService.instance;

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

  bool _loading = true;
  String? _error;
  String _filter = 'all';
  List<ClassIssueReport> _reports = const <ClassIssueReport>[];

  void _toast(
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    if (!mounted) return;
    showAppSnackBar(context, message, type: type);
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await _adminService.refreshRole();
      if (!mounted) return;
      if (_adminService.role.value != AdminRoleState.admin) {
        setState(() {
          _loading = false;
          _error = 'Admin access is required to view these reports.';
        });
        return;
      }
      await _loadReports();
    } catch (error, stack) {
      TelemetryService.instance.logError(
        'admin_reports_bootstrap_failed',
        error: error,
        stack: stack,
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to verify admin access right now.';
      });
    }
  }

  Future<void> _loadReports() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _adminService.fetchReports(status: _filter);
      if (!mounted) return;
      setState(() {
        _reports = data;
      });
      await _adminService.refreshNewReportCount();
    } catch (error, stack) {
      TelemetryService.instance.logError(
        'admin_reports_fetch_failed',
        error: error,
        stack: stack,
        data: {'filter': _filter},
      );
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load reports. Pull to refresh or try again later.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _changeStatus(ClassIssueReport report, String status) async {
    if (status == report.status) return;

    String? resolutionNote = report.resolutionNote;
    bool clearResolutionNote = false;

    if (status == 'resolved') {
      final note = await _promptResolutionNote(report);
      if (note == null) return;
      resolutionNote = note.trim();
    } else if (report.resolutionNote != null &&
        report.resolutionNote!.trim().isNotEmpty) {
      clearResolutionNote = true;
      resolutionNote = null;
    }

    final previousStatus = report.status;
    final previousNote = report.resolutionNote;

    setState(() {
      _reports = _reports.map((entry) {
        if (entry.id != report.id) return entry;
        return entry.copyWith(
          status: status,
          resolutionNote: status == 'resolved'
              ? resolutionNote
              : (clearResolutionNote ? null : entry.resolutionNote),
        );
      }).toList();
    });

    try {
      await _adminService.updateReportStatus(
        report: report,
        status: status,
        resolutionNote: status == 'resolved' ? resolutionNote : null,
        clearResolutionNote: clearResolutionNote,
      );
      if (!mounted) return;
      if (_filter != 'all' && status != _filter) {
        setState(() {
          _reports = _reports.where((entry) => entry.id != report.id).toList();
        });
      }
      _toast(
        'Marked as ${_statusLabels[status] ?? status}.',
        type: AppSnackBarType.success,
      );
    } catch (error, stack) {
      TelemetryService.instance.logError(
        'admin_report_status_failed',
        error: error,
        stack: stack,
        data: {'report_id': report.id, 'status': status},
      );
      if (!mounted) return;
      setState(() {
        _reports = _reports.map((entry) {
          if (entry.id != report.id) return entry;
          return entry.copyWith(
            status: previousStatus,
            resolutionNote: previousNote,
          );
        }).toList();
      });
      _toast(
        'Failed to update status. Please try again.',
        type: AppSnackBarType.error,
      );
    }
  }

  Future<String?> _promptResolutionNote(ClassIssueReport report) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ResolutionNoteDialog(
        initialValue: report.resolutionNote,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final topInset = MediaQuery.of(context).padding.top;

    final headerStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontFamily: 'SFProRounded',
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
          fontSize: 20,
        );

    final listChildren = <Widget>[
      BrandHeader(
        title: 'MySched',
        showChevron: false,
        height: 48,
        avatarRadius: 20,
        textStyle: headerStyle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      SizedBox(height: spacing.lg),
      ..._buildPageContent(context),
    ];

    return AppScaffold(
      screenName: 'admin_issue_reports',
      safeArea: false,
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: _loadReports,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              topInset + spacing.xxl,
              20,
              spacing.xxl,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            children: listChildren,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageContent(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = AppTokens.spacing;

    return [
      ValueListenableBuilder<int>(
        valueListenable: _adminService.newReportCount,
        builder: (context, count, _) => _buildHeroCard(theme, count),
      ),
      Section(
        title: 'Status filters',
        subtitle: 'Narrow the list to reports that need your attention.',
        children: [
          _buildFilterChips(theme),
        ],
      ),
      Section(
        title: 'Reports',
        subtitle: _reports.isEmpty
            ? 'Keep students in sync by reviewing flagged classes here.'
            : 'Use the overflow menu to update status or add resolution notes.',
        spacing: spacing.lg,
        children: _buildReportSection(theme),
      ),
    ];
  }

  Widget _buildHeroCard(ThemeData theme, int newCount) {
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color background = isDark
        ? colors.primary.withValues(alpha: 0.18)
        : Color.alphaBlend(
            colors.primary.withValues(alpha: 0.12),
            colors.surface,
          );

    final badgeText = newCount == 0
        ? 'All caught up'
        : '$newCount new report${newCount == 1 ? '' : 's'}';

    return CardX(
      backgroundColor: background,
      borderColor: Colors.transparent,
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: isDark ? 0.32 : 0.18),
              borderRadius: AppTokens.radius.lg,
            ),
            child: Icon(
              Icons.flag_rounded,
              color: colors.primary,
              size: 28,
            ),
          ),
          SizedBox(height: spacing.lg),
          Text(
            'Class issue reports',
            style: AppTokens.typography.title.copyWith(
              color: colors.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            'Track what students are flagging and keep every synced class accurate.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: isDark ? 0.18 : 0.08),
              borderRadius: AppTokens.radius.md,
            ),
            child: Text(
              badgeText,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildReportSection(ThemeData theme) {
    final spacing = AppTokens.spacing;

    if (_loading && _reports.isEmpty && _error == null) {
      return [
        CardX(
          borderColor: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.lg),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ];
    }

    if (_error != null) {
      return [
        ErrorState(
          title: 'Something went wrong',
          message: _error!,
          onRetry: _loadReports,
        ),
      ];
    }

    if (_reports.isEmpty) {
      return [
        EmptyState(
          icon: Icons.flag_outlined,
          title: 'No reports yet',
          message:
              'Students haven\'t flagged any synced classes. Check back later.',
        ),
      ];
    }

    return _reports.map((report) => _buildReportCard(theme, report)).toList();
  }

  Widget _buildFilterChips(ThemeData theme) {
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final chips = <Widget>[];

    for (final value in _filters) {
      final bool selected = _filter == value;
      chips.add(
        ChoiceChip(
          label: Text(_filterLabel(value)),
          selected: selected,
          onSelected: (bool active) {
            if (!active || value == _filter) return;
            setState(() => _filter = value);
            _loadReports();
          },
          selectedColor: colors.primary.withValues(alpha: 0.16),
          backgroundColor: colors.surface,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? colors.primary : colors.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      );
    }

    return CardX(
      borderColor: Colors.transparent,
      padding: spacing.edgeInsetsAll(spacing.md),
      backgroundColor: theme.brightness == Brightness.dark
          ? colors.surfaceContainerHigh
          : colors.surfaceContainerHighest,
      child: Wrap(
        spacing: spacing.sm,
        runSpacing: spacing.sm,
        children: chips,
      ),
    );
  }

  Widget _buildReportCard(ThemeData theme, ClassIssueReport report) {
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

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

    return CardX(
      padding: spacing.edgeInsetsAll(spacing.xl),
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
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Container(
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: AppTokens.radius.md,
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.4),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        statusLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
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
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (metadataChips.isNotEmpty) ...[
            SizedBox(height: spacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: metadataChips,
            ),
          ],
          if (report.note != null && report.note!.trim().isNotEmpty) ...[
            SizedBox(height: spacing.lg),
            Text(
              'Reporter note',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              report.note!.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
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
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              report.resolutionNote!.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          SizedBox(height: spacing.lg),
          Text(
            '$reporterLabel | $timestampLabel',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(ThemeData theme, IconData icon, String label) {
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: AppTokens.radius.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
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

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xl),
      contentPadding: spacing.edgeInsetsAll(spacing.xxl),
      actionsPadding: EdgeInsets.fromLTRB(
        spacing.xxl,
        spacing.md,
        spacing.xxl,
        spacing.md,
      ),
      title: const Text('Add a resolution note'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Let other admins know what you changed so everyone stays informed.',
            ),
            SizedBox(height: spacing.md),
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
                border: const OutlineInputBorder(),
                errorText: _showValidation
                    ? 'Please add a short summary before resolving.'
                    : null,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          style: TextButton.styleFrom(
            foregroundColor: colors.onSurfaceVariant,
          ),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _handleSave,
          child: const Text('Save note'),
        ),
      ],
    );
  }
}
