// add_class_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app/routes.dart';
import '../services/notif_scheduler.dart';
import '../services/schedule_api.dart';
import '../services/profile_cache.dart';
import '../services/telemetry_service.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/motion.dart';
import '../ui/theme/tokens.dart';
import '../ui/theme/card_styles.dart';
import '../utils/app_log.dart';
import '../utils/nav.dart';
import '../utils/schedule_overlap.dart';

const _scope = 'AddClass';

/// Validates class time range. End time must be after start time.
bool isValidClassTimeRange(TimeOfDay start, TimeOfDay end) {
  final startMinutes = start.hour * 60 + start.minute;
  final endMinutes = end.hour * 60 + end.minute;
  // End time must be strictly after start time
  return endMinutes > startMinutes;
}

class AddClassPage extends StatefulWidget {
  const AddClassPage({super.key, required this.api, this.initialClass});

  final ScheduleApi api;
  final ClassItem? initialClass;

  @override
  State<AddClassPage> createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> with RouteAware {
  String _studentName = 'Student';
  String _studentEmail = '';
  String? _avatarUrl;
  bool _profileHydrated = false;
  Route<dynamic>? _routeSubscription;

  bool get _isEditing => widget.initialClass != null;

  final _formKey = GlobalKey<_AddClassFormState>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute && route != _routeSubscription) {
      if (_routeSubscription != null) {
        routeObserver.unsubscribe(this);
      }
      _routeSubscription = route;
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    if (_routeSubscription != null) {
      routeObserver.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    // Refresh profile when returning from account page
    _loadProfile(refresh: true);
  }

  Future<void> _loadProfile({bool refresh = false}) async {
    try {
      final profile = await ProfileCache.load(forceRefresh: refresh);
      _applyProfile(profile);
    } catch (e, stack) {
      TelemetryService.instance
          .logError('add_class_load_profile', error: e, stack: stack);
      if (!mounted) return;
      if (!_profileHydrated) {
        setState(() => _profileHydrated = true);
      }
    }
  }

  void _applyProfile(ProfileSummary? profile) {
    if (!mounted) return;
    if (profile == null) {
      if (!_profileHydrated) {
        setState(() => _profileHydrated = true);
      }
      return;
    }
    final name = profile.name ?? 'Student';
    final email = profile.email ?? '';
    final avatar = profile.avatarUrl;
    final changed = name != _studentName ||
        email != _studentEmail ||
        avatar != _avatarUrl ||
        !_profileHydrated;
    if (!changed) return;
    setState(() {
      _studentName = name;
      _studentEmail = email;
      _avatarUrl = avatar;
      _profileHydrated = true;
    });
  }

  Future<void> _openAccount() async {
    await context.push(AppRoutes.account);
    if (!mounted) return;
    await _loadProfile(refresh: true);
  }

  // ===== Reminders-style Menu (nav bar actions) =====
  Widget _buildMenuButton({Color? iconColor}) {
    return PopupMenuButton<_ClassMenuAction>(
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: AppTokens.radius.md,
      ),
      icon: Icon(
        Icons.more_vert_rounded,
        color: iconColor,
      ),
      onSelected: (action) {
        switch (action) {
          case _ClassMenuAction.save:
            _formKey.currentState?.triggerSave();
            break;
          case _ClassMenuAction.cancel:
            Navigator.of(context).maybePop();
            break;
          case _ClassMenuAction.autofill:
            _formKey.currentState?.triggerAutofill();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _ClassMenuAction.save,
          child: Row(
            children: [
              Icon(Icons.save_outlined, size: AppTokens.iconSize.sm),
              SizedBox(width: AppTokens.spacing.md),
              const Text('Save class'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _ClassMenuAction.cancel,
          child: Row(
            children: [
              Icon(Icons.close_rounded, size: AppTokens.iconSize.sm),
              SizedBox(width: AppTokens.spacing.md),
              const Text('Cancel'),
            ],
          ),
        ),
        if (kDebugMode)
          PopupMenuItem(
            value: _ClassMenuAction.autofill,
            child: Row(
              children: [
                Icon(Icons.auto_fix_high_rounded, size: AppTokens.iconSize.sm),
                SizedBox(width: AppTokens.spacing.md),
                const Text('Autofill sample'),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    final menuButton = _buildMenuButton(
      iconColor:
          colors.onSurfaceVariant.withValues(alpha: AppOpacity.prominent),
    );

    final hero = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScreenBrandHeader(
          name: _studentName,
          email: _studentEmail,
          avatarUrl: _avatarUrl,
          onAccountTap: _openAccount,
          showChevron: false,
          loading: !_profileHydrated,
          height: AppTokens.componentSize.listItemSm,
          avatarRadius: AppTokens.spacing.xl,
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'SFProRounded',
            fontWeight: AppTokens.fontWeight.bold,
            color: colors.primary,
            fontSize: AppTokens.typography.title.fontSize,
          ),
        ),
        SizedBox(height: spacing.xl),
        ScreenHeroCard(
          title: _isEditing ? 'Edit custom class' : 'Add custom class',
          subtitle:
              'Stay consistent with your Reminders layout. Use the menu to save, cancel, or autofill.',
        ),
      ],
    );

    final sections = <Widget>[
      ScreenSection(
        decorated: false,
        child: _RemindersStyleShell(
          title: _isEditing ? 'Edit custom class' : 'Add custom class',
          subtitle: _isEditing
              ? 'Update the session details for this custom class.'
              : 'Enter the session details. You can edit or remove custom classes from the schedules tab later.',
          trailing: SizedBox(
              height: AppTokens.componentSize.buttonSm, child: menuButton),
          child: AddClassForm(
            key: _formKey,
            api: widget.api,
            initialClass: widget.initialClass,
            isSheet: false,
            onCancel: () => Navigator.of(context).maybePop(),
            onSaved: (day) => Navigator.of(context).pop(day),
          ),
        ),
      ),
      ScreenSection(
        decorated: false,
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).maybePop(),
                minHeight: AppTokens.componentSize.buttonMd,
              ),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: PrimaryButton(
                label: _isEditing ? 'Save class' : 'Add class',
                onPressed: () => _formKey.currentState?.triggerSave(),
                minHeight: AppTokens.componentSize.buttonMd,
              ),
            ),
          ],
        ),
      ),
    ];

    return ScreenShell(
      screenName: _isEditing ? 'edit_class' : 'add_class',
      hero: hero,
      sections: sections,
      onRefresh: () => _loadProfile(refresh: true),
    );
  }
}

