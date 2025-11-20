// add_class_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app/routes.dart';
import '../services/notif_scheduler.dart';
import '../services/schedule_api.dart';
import '../services/profile_cache.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';
import '../ui/theme/card_styles.dart';
import '../utils/nav.dart';

bool isValidClassTimeRange(TimeOfDay start, TimeOfDay end) {
  final startMinutes = start.hour * 60 + start.minute;
  final endMinutes = end.hour * 60 + end.minute;
  return endMinutes > startMinutes;
}

class AddClassPage extends StatefulWidget {
  const AddClassPage({super.key, required this.api, this.initialClass});

  final ScheduleApi api;
  final ClassItem? initialClass;

  @override
  State<AddClassPage> createState() => _AddClassPageState();
}

class AddClassSheet extends StatelessWidget {
  const AddClassSheet({
    super.key,
    required this.api,
    this.initialClass,
  });

  final ScheduleApi api;
  final ClassItem? initialClass;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final spacing = AppTokens.spacing;
    final cardBackground = elevatedCardBackground(theme, solid: true);
    final borderColor = elevatedCardBorder(theme, solid: true);
    final maxHeight = media.size.height -
        (AppTokens.spacing.xxxl * 2 + media.padding.top + media.padding.bottom);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: maxHeight.clamp(520.0, double.infinity),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: AppTokens.radius.xl,
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.35 : 0.18,
                  ),
                  blurRadius: 28,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: ClipRRect(
                borderRadius: AppTokens.radius.xl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              spacing.xl,
                              spacing.xl,
                              spacing.xl,
                              media.viewInsets.bottom +
                                  media.padding.bottom +
                                  spacing.xl,
                            ),
                            child: AddClassForm(
                              api: api,
                              initialClass: initialClass,
                              isSheet: true,
                              onCancel: () => Navigator.of(context).pop(false),
                              onSaved: (created) =>
                                  Navigator.of(context).pop(created),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Container(
                                height: spacing.lg,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      cardBackground,
                                      cardBackground.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Container(
                                height: spacing.lg,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      cardBackground,
                                      cardBackground.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
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

class _AddClassPageState extends State<AddClassPage> with RouteAware {
  final _formKey = GlobalKey<_AddClassFormState>();

  String? _studentName;
  String? _studentEmail;
  String? _avatarUrl;
  bool _profileHydrated = false;
  VoidCallback? _profileListener;
  PageRoute<dynamic>? _routeSubscription;

  bool get _isEditing => widget.initialClass != null;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _profileListener = () {
      final profile = ProfileCache.notifier.value;
      _applyProfile(profile);
    };
    ProfileCache.notifier.addListener(_profileListener!);
    _applyProfile(ProfileCache.notifier.value);
  }

  @override
  void dispose() {
    if (_profileListener != null) {
      ProfileCache.notifier.removeListener(_profileListener!);
    }
    if (_routeSubscription != null) {
      routeObserver.unsubscribe(this);
      _routeSubscription = null;
    }
    super.dispose();
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

  Future<void> _loadProfile({bool refresh = false}) async {
    try {
      final profile = await ProfileCache.load(forceRefresh: refresh);
      _applyProfile(profile);
    } catch (_) {
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
    final name = profile.name;
    final email = profile.email;
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
      tooltip: 'Class options',
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
            children: const [
              Icon(Icons.save_outlined, size: 18),
              SizedBox(width: 12),
              Text('Save class'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _ClassMenuAction.cancel,
          child: Row(
            children: const [
              Icon(Icons.close_rounded, size: 18),
              SizedBox(width: 12),
              Text('Cancel'),
            ],
          ),
        ),
        if (kDebugMode)
          PopupMenuItem(
            value: _ClassMenuAction.autofill,
            child: Row(
              children: const [
                Icon(Icons.auto_fix_high_rounded, size: 18),
                SizedBox(width: 12),
                Text('Autofill sample'),
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
      iconColor: colors.onSurfaceVariant.withValues(alpha: 0.9),
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
          height: 48,
          avatarRadius: 20,
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'SFProRounded',
            fontWeight: FontWeight.w700,
            color: colors.primary,
            fontSize: 20,
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
          trailing: SizedBox(height: 36, child: menuButton),
          child: AddClassForm(
            key: _formKey,
            api: widget.api,
            initialClass: widget.initialClass,
            isSheet: false,
            onCancel: () => Navigator.of(context).maybePop(),
            onSaved: (created) => Navigator.of(context).pop(created),
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
                minHeight: 48,
              ),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: PrimaryButton(
                label: _isEditing ? 'Save class' : 'Add class',
                onPressed: () => _formKey.currentState?.triggerSave(),
                minHeight: 48,
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
    final cardBackground = elevatedCardBackground(theme);
    final borderColor = elevatedCardBorder(theme);

    return CardX(
      padding: const EdgeInsets.all(20),
      backgroundColor: cardBackground,
      borderColor: borderColor,
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
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMM d').format(DateTime.now()),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 4),
                SizedBox(height: 36, child: trailing!),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: AppTokens.radius.lg,
            ),
            child: Row(
              children: [
                Icon(Icons.class_outlined,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.8)),
                const SizedBox(width: 12),
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
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

// ===== FORM (unchanged logic; added triggerSave/triggerAutofill for menu) =====
class AddClassForm extends StatefulWidget {
  const AddClassForm({
    super.key,
    required this.api,
    this.initialClass,
    required this.onCancel,
    required this.onSaved,
    required this.isSheet,
  });

  final ScheduleApi api;
  final ClassItem? initialClass;
  final VoidCallback onCancel;
  final ValueChanged<bool> onSaved;
  final bool isSheet;

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
      debugPrint('AddClass: failed to load instructors -> $error');
      setState(() {
        _loadingInstructors = false;
        _instructorError = 'Failed to load instructors. Tap to retry.';
      });
    }
  }

  String _format(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

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
    );
    if (next != null && mounted) {
      setState(() => _end = next);
    }
  }

  void _fillWithTestData() {
    final now = DateTime.now();
    final startDate = now.add(const Duration(minutes: 6));
    final endDate = startDate.add(const Duration(hours: 1));
    final startTime = TimeOfDay(hour: startDate.hour, minute: startDate.minute);
    final endTime = TimeOfDay(hour: endDate.hour, minute: endDate.minute);

    setState(() {
      _title.text = 'Test class';
      _room.text = 'Room 203';
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
    if (!isValidClassTimeRange(_start, _end)) {
      showAppSnackBar(
        context,
        'End time must be after start time.',
        type: AppSnackBarType.error,
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final instructorName = _instructorText.text.trim();
      final trimmedTitle = _title.text.trim();
      final trimmedRoom = _room.text.trim();
      final sanitizedInstructor =
          instructorName.isEmpty ? null : instructorName;
      final day = _day;
      final start = _format(_start);
      final end = _format(_end);
      final room = trimmedRoom.isEmpty ? null : trimmedRoom;

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
        );
      } else {
        await widget.api.addCustomClass(
          day: day,
          startTime: start,
          endTime: end,
          title: trimmedTitle,
          room: room,
          instructor: sanitizedInstructor,
        );
      }
      await NotifScheduler.resync();
      if (!mounted) return;
      widget.onSaved(true);
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
    final helperStyle = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant.withValues(alpha: 0.78),
    );

    final banner = () {
      if (_loadingInstructors) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: AppTokens.radius.lg,
            color: colors.surfaceContainerHigh,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              ),
              const SizedBox(width: 12),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: AppTokens.radius.lg,
              color: colors.error.withValues(alpha: 0.08),
            ),
            child: Row(
              children: [
                Icon(Icons.refresh_rounded, color: colors.error),
                const SizedBox(width: 12),
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
          const SizedBox(height: 12),
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
                    } else {
                      _instructorText.clear();
                      _instructorManuallyEdited = false;
                    }
                  });
                },
        ),
        const SizedBox(height: 12),
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
                return;
              }
              _instructorManuallyEdited = true;
              if (_selectedInstructorId != null) {
                final selected = _findInstructorById(_selectedInstructorId);
                if (selected == null || selected.name.trim() != trimmed) {
                  _selectedInstructorId = null;
                }
              }
            });
          },
        ),
        const SizedBox(height: 8),
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

    final trailingGap =
        widget.isSheet ? const SizedBox(width: 48) : const SizedBox(width: 12);

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
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ),
            trailingGap,
          ],
        ),
        const SizedBox(height: 8),
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
    final isEditing = _isEditing;
    final titleText = isEditing ? 'Edit custom class' : 'Add custom class';
    final helperText = isEditing
        ? 'Update the session details for this custom class.'
        : 'Enter the session details. You can edit or remove custom classes from the schedules tab later.';
    final fillColor = theme.brightness == Brightness.dark
        ? colors.surfaceContainerHighest.withValues(alpha: 0.85)
        : colors.surfaceContainerHigh;
    final borderColor = colors.outlineVariant.withValues(alpha: 0.32);

    InputDecoration decorationFor(String label, {String? hint}) =>
        InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: fillColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            borderSide: BorderSide(color: colors.primary, width: 2),
          ),
        );

    final formSections = <Widget>[];
    if (widget.isSheet) {
      formSections
        ..add(_buildHeader(theme, titleText, helperText))
        ..add(const SizedBox(height: 16));
    }

    formSections.addAll([
      CardX(
        backgroundColor: colors.surfaceContainerHigh,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SectionHeader(
                    title: 'Class details',
                    subtitle: 'Displayed across your schedules',
                  ),
                ),
                if (kDebugMode && !isEditing)
                  IconButton(
                    icon: const Icon(Icons.auto_fix_high_rounded),
                    tooltip: 'Auto-fill sample data',
                    onPressed: _submitting ? null : _fillWithTestData,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _title,
              decoration: decorationFor('Class title', hint: 'e.g. Calculus 2'),
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _room,
              decoration: decorationFor('Room (optional)'),
              textInputAction: TextInputAction.next,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      CardX(
        backgroundColor: colors.surfaceContainerHigh,
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(
              title: 'Schedule',
              subtitle: 'Tell us when this class usually happens',
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              initialValue: _day,
              decoration: decorationFor('Day of the week'),
              items: const [
                DropdownMenuItem<int>(value: 1, child: Text('Monday')),
                DropdownMenuItem<int>(value: 2, child: Text('Tuesday')),
                DropdownMenuItem<int>(value: 3, child: Text('Wednesday')),
                DropdownMenuItem<int>(value: 4, child: Text('Thursday')),
                DropdownMenuItem<int>(value: 5, child: Text('Friday')),
                DropdownMenuItem<int>(value: 6, child: Text('Saturday')),
                DropdownMenuItem<int>(value: 7, child: Text('Sunday')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _day = value);
              },
            ),
            const SizedBox(height: 16),
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
                const SizedBox(width: 12),
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
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ScopeChip(
                  icon: Icons.calendar_month_rounded,
                  label: _scopeLabel(_day),
                ),
                _ScopeChip(
                  icon: Icons.schedule_rounded,
                  label: '${_format(_start)} - ${_format(_end)}',
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      CardX(
        backgroundColor: colors.surfaceContainerHigh,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(
              title: 'Instructor',
              subtitle: 'Optional details to complete your schedule',
            ),
            const SizedBox(height: 10),
            _buildInstructorField(theme, decorationBuilder: decorationFor),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: _submitting ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
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
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: _submitting ? null : widget.onCancel,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTokens.radius.xl,
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: AppTokens.radius.lg,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colors.primary.withValues(alpha: 0.16),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: colors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ClassMenuAction { save, cancel, autofill }
