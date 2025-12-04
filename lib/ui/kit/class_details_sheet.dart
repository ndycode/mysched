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
                  SizedBox(height: AppTokens.spacing.md),
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
    final maxHeight = media.size.height * 0.85;
    final isDark = theme.brightness == Brightness.dark;

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
                alpha: isDark ? 0.35 : 0.18,
              ),
              blurRadius: 28,
              offset: const Offset(0, 20),
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
                          return const SizedBox(
                            height: 200,
                            child: Center(
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
                              _HeaderRow(
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

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onClose,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary.withValues(alpha: 0.15),
                colors.primary.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: AppTokens.radius.md,
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: colors.primary,
            size: AppTokens.iconSize.xl,
          ),
        ),
        SizedBox(width: AppTokens.spacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTokens.typography.title.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.2,
                  color: colors.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppTokens.spacing.xs),
              Text(
                subtitle,
                style: AppTokens.typography.bodySecondary.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppTokens.spacing.md),
        PressableScale(
          onTap: onClose,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: 0.05),
              borderRadius: AppTokens.radius.md,
            ),
            child: Icon(
              Icons.close_rounded,
              size: AppTokens.iconSize.md,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

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
        _HeaderRow(
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
                    _InfoChip(
                      icon: details.isCustom ? Icons.edit_note_rounded : Icons.cloud_sync_rounded,
                      label: details.isCustom ? 'Custom class' : 'Synced class',
                      color: details.isCustom ? colors.primary : colors.tertiary,
                    ),
                    if (!details.enabled)
                      _InfoChip(
                        icon: Icons.pause_circle_outline_rounded,
                        label: 'Disabled',
                        color: colors.outline,
                      ),
                  ],
                ),
                SizedBox(height: spacing.lg),

                // Main Details Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? colors.surfaceContainerHighest.withValues(alpha: 0.3) 
                        : colors.primary.withValues(alpha: 0.04),
                    borderRadius: AppTokens.radius.lg,
                    border: Border.all(
                      color: isDark 
                          ? colors.outline.withValues(alpha: 0.12) 
                          : colors.primary.withValues(alpha: 0.10),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.access_time_rounded,
                        label: 'Schedule',
                        value: scheduleValue,
                        isPremium: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(
                          height: 1,
                          color: isDark 
                              ? colors.outline.withValues(alpha: 0.15) 
                              : colors.primary.withValues(alpha: 0.10),
                        ),
                      ),
                      _DetailRow(
                        icon: Icons.place_outlined,
                        label: 'Room',
                        value: details.room ?? 'No room assigned',
                        isPremium: true,
                      ),
                      if (details.units != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            height: 1,
                            color: isDark 
                                ? colors.outline.withValues(alpha: 0.15) 
                                : colors.primary.withValues(alpha: 0.10),
                          ),
                        ),
                        _DetailRow(
                          icon: Icons.calculate_outlined,
                          label: 'Units',
                          value: details.units.toString(),
                          isPremium: true,
                        ),
                      ],
                      if (sectionValue != null || details.sectionName != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            height: 1,
                            color: isDark 
                                ? colors.outline.withValues(alpha: 0.15) 
                                : colors.primary.withValues(alpha: 0.10),
                          ),
                        ),
                        _DetailRow(
                          icon: Icons.class_outlined,
                          label: 'Section',
                          value: sectionValue ?? details.sectionName ?? 'Section',
                          helper: sectionValue != null && details.sectionName != null
                              ? details.sectionName
                              : null,
                          isPremium: true,
                        ),
                      ],
                      if (details.createdAt != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            height: 1,
                            color: isDark 
                                ? colors.outline.withValues(alpha: 0.15) 
                                : colors.primary.withValues(alpha: 0.10),
                          ),
                        ),
                        _DetailRow(
                          icon: Icons.history_edu_outlined,
                          label: details.isCustom ? 'Added on' : 'Created',
                          value: _formatDate(details.createdAt!),
                          isPremium: true,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHighest.withValues(alpha: 0.3) : colors.surface,
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: isDark ? colors.outline.withValues(alpha: 0.12) : colors.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructor',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (details.instructorEmail != null &&
                        details.instructorEmail!.isNotEmpty) ...[
                      SizedBox(height: AppTokens.spacing.xs),
                      Text(
                        details.instructorEmail!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w500,
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
          Icon(icon, size: AppTokens.iconSize.sm, color: color),
          SizedBox(width: AppTokens.spacing.xs),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.helper,
    this.isPremium = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? helper;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPremium ? colors.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: AppTokens.radius.sm,
          ),
          child: Icon(
            icon, 
            size: AppTokens.iconSize.md, 
            color: colors.primary,
          ),
        ),
        SizedBox(width: AppTokens.spacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTokens.typography.caption.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppTokens.spacing.xs),
              Text(
                value,
                style: AppTokens.typography.subtitle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              if (helper != null && helper!.isNotEmpty) ...[
                SizedBox(height: AppTokens.spacing.xs),
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
            minimumSize: const Size.fromHeight(50),
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
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
                )
              : Icon(icon, size: AppTokens.iconSize.md),
          label: Text(label),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
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
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
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
            minimumSize: const Size.fromHeight(50),
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
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.error),
                  ),
                )
              : Icon(Icons.delete_outline_rounded, size: AppTokens.iconSize.md),
          label: const Text('Delete class'),
          style: TextButton.styleFrom(
            foregroundColor: colors.error,
            minimumSize: const Size.fromHeight(50),
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