class AddClassSheet extends StatefulWidget {
  const AddClassSheet({
    super.key,
    required this.api,
    this.initialClass,
  });

  final ScheduleApi api;
  final ClassItem? initialClass;

  @override
  State<AddClassSheet> createState() => _AddClassSheetState();
}

class _AddClassSheetState extends State<AddClassSheet> {
  final _formKey = GlobalKey<_AddClassFormState>();
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final spacing = AppTokens.spacing;
    final cardBackground = elevatedCardBackground(theme, solid: true);
    final borderColor = elevatedCardBorder(theme, solid: true);
    final borderWidth = elevatedCardBorderWidth(theme);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.initialClass != null;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppLayout.sheetMaxWidth,
            maxHeight: media.size.height * AppLayout.sheetMaxHeightRatio,
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: spacing.xl),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: AppTokens.radius.xxl,
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
              boxShadow: isDark
                  ? null
                  : [
                      AppTokens.shadow.modal(
                        theme.colorScheme.shadow.withValues(alpha: AppOpacity.border),
                      ),
                    ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: ClipRRect(
                borderRadius: AppTokens.radius.xl,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(spacing.xl),
                        child: AddClassForm(
                          key: _formKey,
                          api: widget.api,
                          initialClass: widget.initialClass,
                          isSheet: true,
                          includeButtons: false,
                          onCancel: () => Navigator.of(context).maybePop(),
                          onSaved: (day) => Navigator.of(context).pop(day),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        spacing.xl,
                        spacing.md,
                        spacing.xl,
                        spacing.xl + media.viewInsets.bottom,
                      ),
                      decoration: BoxDecoration(
                        color: cardBackground,
                        border: Border(
                          top: BorderSide(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: AppOpacity.ghost),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              label: _submitting
                                  ? (isEditing ? 'Updating...' : 'Saving...')
                                  : (isEditing ? 'Update class' : 'Save class'),
                              onPressed: _submitting
                                  ? null
                                  : () {
                                      setState(() => _submitting = true);
                                      _formKey.currentState
                                          ?.triggerSave()
                                          .whenComplete(() {
                                        if (mounted) {
                                          setState(() => _submitting = false);
                                        }
                                      });
                                    },
                              minHeight: AppTokens.componentSize.buttonMd,
                            ),
                          ),
                          SizedBox(width: spacing.md),
                          Expanded(
                            child: SecondaryButton(
                              label: 'Cancel',
                              onPressed: () => Navigator.of(context).maybePop(),
                              minHeight: AppTokens.componentSize.buttonMd,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RemindersStyleShell extends StatelessWidget {
  const _RemindersStyleShell({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardBackground = elevatedCardBackground(theme);
    final borderColor = elevatedCardBorder(theme);

    return Container(
      padding: AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.xl),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: AppTokens.radius.md,
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: AppOpacity.faint),
                  blurRadius: AppTokens.shadow.sm,
                  offset: AppShadowOffset.sm,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                        fontSize: AppTokens.typography.title.fontSize,
                      ),
                    ),
                    SizedBox(height: AppTokens.spacing.xs),
                    Text(
                      DateFormat('EEEE, MMM d').format(DateTime.now()),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: AppTokens.typography.subtitle.fontSize,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: AppTokens.spacing.xs),
                SizedBox(
                    height: AppTokens.componentSize.buttonSm, child: trailing!),
              ],
            ],
          ),
          SizedBox(height: AppTokens.spacing.lg),
          Container(
            padding: AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.lg),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest
                  .withValues(alpha: AppOpacity.barrier),
              borderRadius: AppTokens.radius.lg,
            ),
            child: Row(
              children: [
                Icon(Icons.class_outlined,
                    color: colors.onSurfaceVariant
                        .withValues(alpha: AppOpacity.prominent)),
                SizedBox(width: AppTokens.spacing.md),
                Expanded(
                  child: Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTokens.spacing.xl),
          child,
        ],
      ),
    );
  }
}

