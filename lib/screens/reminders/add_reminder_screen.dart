import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/reminders_repository.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';

class AddReminderPage extends StatelessWidget {
  const AddReminderPage({
    super.key,
    required this.api,
    this.editing,
  });

  final RemindersApi api;
  final ReminderEntry? editing;

  @override
  Widget build(BuildContext context) {
    final hero = ScreenHeroCard(
      title: editing == null ? 'New reminder' : 'Edit reminder',
      subtitle:
          'Capture tasks, labs, or exams and stay aligned with your dashboard.',
    );

    return ScreenShell(
      screenName: 'add_reminder',
      hero: hero,
      sections: [
        ScreenSection(
          decorated: false,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppLayout.contentMaxWidthMedium),
            child: AddReminderForm(
              api: api,
              editing: editing,
              isSheet: false,
              onCancel: () => Navigator.of(context).maybePop(),
              onSaved: (reminderId) =>
                  Navigator.of(context, rootNavigator: true).pop(reminderId),
            ),
          ),
        ),
      ],
    );
  }
}

class AddReminderSheet extends StatefulWidget {
  const AddReminderSheet({
    super.key,
    required this.api,
    this.editing,
  });

  final RemindersApi api;
  final ReminderEntry? editing;

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  final _formKey = GlobalKey<_AddReminderFormState>();
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.editing != null;
    final cardBackground = isDark ? colors.surfaceContainerHigh : colors.surface;

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
              title: isEditing ? 'Edit reminder' : 'New reminder',
              subtitle: isEditing
                  ? 'Update your reminder details'
                  : 'Create a reminder and we will notify you before it is due',
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
              child: AddReminderForm(
                key: _formKey,
                api: widget.api,
                editing: widget.editing,
                isSheet: true,
                includeButtons: false,
                onCancel: () => Navigator.of(context).maybePop(),
                onSaved: (reminderId) =>
                    Navigator.of(context, rootNavigator: true).pop(reminderId),
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
                        ? (isEditing ? 'Saving...' : 'Saving...')
                        : (isEditing ? 'Save reminder' : 'Save reminder'),
                    onPressed: _submitting
                        ? null
                        : () {
                            setState(() => _submitting = true);
                            _formKey.currentState?.triggerSave().whenComplete(() {
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
                    onPressed:
                        _submitting ? null : () => Navigator.of(context).maybePop(),
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

class AddReminderForm extends StatefulWidget {
  const AddReminderForm({
    super.key,
    required this.api,
    this.editing,
    required this.isSheet,
    required this.onCancel,
    required this.onSaved,
    this.includeButtons = true,
  });

  final RemindersApi api;
  final ReminderEntry? editing;
  final bool isSheet;
  final VoidCallback onCancel;

  /// Called with the new reminder ID when creating, or null when editing.
  final ValueChanged<int?> onSaved;
  final bool includeButtons;

  @override
  State<AddReminderForm> createState() => _AddReminderFormState();
}

class _AddReminderFormState extends State<AddReminderForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String? _whenError;
  bool _submitting = false;
  String? _formError;

  final _dateFormat = DateFormat('EEE, MMM d');
  final _timeFormat = DateFormat('h:mm a');

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    if (editing != null) {
      _titleController.text = editing.title;
      _notesController.text = editing.details ?? '';
      _selectedDate = editing.dueAt;
      _selectedTime = TimeOfDay.fromDateTime(editing.dueAt);
    } else {
      final now = DateTime.now();
      final nextHour = now.add(const Duration(hours: 1));
      _selectedDate = _roundToNearestDate(nextHour);
      _selectedTime = TimeOfDay.fromDateTime(nextHour);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  static DateTime _roundToNearestDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  Future<void> triggerSave() => _submit();
  void triggerAutofill() => _fillWithTestData();

  void _fillWithTestData() {
    final titles = [
      'Submit assignment',
      'Buy groceries',
      'Call mom',
      'Meeting with team',
      'Doctor appointment',
      'Pay bills',
      'Clean room',
      'Study for exam',
    ];
    final notes = [
      'Don\'t forget to bring the documents.',
      'Milk, eggs, bread, and cheese.',
      'Ask about the weekend plans.',
      'Discuss the new project requirements.',
      'Checkup at 3 PM.',
      'Electricity and internet bills.',
      'Vacuum and dust.',
      'Chapters 4-6.',
    ];
    final random = Random();
    final index = random.nextInt(titles.length);

    setState(() {
      _titleController.text = titles[index];
      _notesController.text = notes[index];

      final now = DateTime.now();
      final randomDay = now.add(Duration(days: random.nextInt(7)));
      final randomHour = random.nextInt(24);
      final randomMinute = random.nextInt(60);

      _selectedDate = _roundToNearestDate(randomDay);
      _selectedTime = TimeOfDay(hour: randomHour, minute: randomMinute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final editing = widget.editing;
    final fieldFill = isDark
        ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.prominent)
        : colors.surfaceContainerHigh;
    final fieldBorder =
        colors.outlineVariant.withValues(alpha: AppOpacity.fieldBorder);
    final spacing = AppTokens.spacing;

    InputDecoration decorationFor(String label, {String? hint}) =>
        InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: fieldFill,
          contentPadding: spacing.edgeInsetsSymmetric(
              horizontal: spacing.lg, vertical: spacing.lg),
          border: OutlineInputBorder(
            borderRadius: AppTokens.radius.lg,
            borderSide: BorderSide(color: fieldBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppTokens.radius.lg,
            borderSide: BorderSide(color: fieldBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppTokens.radius.lg,
            borderSide: BorderSide(
                color: colors.primary,
                width: AppTokens.componentSize.dividerBold),
          ),
        );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_formError != null) ...[
            ErrorBanner(message: _formError!),
            SizedBox(height: AppTokens.spacing.md),
          ],
          // Reminder details card
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
                        title: 'Reminder details',
                        subtitle: 'Shown across the app',
                      ),
                    ),
                    if (kDebugMode && editing == null)
                      IconButton(
                        icon: const Icon(Icons.auto_fix_high_rounded),
                        onPressed: _submitting ? null : _fillWithTestData,
                      ),
                  ],
                ),
                SizedBox(height: AppTokens.spacing.md),
                TextFormField(
                  controller: _titleController,
                  decoration: decorationFor('Title', hint: 'e.g. Submit quiz'),
                  maxLength: 160,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                SizedBox(height: AppTokens.spacing.lg),
                TextFormField(
                  controller: _notesController,
                  decoration:
                      decorationFor('Notes (optional)', hint: 'Add details'),
                  maxLines: 3,
                  minLines: 2,
                ),
              ],
            ),
          ),
          SizedBox(height: AppTokens.spacing.lg),
          // Reminder time card
          SurfaceCard(
            variant: SurfaceCardVariant.elevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  title: 'Reminder time',
                  subtitle: 'We will notify you at this time',
                ),
                SizedBox(height: AppTokens.spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TimeFieldTile(
                        label: 'Date',
                        value: _dateFormat.format(_selectedDate),
                        icon: Icons.calendar_month_rounded,
                        onTap: _submitting ? null : _pickDate,
                      ),
                    ),
                    SizedBox(width: AppTokens.spacing.md),
                    Expanded(
                      child: TimeFieldTile(
                        label: 'Time',
                        value: _timeFormat.format(_combine()),
                        icon: Icons.schedule_rounded,
                        onTap: _submitting ? null : _pickTime,
                      ),
                    ),
                  ],
                ),
                if (_whenError != null) ...[
                  SizedBox(height: AppTokens.spacing.md),
                  Text(
                    _whenError!,
                    style: AppTokens.typography.caption.copyWith(
                      color: palette.danger,
                    ),
                  ),
                ],
                SizedBox(height: AppTokens.spacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: InfoChip(
                        icon: Icons.today_outlined,
                        label: _friendlyDateSummary(),
                      ),
                    ),
                    SizedBox(width: AppTokens.spacing.md),
                    Expanded(
                      child: InfoChip(
                        icon: Icons.access_time_filled_rounded,
                        label: _friendlyTimeSummary(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.includeButtons) ...[
            SizedBox(height: AppTokens.spacing.xl),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: _submitting
                        ? (editing == null ? 'Saving...' : 'Saving...')
                        : (editing == null ? 'Save reminder' : 'Save reminder'),
                    onPressed: _submitting ? null : _submit,
                    minHeight: AppTokens.componentSize.buttonMd,
                  ),
                ),
                SizedBox(width: AppTokens.spacing.md),
                Expanded(
                  child: SecondaryButton(
                    label: 'Cancel',
                    onPressed: _submitting ? null : widget.onCancel,
                    minHeight: AppTokens.componentSize.buttonMd,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Header is now handled by SheetHeaderRow in the sheet wrapper
  // For non-sheet usage, we skip header as it's in the hero section

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDate.isBefore(_roundToNearestDate(now))
        ? _roundToNearestDate(now)
        : _selectedDate;
    final picked = await showAppDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      helpText: 'Select date',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _whenError = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showAppTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Select time',
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _whenError = null;
      });
    }
  }

  DateTime _combine() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  String _friendlyDateSummary() {
    final combined = _combine();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(combined.year, combined.month, combined.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return DateFormat('MMM d').format(combined);
  }

  String _friendlyTimeSummary() {
    final combined = _combine();
    return _timeFormat.format(combined);
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    setState(() {
      _formError = null;
    });
    if (!form.validate()) return;

    final dueAt = _combine();
    final now = DateTime.now();
    if (dueAt.isBefore(now.add(const Duration(minutes: 1)))) {
      setState(() {
        _whenError = 'Pick a time in the future.';
        _formError = null;
      });
      return;
    }

    setState(() {
      _whenError = null;
      _submitting = true;
      _formError = null;
    });
    try {
      FocusScope.of(context).unfocus();
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      int? newReminderId;
      if (widget.editing == null) {
        final created = await widget.api.createReminder(
          title: _titleController.text.trim(),
          details: notes,
          dueAt: dueAt,
        );
        newReminderId = created.id;
      } else {
        await widget.api.updateReminder(
          widget.editing!.id,
          title: _titleController.text.trim(),
          details: _notesController.text,
          dueAt: dueAt,
        );
      }
      if (!mounted) return;
      widget.onSaved(newReminderId);
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Save failed: $error',
        type: AppSnackBarType.error,
      );
      setState(() {
        _formError = 'Save failed: $error';
      });
      setState(() => _submitting = false);
    }
  }
}


