import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/schedule_api.dart' as sched;
import '../../widgets/instructor_avatar.dart';
import '../../services/telemetry_service.dart';
import '../theme/card_styles.dart';
import '../kit/kit.dart';
import '../theme/tokens.dart';

class ClassDetailsSheet extends StatefulWidget {
  const ClassDetailsSheet({
    super.key,
    required this.api,
    required this.item,
    this.initial,
    this.onLoaded,
    this.onEditCustom,
    this.onDeleteCustom,
    this.onDetailsChanged,
  });

  final sched.ScheduleApi api;
  final sched.ClassItem item;
  final sched.ClassDetails? initial;
  final ValueChanged<sched.ClassDetails>? onLoaded;
  final Future<void> Function(sched.ClassDetails details)? onEditCustom;
  final Future<void> Function(sched.ClassDetails details)? onDeleteCustom;
  final void Function(sched.ClassDetails details)? onDetailsChanged;

  @override
  State<ClassDetailsSheet> createState() => _ClassDetailsSheetState();
}

class _ClassDetailsSheetState extends State<ClassDetailsSheet> {
  late Future<sched.ClassDetails> _future;
  bool _toggleBusy = false;
  bool _deleteBusy = false;
  bool _reportBusy = false;

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
    if (widget.initial != null) {
      _future = Future<sched.ClassDetails>.value(widget.initial!);
      _refreshDetails();
    } else {
      _future = _loadDetails();
    }
  }

  void _refreshDetails() {
    _loadDetails().then((details) {
      if (!mounted) return;
      setState(() {
        _future = Future<sched.ClassDetails>.value(details);
      });
    }).catchError((_) {
      // Ignore refresh errors; cached value already shown.
    });
  }

  Future<sched.ClassDetails> _loadDetails() async {
    final details = await widget.api.fetchClassDetails(widget.item);
    widget.onLoaded?.call(details);
    return details;
  }

  Future<void> _toggleEnabled(sched.ClassDetails details) async {
    if (_toggleBusy) return;
    setState(() => _toggleBusy = true);
    final enable = !details.enabled;
    try {
      if (details.isCustom) {
        await widget.api.setCustomClassEnabled(details.id, enable);
      } else {
        await widget.api.setClassEnabled(
          widget.item.copyWith(enabled: enable),
          enable,
        );
      }
      final updated = details.copyWith(enabled: enable);
      widget.onLoaded?.call(updated);
      widget.onDetailsChanged?.call(updated);
      if (mounted) {
        setState(() {
          _future = Future<sched.ClassDetails>.value(updated);
        });
      }
      _toast(
        enable ? 'Class enabled.' : 'Class disabled.',
        type: AppSnackBarType.success,
      );
    } catch (error) {
      _toast(
        'Failed to update class: $error',
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _toggleBusy = false);
      }
    }
  }

  Future<void> _editCustom(sched.ClassDetails details) async {
    final callback = widget.onEditCustom;
    if (callback == null || !details.isCustom) return;
    final navigator = Navigator.of(context);
    navigator.pop();
    await callback(details);
  }

  Future<void> _deleteCustom(sched.ClassDetails details) async {
    if (!details.isCustom || _deleteBusy) return;
    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete custom class?'),
            content: const Text(
              'This class will be removed from your schedules and reminders.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirm) return;
    if (!mounted) return;
    setState(() => _deleteBusy = true);
    try {
      await widget.api.deleteCustomClass(details.id);
      await widget.onDeleteCustom?.call(details);
      _toast(
        'Custom class deleted.',
        type: AppSnackBarType.success,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      _toast(
        'Failed to delete class: $error',
        type: AppSnackBarType.error,
      );
      if (mounted) {
        setState(() => _deleteBusy = false);
      }
    }
  }

  Future<void> _reportLinkedIssue(sched.ClassDetails details) async {
    if (_reportBusy) return;

    final controller = TextEditingController();
    final submittedNote = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final trimmed = controller.text.trim();
            final canSubmit = trimmed.length >= 8;
            return AlertDialog(
              title: const Text('Report a schedule issue'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tell us what looks wrong so an administrator can review it.',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    autofocus: true,
                    onChanged: (_) => setModalState(() {}),
                    decoration: const InputDecoration(
                      hintText:
                          'Example: Time conflict, instructor mismatch...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Minimum 8 characters.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: canSubmit
                      ? () => Navigator.of(context).pop(trimmed)
                      : null,
                  child: const Text('Send report'),
                ),
              ],
            );
          },
        );
      },
    );

    if (submittedNote == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() => _reportBusy = true);
    try {
      await widget.api.reportClassIssue(details, note: submittedNote);
      TelemetryService.instance.logEvent(
        'class_issue_reported',
        data: {
          'class_id': details.id,
          'section_id': details.sectionId,
          'enabled': details.enabled,
          'note_length': submittedNote.length,
        },
      );
      _toast(
        "Thanks! We'll review this class shortly.",
        type: AppSnackBarType.success,
      );
    } catch (error, stack) {
      TelemetryService.instance.logError(
        'class_issue_report_failed',
        error: error,
        stack: stack,
        data: {'class_id': details.id},
      );
      _toast(
        'Could not send the report. Try again later.',
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _reportBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final cardBackground = elevatedCardBackground(theme, solid: true);
    final borderColor = elevatedCardBorder(theme, solid: true);
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * 0.78;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: AppTokens.radius.xl,
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.32 : 0.18,
              ),
              blurRadius: 24,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: spacing.edgeInsetsOnly(
              left: spacing.xl + 8,
              right: spacing.xl + 8,
              top: spacing.xl + 4,
              bottom: spacing.xl,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      PressableScale(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Class details',
                          textAlign: TextAlign.center,
                          style: AppTokens.typography.title.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  SizedBox(height: spacing.lg),
                  Flexible(
                    child: FutureBuilder<sched.ClassDetails>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          final message = snapshot.error?.toString() ??
                              'Unable to load class details.';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                message,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.error,
                                ),
                              ),
                              SizedBox(height: spacing.lg),
                              FilledButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        }
                        final details = snapshot.data!;
                        return _ClassDetailsContent(
                          details: details,
                          onToggle: () => _toggleEnabled(details),
                          onReport: details.isCustom
                              ? null
                              : () => _reportLinkedIssue(details),
                          toggleBusy: _toggleBusy,
                          onEdit:
                              details.isCustom && widget.onEditCustom != null
                                  ? () => _editCustom(details)
                                  : null,
                          onDelete: details.isCustom
                              ? () => _deleteCustom(details)
                              : null,
                          deleteBusy: _deleteBusy,
                          reportBusy: _reportBusy,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClassDetailsContent extends StatelessWidget {
  const _ClassDetailsContent({
    required this.details,
    this.onToggle,
    this.onEdit,
    this.onDelete,
    this.onReport,
    this.toggleBusy = false,
    this.deleteBusy = false,
    this.reportBusy = false,
  });

  final sched.ClassDetails details;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final bool toggleBusy;
  final bool deleteBusy;
  final bool reportBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    final startLabel = _formatTime(details.start);
    final endLabel = _formatTime(details.end);
    final dayValid = details.day >= 1 && details.day <= 7;
    final dayLabel = dayValid ? _weekdayName(details.day) : null;
    final scheduleValue = dayLabel != null
        ? '$dayLabel, $startLabel - $endLabel'
        : '$startLabel - $endLabel';

    final bool isLinked = !details.isCustom;
    final tags = <Widget>[
      _InfoChip(
        icon: details.isCustom ? Icons.star_border_rounded : Icons.cloud_sync,
        label: details.isCustom ? 'Custom class' : 'Synced class',
        color: details.isCustom ? colors.secondary : colors.primary,
      ),
      if (!details.enabled)
        _InfoChip(
          icon: Icons.pause_circle_outline,
          label: 'Disabled',
          color: colors.outline,
        ),
    ];

    final sectionParts = <String>[];
    if (details.sectionCode != null && details.sectionCode!.isNotEmpty) {
      sectionParts.add(details.sectionCode!);
    }
    if (details.sectionNumber != null && details.sectionNumber!.isNotEmpty) {
      sectionParts.add('Section ${details.sectionNumber!}');
    }
    final sectionValue = sectionParts.isEmpty ? null : sectionParts.join(' / ');

    final infoRows = <Widget>[
      _DetailRow(
        icon: Icons.schedule_rounded,
        label: 'Schedule',
        value: scheduleValue,
      ),
      if (details.room != null && details.room!.isNotEmpty)
        _DetailRow(
          icon: Icons.location_on_outlined,
          label: 'Room',
          value: details.room!,
        ),
      if (details.units != null)
        _DetailRow(
          icon: Icons.calculate_outlined,
          label: 'Units',
          value: details.units.toString(),
        ),
      if (sectionValue != null || details.sectionName != null)
        _DetailRow(
          icon: Icons.class_outlined,
          label: 'Section',
          value: sectionValue ?? details.sectionName ?? 'Section',
          helper: sectionValue != null && details.sectionName != null
              ? details.sectionName
              : null,
        ),
      if (details.sectionStatus != null && details.sectionStatus!.isNotEmpty)
        _DetailRow(
          icon: Icons.info_outline,
          label: 'Section status',
          value: details.sectionStatus!,
        ),
      if (details.createdAt != null)
        _DetailRow(
          icon: Icons.history_edu_outlined,
          label: details.isCustom ? 'Added on' : 'Created',
          value: _formatDate(details.createdAt!),
        ),
      if (details.updatedAt != null &&
          (details.createdAt == null ||
              !details.updatedAt!.isAtSameMomentAs(details.createdAt!)))
        _DetailRow(
          icon: Icons.update,
          label: 'Updated',
          value: _formatDate(details.updatedAt!),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          details.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        if (details.code != null && details.code!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            details.code!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
        if (tags.isNotEmpty) ...[
          SizedBox(height: spacing.lg),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags,
          ),
        ],
        if (isLinked) ...[
          SizedBox(height: spacing.sm),
          Text(
            'This class stays in sync with the campus schedule. Reach out to an admin if details are incorrect.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
        SizedBox(height: spacing.xl),
        ..._insertSpacing(infoRows, spacing.lg),
        if (details.instructorName != null &&
            details.instructorName!.isNotEmpty) ...[
          SizedBox(height: spacing.xl),
          _InstructorDetail(details: details),
        ],
        if (onEdit != null || onToggle != null || onDelete != null) ...[
          SizedBox(height: spacing.xl),
          _ClassDetailActions(
            details: details,
            onToggle: onToggle,
            onEdit: onEdit,
            onDelete: onDelete,
            onReport: onReport,
            toggleBusy: toggleBusy,
            deleteBusy: deleteBusy,
            reportBusy: reportBusy,
          ),
        ],
      ],
    );
  }

  static List<Widget> _insertSpacing(List<Widget> items, double spacing) {
    if (items.isEmpty) return const [];
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(SizedBox(height: spacing));
      }
    }
    return result;
  }

  static String _formatDate(DateTime date) {
    return DateFormat.yMMMMd().add_jm().format(date);
  }

  static String _formatTime(String raw) {
    final minutes = _minutesFor(raw);
    final date = DateTime(2024, 1, 1, minutes ~/ 60, minutes % 60);
    return DateFormat.jm().format(date).replaceAll('\u202f', ' ');
  }
}

class _ClassDetailActions extends StatelessWidget {
  const _ClassDetailActions({
    required this.details,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
    required this.toggleBusy,
    required this.deleteBusy,
    required this.reportBusy,
  });

  final sched.ClassDetails details;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final bool toggleBusy;
  final bool deleteBusy;
  final bool reportBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final children = <Widget>[];

    if (onEdit != null) {
      children.add(
        Semantics(
          button: true,
          label: 'Edit custom class',
          child: Tooltip(
            message: 'Open the custom class editor',
            child: FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit custom class'),
            ),
          ),
        ),
      );
    }

    if (onToggle != null) {
      final label = details.enabled ? 'Disable class' : 'Enable class';
      final icon = details.enabled
          ? Icons.pause_circle_outline
          : Icons.play_circle_outline;
      children.add(
        Semantics(
          button: true,
          toggled: details.enabled,
          label: label,
          child: Tooltip(
            message: details.enabled
                ? 'Temporarily hide this class from your schedule'
                : 'Show this class in your schedule again',
            child: FilledButton.tonalIcon(
              onPressed: toggleBusy ? null : onToggle,
              icon: toggleBusy
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colors.primary),
                      ),
                    )
                  : Icon(icon),
              label: Text(label),
            ),
          ),
        ),
      );
    }

    if (!details.isCustom && onReport != null) {
      children.add(
        Semantics(
          button: true,
          label: 'Report schedule issue',
          child: Tooltip(
            message: 'Let the admins know something looks wrong',
            child: TextButton.icon(
              onPressed: reportBusy ? null : onReport,
              icon: reportBusy
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : const Icon(Icons.flag_outlined),
              label: Text(
                reportBusy ? 'Sending report...' : 'Report schedule issue',
              ),
            ),
          ),
        ),
      );
    }
    if (onDelete != null) {
      children.add(
        Semantics(
          button: true,
          label: 'Delete class',
          child: Tooltip(
            message: 'Remove this custom class from MySched',
            child: TextButton.icon(
              onPressed: deleteBusy ? null : onDelete,
              icon: deleteBusy
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.error),
                      ),
                    )
                  : const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete class'),
              style: TextButton.styleFrom(
                foregroundColor: colors.error,
              ),
            ),
          ),
        ),
      );
    }

    if (children.isEmpty && !details.isCustom) {
      children.add(
        Text(
          'Linked classes can only be edited by an administrator.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      );
    } else if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _spaced(children),
    );
  }

  List<Widget> _spaced(List<Widget> items) {
    if (items.length <= 1) return items;
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(const SizedBox(height: 12));
      }
    }
    return result;
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.helper,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (helper != null && helper!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  helper!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InstructorDetail extends StatelessWidget {
  const _InstructorDetail({required this.details});

  final sched.ClassDetails details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = details.instructorName ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instructor',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InstructorAvatar(
              name: name,
              avatarUrl: details.instructorAvatar,
              tint: colors.primary,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (details.instructorTitle != null &&
                      details.instructorTitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      details.instructorTitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (details.instructorDepartment != null &&
                      details.instructorDepartment!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      details.instructorDepartment!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (details.instructorEmail != null &&
                      details.instructorEmail!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    SelectableText(
                      details.instructorEmail!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundOpacity = theme.brightness == Brightness.dark ? 0.24 : 0.12;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: backgroundOpacity),
        borderRadius: AppTokens.radius.md,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

int _minutesFor(String raw) {
  final value = raw.trim().toLowerCase().replaceAll('.', '');
  if (value.isEmpty) return 0;

  var text = value;
  var meridian = '';
  if (text.endsWith('am') || text.endsWith('pm')) {
    meridian = text.substring(text.length - 2);
    text = text.substring(0, text.length - 2).trim();
  }

  int hour;
  int minute;

  if (text.contains(':')) {
    final parts = text.split(':').map((part) => part.trim()).toList();
    hour = int.tryParse(parts[0]) ?? 0;
    minute = parts.length >= 2 ? int.tryParse(parts[1]) ?? 0 : 0;
  } else {
    hour = int.tryParse(text) ?? 0;
    minute = 0;
  }

  if (meridian == 'pm' && hour != 12) hour += 12;
  if (meridian == 'am' && hour == 12) hour = 0;

  hour = hour.clamp(0, 23);
  minute = minute.clamp(0, 59);

  return hour * 60 + minute;
}

String _weekdayName(int day) {
  const names = [
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
  return 'Day $day';
}