class AddClassForm extends StatefulWidget {
  const AddClassForm({
    super.key,
    required this.api,
    this.initialClass,
    required this.onCancel,
    required this.onSaved,
    required this.isSheet,
    this.includeButtons = true,
  });

  final ScheduleApi api;
  final ClassItem? initialClass;
  final VoidCallback onCancel;

  /// Called when the class is saved. Passes the weekday (1-7) of the saved class,
  /// or null if cancelled/failed. This allows callers to scroll to the new class.
  final ValueChanged<int?> onSaved;
  final bool isSheet;
  final bool includeButtons;

  bool get isEditing => initialClass != null;

  @override
  State<AddClassForm> createState() => _AddClassFormState();
}

class _AddClassFormState extends State<AddClassForm> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _room = TextEditingController();
  final _instructorText = TextEditingController();

  List<InstructorOption> _instructors = const [];
  bool _loadingInstructors = true;
  String? _instructorError;
  String? _selectedInstructorId;
  String? _selectedInstructorAvatar;
  String? _initialInstructorName;
  bool _instructorManuallyEdited = false;

  int _day = DateTime.now().weekday;
  TimeOfDay _start = const TimeOfDay(hour: 7, minute: 30);
  TimeOfDay _end = const TimeOfDay(hour: 9, minute: 0);
  bool _submitting = false;

  bool get _isEditing => widget.isEditing;

  void _applyInitialValues() {
    final initial = widget.initialClass;
    if (initial == null) return;
    _day = initial.day;
    _start = _parseTime(initial.start);
    _end = _parseTime(initial.end);
    final title = (initial.title ?? initial.code ?? '').trim();
    if (title.isNotEmpty) {
      _title.text = title;
    }
    final room = initial.room?.trim();
    if (room != null) {
      _room.text = room;
    }
    _initialInstructorName = initial.instructor?.trim();
    if (_initialInstructorName != null &&
        _initialInstructorName!.isNotEmpty &&
        _instructorText.text.isEmpty) {
      _instructorText.text = _initialInstructorName!;
      _instructorManuallyEdited = false;
    }
  }

  TimeOfDay _parseTime(String raw) {
    final pieces = raw.split(':');
    final hour = pieces.isNotEmpty ? int.tryParse(pieces[0]) ?? 0 : 0;
    final minute = pieces.length > 1 ? int.tryParse(pieces[1]) ?? 0 : 0;
    final normalizedHour = hour < 0
        ? 0
        : hour > 23
            ? 23
            : hour;
    final normalizedMinute = minute < 0
        ? 0
        : minute > 59
            ? 59
            : minute;
    return TimeOfDay(hour: normalizedHour, minute: normalizedMinute);
  }

  @override
  void initState() {
    super.initState();
    _applyInitialValues();
    _loadInstructors();
  }

  @override
  void dispose() {
    _title.dispose();
    _room.dispose();
    _instructorText.dispose();
    super.dispose();
  }

  Future<void> _loadInstructors() async {
    if (mounted) {
      setState(() {
        _loadingInstructors = true;
        _instructorError = null;
      });
    }
    try {
      final list = await widget.api.fetchInstructors();
      if (!mounted) return;
      setState(() {
        _instructors = list;
        if (_selectedInstructorId == null && _initialInstructorName != null) {
          final lookup = _initialInstructorName!.toLowerCase();
          for (final option in list) {
            if (option.name.toLowerCase() == lookup) {
              _selectedInstructorId = option.id;
              if (!_instructorManuallyEdited) {
                _instructorText.text = option.name;
              }
              break;
            }
          }
          if (_selectedInstructorId == null &&
              !_instructorManuallyEdited &&
              _initialInstructorName!.isNotEmpty) {
            _instructorText.text = _initialInstructorName!;
          }
          _initialInstructorName = null;
        }
        if (_selectedInstructorId != null &&
            list.every((option) => option.id != _selectedInstructorId)) {
          _selectedInstructorId = null;
        }
        if (_selectedInstructorId != null && !_instructorManuallyEdited) {
          final selected = _findInstructorById(_selectedInstructorId);
          if (selected != null) {
            _instructorText.text = selected.name;
          }
        }
        if (_selectedInstructorId == null &&
            _instructorText.text.trim().isNotEmpty) {
          _instructorManuallyEdited = true;
        }
        _loadingInstructors = false;
      });
    } catch (error) {
      if (!mounted) return;
      AppLog.error(_scope, 'Failed to load instructors', error: error);
      setState(() {
        _loadingInstructors = false;
        _instructorError = 'Failed to load instructors. Tap to retry.';
      });
    }
  }

  String _format(TimeOfDay value) {
    final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _scopeLabel(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[(weekday - 1).clamp(0, 6)];
  }

  InstructorOption? _findInstructorById(String? id) {
    if (id == null) return null;
    for (final option in _instructors) {
      if (option.id == id) return option;
    }
    return null;
  }

  Future<void> _pickStart() async {
    final next = await showTimePicker(
      context: context,
      initialTime: _start,
      helpText: 'Class start time',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (next != null && mounted) {
      setState(() => _start = next);
    }
  }

  Future<void> _pickEnd() async {
    final next = await showTimePicker(
      context: context,
      initialTime: _end,
      helpText: 'Class end time',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (next != null && mounted) {
      setState(() => _end = next);
    }
  }

  Future<void> _fillWithTestData() async {
    final now = DateTime.now();
    final startDate = now.add(const Duration(minutes: 6));
    final endDate = startDate.add(const Duration(hours: 1));
    final startTime = TimeOfDay(hour: startDate.hour, minute: startDate.minute);
    final endTime = TimeOfDay(hour: endDate.hour, minute: endDate.minute);

    // Fetch random class from DB
    final randomClass = await widget.api.fetchRandomClass();

    if (!mounted) return;

    setState(() {
      if (randomClass != null) {
        _title.text = randomClass.title ?? randomClass.code ?? 'Test class';
        _room.text = randomClass.room ?? 'Room 203';
      } else {
        _title.text = 'Test class';
        _room.text = 'Room 203';
      }
      _day = startDate.weekday;
      _start = startTime;
      _end = endTime;
      _instructorText.text = 'Prof. Sample';
      _selectedInstructorId = null;
      _instructorManuallyEdited = true;
    });
  }

  // Exposed to the menu in the page header
  Future<void> triggerSave() => _save();
  void triggerAutofill() => _fillWithTestData();

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    // Validate that end time is after start time
    if (!isValidClassTimeRange(_start, _end)) {
      showAppSnackBar(
        context,
        'End time must be after start time.',
        type: AppSnackBarType.error,
      );
      return;
    }

    final instructorName = _instructorText.text.trim();
    final trimmedTitle = _title.text.trim();
    final trimmedRoom = _room.text.trim();
    final sanitizedInstructor = instructorName.isEmpty ? null : instructorName;
    final day = _day;
    final start = _format(_start);
    final end = _format(_end);
    final room = trimmedRoom.isEmpty ? null : trimmedRoom;

    final cached = widget.api.getCachedClasses() ?? const <ClassItem>[];
    final proposed = ClassItem(
      id: widget.initialClass?.id ?? -1,
      day: day,
      start: start,
      end: end,
      title: trimmedTitle,
      code: widget.initialClass?.code,
      room: room,
      instructor: sanitizedInstructor,
      enabled: true,
      isCustom: true,
    );
    for (final existing in cached) {
      if (!existing.enabled) continue;
      if (widget.initialClass != null &&
          existing.id == widget.initialClass!.id) {
        continue;
      }
      if (existing.day != day) continue;
      if (classesOverlap(proposed, existing)) {
        final conflictLabel =
            existing.title ?? existing.code ?? 'another class';
        showAppSnackBar(
          context,
          'This class overlaps with $conflictLabel. Adjust the time or day.',
          type: AppSnackBarType.error,
        );
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      if (_isEditing) {
        final existing = widget.initialClass;
        if (existing == null) {
          throw StateError('Missing initial class for edit submission.');
        }
        await widget.api.updateCustomClass(
          id: existing.id,
          day: day,
          startTime: start,
          endTime: end,
          title: trimmedTitle,
          room: room,
          instructor: sanitizedInstructor,
          instructorAvatar: _selectedInstructorAvatar,
        );
      } else {
        await widget.api.addCustomClass(
          day: day,
          startTime: start,
          endTime: end,
          title: trimmedTitle,
          room: room,
          instructor: sanitizedInstructor,
          instructorAvatar: _selectedInstructorAvatar,
        );
      }

      // Ensure the new class is visible to the scheduler
      await widget.api.refreshMyClasses();
      // Short delay to allow DB propagation if needed
      await Future.delayed(AppMotionSystem.deliberate);

      await NotifScheduler.resync(api: widget.api);
      if (!mounted) return;
      widget.onSaved(day);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        _isEditing ? 'Update failed: $e' : 'Save failed: $e',
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildInstructorField(
    ThemeData theme, {
    required InputDecoration Function(String label, {String? hint})
        decorationBuilder,
  }) {
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final helperStyle = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant.withValues(alpha: AppOpacity.glassCard),
    );

    final banner = () {
      if (_loadingInstructors) {
        return Container(
          padding: spacing.edgeInsetsSymmetric(
              horizontal: spacing.lg, vertical: spacing.lgPlus),
          decoration: BoxDecoration(
            borderRadius: AppTokens.radius.lg,
            color: colors.surfaceContainerHigh,
          ),
          child: Row(
            children: [
              SizedBox(
                width: AppTokens.componentSize.badgeMdPlus,
                height: AppTokens.componentSize.badgeMdPlus,
                child: CircularProgressIndicator(
                  strokeWidth: AppTokens.componentSize.progressStroke,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Text(
                  'Loading instructors...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      if (_instructorError != null) {
        return InkWell(
          borderRadius: AppTokens.radius.lg,
          onTap: _loadInstructors,
          child: Container(
            padding: spacing.edgeInsetsAll(spacing.lg),
            decoration: BoxDecoration(
              borderRadius: AppTokens.radius.lg,
              color: colors.error.withValues(alpha: AppOpacity.highlight),
            ),
            child: Row(
              children: [
                Icon(Icons.refresh_rounded, color: colors.error),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Text(
                    _instructorError!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return null;
    }();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (banner != null) ...[
          banner,
          SizedBox(height: AppTokens.spacing.md),
        ],
        DropdownButtonFormField<String?>(
          key: ValueKey<String?>(_selectedInstructorId),
          initialValue: _selectedInstructorId,
          decoration: decorationBuilder('Instructor (optional)'),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('No instructor'),
            ),
            ..._instructors.map(
              (option) => DropdownMenuItem<String?>(
                value: option.id,
                child: Text(option.name),
              ),
            ),
          ],
          isDense: true,
          isExpanded: true,
          onChanged: _loadingInstructors
              ? null
              : (value) {
                  setState(() {
                    _selectedInstructorId = value;
                    final selected = _findInstructorById(value);
                    if (selected != null) {
                      _instructorManuallyEdited = false;
                      _instructorText.text = selected.name;
                      _selectedInstructorAvatar = selected.avatarUrl;
                    } else {
                      _instructorText.clear();
                      _instructorManuallyEdited = false;
                      _selectedInstructorAvatar = null;
                    }
                  });
                },
        ),
        SizedBox(height: AppTokens.spacing.md),
        TextFormField(
          controller: _instructorText,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          enableSuggestions: false,
          autocorrect: false,
          decoration: decorationBuilder(
            'Custom instructor name',
            hint: 'Type a name or title',
          ),
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            setState(() {
              final trimmed = value.trim();
              if (trimmed.isEmpty) {
                _instructorManuallyEdited = false;
                _selectedInstructorId = null;
                _selectedInstructorAvatar = null;
                return;
              }
              _instructorManuallyEdited = true;
              if (_selectedInstructorId != null) {
                final selected = _findInstructorById(_selectedInstructorId);
                if (selected == null || selected.name.trim() != trimmed) {
                  _selectedInstructorId = null;
                  _selectedInstructorAvatar = null;
                }
              }
            });
          },
        ),
        SizedBox(height: AppTokens.spacing.sm),
        Text(
          'Pick from the list or enter a custom instructor name.',
          style: helperStyle,
        ),
      ],
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    String titleText,
    String helperText,
  ) {
    final colors = theme.colorScheme;
    final Widget leading = widget.isSheet
        ? IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: widget.onCancel,
          )
        : const SizedBox.shrink();

    final trailingGap = widget.isSheet
        ? SizedBox(width: AppTokens.spacing.quad)
        : SizedBox(width: AppTokens.spacing.md);

    return Column(
      crossAxisAlignment:
          widget.isSheet ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            leading,
            Expanded(
              child: Text(
                titleText,
                textAlign: widget.isSheet ? TextAlign.center : TextAlign.left,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: AppTokens.fontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
            ),
            trailingGap,
          ],
        ),
        SizedBox(height: AppTokens.spacing.sm),
        Text(
          helperText,
          textAlign: widget.isSheet ? TextAlign.center : TextAlign.left,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isEditing = _isEditing;
    final titleText = isEditing ? 'Edit custom class' : 'Add custom class';
    final helperText = isEditing
        ? 'Update the session details for this custom class.'
        : 'Enter the session details. You can edit or remove custom classes from the schedules tab later.';
    final fillColor = theme.brightness == Brightness.dark
        ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.prominent)
        : colors.surfaceContainerHigh;
    final borderColor =
        colors.outlineVariant.withValues(alpha: AppOpacity.fieldBorder);

    InputDecoration decorationFor(String label, {String? hint}) =>
        InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: fillColor,
          contentPadding: spacing.edgeInsetsSymmetric(
              horizontal: spacing.lg, vertical: spacing.lg),
          border: OutlineInputBorder(
            borderRadius: AppTokens.radius.lg,
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppTokens.radius.lg,
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppTokens.radius.lg,
            borderSide: BorderSide(
                color: colors.primary,
                width: AppTokens.componentSize.dividerBold),
          ),
        );

    final formSections = <Widget>[];
    if (widget.isSheet) {
      formSections
        ..add(_buildHeader(theme, titleText, helperText))
        ..add(SizedBox(height: AppTokens.spacing.lg));
    }

    formSections.addAll([
      Container(
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SectionHeader(
                    title: 'Class details',
                    subtitle: 'Displayed across your schedules',
                  ),
                ),
                if (kDebugMode && !isEditing)
                  IconButton(
                    icon: const Icon(Icons.auto_fix_high_rounded),
                    onPressed: _submitting ? null : _fillWithTestData,
                  ),
              ],
            ),
            SizedBox(height: AppTokens.spacing.md),
            TextFormField(
              controller: _title,
              decoration: decorationFor('Class title', hint: 'e.g. Calculus 2'),
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            SizedBox(height: AppTokens.spacing.lg),
            TextFormField(
              controller: _room,
              decoration: decorationFor('Room (optional)'),
              textInputAction: TextInputAction.next,
            ),
          ],
        ),
      ),
      SizedBox(height: AppTokens.spacing.lg),
      Container(
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: 'Schedule',
              subtitle: 'Tell us when this class usually happens',
            ),
            SizedBox(height: AppTokens.spacing.md),
            InkWell(
              onTap: _submitting ? null : _pickDay,
              borderRadius: AppTokens.radius.lg,
              child: Container(
                padding: spacing.edgeInsetsSymmetric(
                    horizontal: spacing.lg,
                    vertical:
                        spacing.md + AppTokens.componentSize.paddingAdjust),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: AppTokens.radius.lg,
                  border: Border.all(
                    color: colors.outlineVariant
                        .withValues(alpha: AppOpacity.ghost),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _scopeLabel(_day),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppTokens.spacing.lg),
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: 'Starts',
                    value: _format(_start),
                    icon: Icons.play_arrow_rounded,
                    onTap: _submitting ? null : _pickStart,
                  ),
                ),
                SizedBox(width: AppTokens.spacing.md),
                Expanded(
                  child: _TimeField(
                    label: 'Ends',
                    value: _format(_end),
                    icon: Icons.flag_rounded,
                    onTap: _submitting ? null : _pickEnd,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.spacing.lg),
            Row(
              children: [
                Expanded(
                  child: InfoChip(
                    icon: Icons.calendar_month_rounded,
                    label: _scopeLabel(_day),
                  ),
                ),
                SizedBox(width: AppTokens.spacing.md),
                Expanded(
                  child: InfoChip(
                    icon: Icons.schedule_rounded,
                    label: '${_format(_start)} - ${_format(_end)}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      SizedBox(height: AppTokens.spacing.lg),
      Container(
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: 'Instructor',
              subtitle: 'Optional details to complete your schedule',
            ),
            SizedBox(height: AppTokens.spacing.md),
            _buildInstructorField(theme, decorationBuilder: decorationFor),
          ],
        ),
      ),
      if (widget.includeButtons) ...[
        SizedBox(height: AppTokens.spacing.xl),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: _submitting ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize:
                      Size.fromHeight(AppTokens.componentSize.buttonSm),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTokens.radius.xl,
                  ),
                ),
                child: Text(
                  _submitting
                      ? (isEditing ? 'Updating...' : 'Saving...')
                      : (isEditing ? 'Update class' : 'Save class'),
                ),
              ),
            ),
            SizedBox(width: AppTokens.spacing.md),
            Expanded(
              child: OutlinedButton(
                onPressed: _submitting ? null : widget.onCancel,
                style: OutlinedButton.styleFrom(
                  minimumSize:
                      Size.fromHeight(AppTokens.componentSize.buttonSm),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTokens.radius.xl,
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ],
    ]);

    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: formSections,
      ),
    );
  }

  Future<void> _pickDay() async {
    final theme = Theme.of(context);
    final spacing = AppTokens.spacing;

    final picked = await AppModal.alert<int>(
      context: context,
      useRootNavigator: !widget.isSheet,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: spacing.edgeInsetsAll(spacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppLayout.sheetMaxWidth,
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.6,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? theme.colorScheme.surfaceContainerHigh
                    : theme.colorScheme.surface,
                borderRadius: AppTokens.radius.md,
                border: Border.all(
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.outline.withValues(alpha: AppOpacity.overlay)
                      : theme.colorScheme.outline,
                  width: theme.brightness == Brightness.dark
                      ? AppTokens.componentSize.divider
                      : AppTokens.componentSize.dividerThin,
                ),
                boxShadow: theme.brightness == Brightness.dark
                    ? null
                    : [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(alpha: AppOpacity.veryFaint),
                          blurRadius: AppTokens.shadow.lg,
                          offset: AppShadowOffset.sm,
                        ),
                      ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: spacing.edgeInsetsAll(spacing.xxl),
                    child: Text(
                      'Select day',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                      ),
                    ),
                  ),
                  ...List.generate(7, (index) {
                    final dayValue = index + 1;
                    final isSelected = dayValue == _day;
                    return InkWell(
                      onTap: () => Navigator.of(dialogContext).pop(dayValue),
                      child: Padding(
                        padding: spacing.edgeInsetsSymmetric(
                          horizontal: spacing.xl,
                          vertical: spacing.md,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _scopeLabel(dayValue),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: isSelected
                                      ? AppTokens.fontWeight.semiBold
                                      : AppTokens.fontWeight.regular,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_rounded,
                                color: theme.colorScheme.primary,
                                size: AppTokens.iconSize.md,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  Padding(
                    padding: spacing.edgeInsetsAll(spacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _day = picked);
    }
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return InkWell(
      borderRadius: AppTokens.radius.lg,
      onTap: onTap,
      child: Container(
        padding: AppTokens.spacing.edgeInsetsSymmetric(
          horizontal: AppTokens.spacing.md,
          vertical: AppTokens.spacing.md,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: AppTokens.radius.lg,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: AppOpacity.ghost),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: AppTokens.componentSize.avatarSm,
              height: AppTokens.componentSize.avatarSm,
              decoration: BoxDecoration(
                borderRadius: AppTokens.radius.md,
                color: colors.primary.withValues(alpha: AppOpacity.statusBg),
              ),
              alignment: Alignment.center,
              child: Icon(icon,
                  color: colors.primary, size: AppTokens.iconSize.sm),
            ),
            SizedBox(width: AppTokens.spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppTokens.spacing.xs),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                        fontSize: AppTokens.typography.subtitle.fontSize,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppTokens.spacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              size: AppTokens.iconSize.md,
              color: colors.onSurfaceVariant.withValues(alpha: AppOpacity.soft),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ClassMenuAction { save, cancel, autofill }
