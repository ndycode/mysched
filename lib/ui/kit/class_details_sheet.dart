import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/schedule_api.dart' as sched;
import '../../services/notif_scheduler.dart';
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
      await NotifScheduler.resync(api: widget.api);
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
    final confirm = await AppModal.showConfirmDialog(
          context: context,
          title: 'Delete custom class?',
          message: 'This class will be removed from your schedules and reminders.',
          confirmLabel: 'Delete',
          isDanger: true,
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
      await NotifScheduler.resync(api: widget.api);
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
    final submittedNote = await showSmoothDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final trimmed = controller.text.trim();
            final canSubmit = trimmed.length >= 8;
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sheet),
              titlePadding: AppTokens.spacing.edgeInsetsOnly(
                left: AppTokens.spacing.xl,
                right: AppTokens.spacing.xl,
                top: AppTokens.spacing.xl,
                bottom: AppTokens.spacing.sm,
              ),
              contentPadding: AppTokens.spacing.edgeInsetsOnly(
                left: AppTokens.spacing.xl,
                right: AppTokens.spacing.xl,
                bottom: AppTokens.spacing.lg,
              ),
              actionsPadding: AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.lg),
              title: Text(
                'Report a schedule issue',
                style: AppTokens.typography.title.copyWith(
                  fontWeight: AppTokens.fontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tell us what looks wrong so an administrator can review it.',
                    style: AppTokens.typography.body.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppTokens.spacing.lg),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    autofocus: true,
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Example: Time conflict, instructor mismatch...',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle),
                      border: OutlineInputBorder(
                        borderRadius: AppTokens.radius.md,
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppTokens.radius.md,
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: AppOpacity.subtle)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppTokens.radius.md,
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: AppTokens.componentSize.dividerThick),
                      ),
                      contentPadding: AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.md),
                    ),
                  ),
                  SizedBox(height: AppTokens.spacing.sm),
                  Text(
                    'Minimum 8 characters.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              actions: [
                SecondaryButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                  minHeight: AppTokens.componentSize.buttonSm,
                  expanded: false,
                ),
                PrimaryButton(
                  label: 'Send report',
                  onPressed: canSubmit
                      ? () => Navigator.of(context).pop(trimmed)
                      : null,
                  minHeight: AppTokens.componentSize.buttonSm,
                  expanded: false,
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
    final maxHeight = media.size.height * 0.85;
    final isDark = theme.brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: AppLayout.sheetMaxWidth),
      child: Container(
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: AppTokens.radius.xl,
          border: Border.all(color: borderColor),
          boxShadow: [
            AppTokens.shadow.bubble(
              theme.shadowColor.withValues(
                alpha: isDark ? 0.35 : 0.18,
              ),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: EdgeInsets.all(spacing.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: FutureBuilder<sched.ClassDetails>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return SizedBox(
                            height: AppTokens.componentSize.previewMd,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          final message = snapshot.error?.toString() ??
                              'Unable to load class details.';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SheetHeaderRow(
                                title: 'Error',
                                subtitle: 'Class details',
                                icon: Icons.error_outline_rounded,
                                onClose: () => Navigator.of(context).pop(),
                              ),
                              SizedBox(height: spacing.lg),
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
                          onClose: () => Navigator.of(context).pop(),
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

// _HeaderRow removed - using global SheetHeaderRow from kit.dart

class _ClassDetailsContent extends StatelessWidget {
  const _ClassDetailsContent({
    required this.details,
    required this.onClose,
    this.onToggle,
    this.onEdit,
    this.onDelete,
    this.onReport,
    this.toggleBusy = false,
    this.deleteBusy = false,
    this.reportBusy = false,
  });

  final sched.ClassDetails details;
  final VoidCallback onClose;
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
    final isDark = theme.brightness == Brightness.dark;

    final startLabel = _formatTime(details.start);
    final endLabel = _formatTime(details.end);
    final dayValid = details.day >= 1 && details.day <= 7;
    final dayLabel = dayValid ? _weekdayName(details.day) : null;
    final scheduleValue = dayLabel != null
        ? '$dayLabel, $startLabel - $endLabel'
        : '$startLabel - $endLabel';

    final sectionParts = <String>[];
    if (details.sectionCode != null && details.sectionCode!.isNotEmpty) {
      sectionParts.add(details.sectionCode!);
    }
    if (details.sectionNumber != null && details.sectionNumber!.isNotEmpty) {
      sectionParts.add('Section ${details.sectionNumber!}');
    }
    final sectionValue = sectionParts.isEmpty ? null : sectionParts.join(' / ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHeaderRow(
          title: details.title,
          subtitle: 'Class details',
          icon: Icons.class_rounded,
          onClose: onClose,
        ),
        SizedBox(height: spacing.xl),
        
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusInfoChip(
                      icon: details.isCustom ? Icons.edit_note_rounded : Icons.cloud_sync_rounded,
                      label: details.isCustom ? 'Custom class' : 'Synced class',
                      color: details.isCustom ? colors.primary : colors.tertiary,
                    ),
                    if (!details.enabled)
                      StatusInfoChip(
                        icon: Icons.pause_circle_outline_rounded,
                        label: 'Disabled',
                        color: colors.outline,
                      ),
                  ],
                ),
                SizedBox(height: spacing.lg),

                // Main Details Container
                Container(
                  padding: EdgeInsets.all(AppTokens.spacing.xl),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.ghost) 
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
                        icon: Icons.access_time_rounded,
                        label: 'Schedule',
                        value: scheduleValue,
                        accentIcon: true,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: AppTokens.spacing.lg),
                        child: Divider(
                          height: AppTokens.componentSize.divider,
                          color: isDark 
                              ? colors.outline.withValues(alpha: AppOpacity.medium) 
                              : colors.primary.withValues(alpha: AppOpacity.dim),
                        ),
                      ),
                      DetailRow(
                        icon: Icons.place_outlined,
                        label: 'Room',
                        value: details.room ?? 'No room assigned',
                        accentIcon: true,
                      ),
                      if (details.units != null) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: AppTokens.spacing.lg),
                          child: Divider(
                            height: AppTokens.componentSize.divider,
                            color: isDark 
                                ? colors.outline.withValues(alpha: AppOpacity.medium) 
                                : colors.primary.withValues(alpha: AppOpacity.dim),
                          ),
                        ),
                        DetailRow(
                          icon: Icons.calculate_outlined,
                          label: 'Units',
                          value: details.units.toString(),
                          accentIcon: true,
                        ),
                      ],
                      if (sectionValue != null || details.sectionName != null) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: AppTokens.spacing.lg),
                          child: Divider(
                            height: AppTokens.componentSize.divider,
                            color: isDark 
                                ? colors.outline.withValues(alpha: AppOpacity.medium) 
                                : colors.primary.withValues(alpha: AppOpacity.dim),
                          ),
                        ),
                        DetailRow(
                          icon: Icons.class_outlined,
                          label: 'Section',
                          value: sectionValue ?? details.sectionName ?? 'Section',
                          helper: sectionValue != null && details.sectionName != null
                              ? details.sectionName
                              : null,
                          accentIcon: true,
                        ),
                      ],
                      if (details.createdAt != null) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: AppTokens.spacing.lg),
                          child: Divider(
                            height: AppTokens.componentSize.divider,
                            color: isDark 
                                ? colors.outline.withValues(alpha: AppOpacity.medium) 
                                : colors.primary.withValues(alpha: AppOpacity.dim),
                          ),
                        ),
                        DetailRow(
                          icon: Icons.history_edu_outlined,
                          label: details.isCustom ? 'Added on' : 'Created',
                          value: _formatDate(details.createdAt!),
                          accentIcon: true,
                        ),
                      ],
                    ],
                  ),
                ),
                
                if (details.instructorName != null && details.instructorName!.isNotEmpty) ...[
                  SizedBox(height: spacing.lg),
                  _InstructorDetail(details: details),
                ],

                SizedBox(height: spacing.xl),

                // Actions
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
            ),
          ),
        ),
      ],
    );
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

