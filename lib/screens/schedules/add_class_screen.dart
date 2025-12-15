// add_class_page.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../services/notification_scheduler.dart';
import '../../services/schedule_repository.dart';
import '../../services/profile_cache.dart';
import '../../services/telemetry_service.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/motion.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/app_log.dart';
import '../../utils/nav.dart';
import '../../utils/schedule_overlap.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    final menuButton = _buildMenuButton(
      iconColor:
          palette.muted.withValues(alpha: AppOpacity.prominent),
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
          textStyle: AppTokens.typography.title.copyWith(
            fontFamily: 'SFProRounded',
            fontWeight: AppTokens.fontWeight.bold,
            color: colors.primary,
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
            onSaved: (day) =>
                Navigator.of(context, rootNavigator: true).pop(day),
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
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.initialClass != null;
    final cardBackground =
        isDark ? colors.surfaceContainerHigh : colors.surface;

    return ModalShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: spacing.edgeInsetsOnly(
              left: spacing.xl,
              right: spacing.xl,
              top: spacing.xl,
              bottom: spacing.md,
            ),
            child: SheetHeaderRow(
              title: isEditing ? 'Edit custom class' : 'Add custom class',
              subtitle: isEditing
                  ? 'Update your class details'
                  : 'Create a new class session',
              icon: isEditing ? Icons.edit_rounded : Icons.add_rounded,
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
          // Form content
          Flexible(
            child: SingleChildScrollView(
              padding: spacing.edgeInsetsOnly(
                left: spacing.xl,
                right: spacing.xl,
                bottom: spacing.md,
              ),
              child: AddClassForm(
                key: _formKey,
                api: widget.api,
                initialClass: widget.initialClass,
                isSheet: true,
                includeButtons: false,
                onCancel: () => Navigator.of(context).maybePop(),
                onSaved: (day) =>
                    Navigator.of(context, rootNavigator: true).pop(day),
              ),
            ),
          ),
          // Action buttons
          Container(
            padding: spacing.edgeInsetsOnly(
              left: spacing.xl,
              right: spacing.xl,
              top: spacing.md,
              bottom: spacing.xl,
            ),
            decoration: BoxDecoration(
              color: cardBackground,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? colors.outline.withValues(alpha: AppOpacity.overlay)
                      : colors.outlineVariant.withValues(alpha: AppOpacity.ghost),
                  width: AppTokens.componentSize.dividerThin,
                ),
              ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              label: _submitting
                                  ? (isEditing ? 'Saving...' : 'Adding...')
                                  : (isEditing ? 'Save class' : 'Save class'),
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
                              onPressed: _submitting
                                  ? null
                                  : () => Navigator.of(context).maybePop(),
                              minHeight: AppTokens.componentSize.buttonMd,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    return SurfaceCard(
      padding: AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.xl),
      borderRadius: AppTokens.radius.md,
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
                      style: AppTokens.typography.title.copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                        letterSpacing: AppLetterSpacing.snug,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: AppTokens.spacing.xs),
                    Text(
                      DateFormat('EEEE, MMM d').format(DateTime.now()),
                      style: AppTokens.typography.subtitle.copyWith(
                        color: palette.muted,
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
                    color: palette.muted
                        .withValues(alpha: AppOpacity.prominent)),
                SizedBox(width: AppTokens.spacing.md),
                Expanded(
                  child: Text(
                    subtitle,
                    style: AppTokens.typography.body.copyWith(
                      color: palette.muted,
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
  String? _formError;

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
    final next = await showAppTimePicker(
      context: context,
      initialTime: _start,
      helpText: 'Class start time',
    );
    if (next != null && mounted) {
      setState(() => _start = next);
    }
  }

  Future<void> _pickEnd() async {
    final next = await showAppTimePicker(
      context: context,
      initialTime: _end,
      helpText: 'Class end time',
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
    setState(() => _formError = null);
    if (!_form.currentState!.validate()) return;

    // Validate that end time is after start time
    if (!isValidClassTimeRange(_start, _end)) {
      setState(() => _formError = 'End time must be after start time.');
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
        setState(() => _formError =
            'This class overlaps with $conflictLabel. Adjust the time or day.');
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

      if (mounted) {
        widget.onSaved(day);
      }
      unawaited(_postSaveSync());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _formError = _isEditing
            ? 'Update failed: $e'
            : 'Save failed: $e';
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _postSaveSync() async {
    try {
      await widget.api.refreshMyClasses();
      await Future.delayed(AppMotionSystem.deliberate);
      await NotifScheduler.resync(api: widget.api);
    } catch (error, stack) {
      AppLog.error(_scope, 'post_save_sync_failed', error: error, stack: stack);
    }
  }

  Widget _buildInstructorField(
    ThemeData theme, {
    required InputDecoration Function(String label, {String? hint})
        decorationBuilder,
  }) {
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final helperStyle = AppTokens.typography.caption.copyWith(
      color: palette.muted.withValues(alpha: AppOpacity.glassCard),
    );

    final banner = () {
      if (_loadingInstructors) {
        return SurfaceCard(
          padding: spacing.edgeInsetsSymmetric(
              horizontal: spacing.lg, vertical: spacing.lgPlus),
          borderRadius: AppTokens.radius.lg,
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
                  style: AppTokens.typography.body.copyWith(
                    color: palette.muted,
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
          child: SurfaceCard(
            padding: spacing.edgeInsetsAll(spacing.lg),
            borderRadius: AppTokens.radius.lg,
            backgroundColor: palette.danger.withValues(alpha: AppOpacity.highlight),
            child: Row(
              children: [
                Icon(Icons.refresh_rounded, color: palette.danger),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Text(
                    _instructorError!,
                    style: AppTokens.typography.body.copyWith(
                      color: palette.danger,
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
        InkWell(
          onTap: _loadingInstructors
              ? null
              : () async {
                  // Build options list: null for "No instructor" + all instructors
                  final options = <String?>[null, ..._instructors.map((i) => i.id)];
                  final picked = await showAppOptionPicker<String?>(
                    context: context,
                    options: options,
                    selectedValue: _selectedInstructorId,
                    labelBuilder: (value) {
                      if (value == null) return 'No instructor';
                      final instructor = _findInstructorById(value);
                      return instructor?.name ?? 'Unknown';
                    },
                    title: 'Select instructor',
                    icon: Icons.person_rounded,
                  );
                  if (picked != _selectedInstructorId) {
                    setState(() {
                      _selectedInstructorId = picked;
                      final selected = _findInstructorById(picked);
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
                  }
                },
          borderRadius: AppTokens.radius.lg,
          child: SurfaceCard(
            padding: spacing.edgeInsetsSymmetric(
              horizontal: spacing.lg,
              vertical: spacing.lg,
            ),
            borderRadius: AppTokens.radius.lg,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instructor (optional)',
                        style: AppTokens.typography.caption.copyWith(
                          color: palette.muted,
                        ),
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        _selectedInstructorId == null
                            ? 'No instructor'
                            : _findInstructorById(_selectedInstructorId)?.name ?? 'Unknown',
                        style: AppTokens.typography.body.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: palette.muted,
                ),
              ],
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isEditing = _isEditing;
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
    // Note: SheetHeaderRow is handled by AddClassSheet wrapper, not the form

    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    formSections.addAll([
      if (_formError != null) ...[
        ErrorBanner(message: _formError!),
        SizedBox(height: spacing.md),
      ],
      SurfaceCard(
        variant: SurfaceCardVariant.elevated,
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
      SurfaceCard(
        variant: SurfaceCardVariant.elevated,
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
              child: SurfaceCard(
                padding: spacing.edgeInsetsSymmetric(
                    horizontal: spacing.lg,
                    vertical:
                        spacing.md + AppTokens.componentSize.paddingAdjust),
                borderRadius: AppTokens.radius.lg,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _scopeLabel(_day),
                        style: AppTokens.typography.body.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: palette.muted,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppTokens.spacing.lg),
            Row(
              children: [
                Expanded(
                  child: TimeFieldTile(
                    label: 'Starts',
                    value: _format(_start),
                    icon: Icons.play_arrow_rounded,
                    onTap: _submitting ? null : _pickStart,
                  ),
                ),
                SizedBox(width: AppTokens.spacing.md),
                Expanded(
                  child: TimeFieldTile(
                    label: 'Ends',
                    value: _format(_end),
                    icon: Icons.flag_rounded,
                    onTap: _submitting ? null : _pickEnd,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      SizedBox(height: AppTokens.spacing.lg),
      SurfaceCard(
        variant: SurfaceCardVariant.elevated,
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
              child: PrimaryButton(
                label: isEditing ? 'Update class' : 'Save class',
                onPressed: _submitting ? null : _save,
                loading: _submitting,
                loadingLabel: isEditing ? 'Updating...' : 'Saving...',
                minHeight: AppTokens.componentSize.buttonSm,
              ),
            ),
            SizedBox(width: AppTokens.spacing.md),
            Expanded(
              child: SecondaryButton(
                label: 'Cancel',
                onPressed: _submitting ? null : widget.onCancel,
                minHeight: AppTokens.componentSize.buttonSm,
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
    final days = List.generate(7, (i) => i + 1);
    final picked = await showAppOptionPicker<int>(
      context: context,
      options: days,
      selectedValue: _day,
      labelBuilder: _scopeLabel,
      title: 'Select day',
      icon: Icons.calendar_today_rounded,
    );

    if (picked != null) {
      setState(() => _day = picked);
    }
  }
}


enum _ClassMenuAction { save, cancel, autofill }