class _InstructorDetail extends StatelessWidget {
  const _InstructorDetail({required this.details});

  final sched.ClassDetails details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final name = details.instructorName ?? '';
    
    return Container(
      padding: EdgeInsets.all(AppTokens.spacing.lg),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.ghost) : colors.surface,
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: isDark ? colors.outline.withValues(alpha: AppOpacity.overlay) : colors.outlineVariant,
          width: AppTokens.componentSize.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructor',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: AppTokens.fontWeight.semiBold,
            ),
          ),
          SizedBox(height: AppTokens.spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InstructorAvatar(
                name: name,
                avatarUrl: details.instructorAvatar,
                tint: colors.primary,
                size: AppTokens.iconSize.xxl,
              ),
              SizedBox(width: AppTokens.spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTokens.typography.subtitle.copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                      ),
                    ),
                    if (details.instructorEmail != null &&
                        details.instructorEmail!.isNotEmpty) ...[
                      SizedBox(height: AppTokens.spacing.xs),
                      Text(
                        details.instructorEmail!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: AppTokens.fontWeight.medium,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// _InfoChip and _DetailRow removed - using global StatusInfoChip and DetailRow from kit.dart

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
      FilledButton.icon(
          onPressed: onEdit,
          icon: Icon(Icons.edit_rounded, size: AppTokens.iconSize.sm),
          label: const Text('Edit custom class'),
          style: FilledButton.styleFrom(
            minimumSize: Size.fromHeight(AppTokens.componentSize.buttonMd),
            shape: RoundedRectangleBorder(
              borderRadius: AppTokens.radius.md,
            ),
          ),
        ),
      );
    }

    if (onToggle != null) {
      final label = details.enabled ? 'Disable class' : 'Enable class';
      final icon = details.enabled
          ? Icons.pause_circle_outline_rounded
          : Icons.play_circle_outline_rounded;
      children.add(
        FilledButton.tonalIcon(
          onPressed: toggleBusy ? null : onToggle,
          icon: toggleBusy
              ? SizedBox(
                  width: AppInteraction.loaderSize,
                  height: AppInteraction.loaderSize,
                  child: CircularProgressIndicator(
                    strokeWidth: AppInteraction.progressStrokeWidth,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
                )
              : Icon(icon, size: AppTokens.iconSize.md),
          label: Text(label),
          style: FilledButton.styleFrom(
            minimumSize: Size.fromHeight(AppTokens.componentSize.buttonMd),
            shape: RoundedRectangleBorder(
              borderRadius: AppTokens.radius.md,
            ),
            backgroundColor: details.enabled ? colors.primaryContainer : null,
            foregroundColor: details.enabled ? colors.onPrimaryContainer : null,
          ),
        ),
      );
    }

    if (!details.isCustom && onReport != null) {
      children.add(
        TextButton.icon(
          onPressed: reportBusy ? null : onReport,
          icon: reportBusy
              ? SizedBox(
                  width: AppInteraction.loaderSize,
                  height: AppInteraction.loaderSize,
                  child: CircularProgressIndicator(
                    strokeWidth: AppInteraction.progressStrokeWidth,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : Icon(Icons.flag_outlined, size: AppTokens.iconSize.md),
          label: Text(
            reportBusy ? 'Sending report...' : 'Report schedule issue',
          ),
          style: TextButton.styleFrom(
            minimumSize: Size.fromHeight(AppTokens.componentSize.buttonMd),
            shape: RoundedRectangleBorder(
              borderRadius: AppTokens.radius.md,
            ),
          ),
        ),
      );
    }
    if (onDelete != null) {
      children.add(
        TextButton.icon(
          onPressed: deleteBusy ? null : onDelete,
          icon: deleteBusy
              ? SizedBox(
                  width: AppInteraction.loaderSize,
                  height: AppInteraction.loaderSize,
                  child: CircularProgressIndicator(
                    strokeWidth: AppInteraction.progressStrokeWidth,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.error),
                  ),
                )
              : Icon(Icons.delete_outline_rounded, size: AppTokens.iconSize.md),
          label: const Text('Delete class'),
          style: TextButton.styleFrom(
            foregroundColor: colors.error,
            minimumSize: Size.fromHeight(AppTokens.componentSize.buttonMd),
            shape: RoundedRectangleBorder(
              borderRadius: AppTokens.radius.md,
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
        result.add(SizedBox(height: AppTokens.spacing.md));
      }
    }
    return result;
  }
}
