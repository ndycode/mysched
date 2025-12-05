import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/reminders_api.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';
import '../ui/theme/card_styles.dart';

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
            constraints: const BoxConstraints(maxWidth: AppLayout.contentMaxWidthMedium),
            child: AddReminderForm(
              api: api,
              editing: editing,
              isSheet: false,
              onCancel: () => Navigator.of(context).maybePop(),
              onSaved: (changed) => Navigator.of(context).pop(changed),
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
    final media = MediaQuery.of(context);
    final spacing = AppTokens.spacing;
    final cardBackground = elevatedCardBackground(theme, solid: true);
    final isEditing = widget.editing != null;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppLayout.sheetMaxWidth,
            maxHeight: media.size.height * AppScale.sheetHeightRatio,
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: spacing.xl),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.surfaceContainerHigh
                  : theme.colorScheme.surface,
              borderRadius: AppTokens.radius.xxl,
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? theme.colorScheme.outline.withValues(alpha: AppOpacity.overlay)
                    : theme.colorScheme.outline,
                width: theme.brightness == Brightness.dark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: AppOpacity.medium),
                  blurRadius: AppTokens.shadow.xxl,
                  offset: AppShadowOffset.modal,
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
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(spacing.xl),
                        child: AddReminderForm(
                          key: _formKey,
                          api: widget.api,
                          editing: widget.editing,
                          isSheet: true,
                          includeButtons: false,
                          onCancel: () => Navigator.of(context).maybePop(),
                          onSaved: (changed) =>
                              Navigator.of(context).pop(changed),
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
                                  : (isEditing
                                      ? 'Update reminder'
                                      : 'Save reminder'),
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
                          SizedBox(width: AppTokens.spacing.md),
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
  final ValueChanged<bool> onSaved;
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
    final editing = widget.editing;
    final title = editing == null ? 'New reminder' : 'Edit reminder';
    final helper = editing == null
        ? 'Create a reminder and we will notify you before it is due.'
        : 'Update the reminder details. We will refresh upcoming alerts.';
    final fieldFill = isDark
        ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.prominent)
        : colors.surfaceContainerHigh;
    final fieldBorder = colors.outlineVariant.withValues(alpha: AppOpacity.fieldBorder);
    final spacing = AppTokens.spacing;

    InputDecoration decorationFor(String label, {String? hint}) =>
        InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: fieldFill,
          contentPadding:
              spacing.edgeInsetsAll(spacing.lg),
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
            borderSide: BorderSide(color: colors.primary, width: AppTokens.componentSize.dividerBold),
          ),
        );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(theme, title, helper),
          SizedBox(height: AppTokens.spacing.lg),
          Container(
            padding: spacing.edgeInsetsSymmetric(
              horizontal: spacing.lg + spacing.xs / 2,
              vertical: spacing.lg + spacing.xs / 2,
            ),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.ghost)
                  : colors.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle),
              borderRadius: AppTokens.radius.lg,
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: AppOpacity.accent),
              ),
            ),
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
          Container(
            padding: spacing.edgeInsetsSymmetric(
              horizontal: spacing.lg + spacing.xs / 2,
              vertical: spacing.lg + spacing.xs / 2,
            ),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.ghost)
                  : colors.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle),
              borderRadius: AppTokens.radius.lg,
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: AppOpacity.accent),
              ),
            ),
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
                      child: FormFieldTile(
                        label: 'Date',
                        value: _dateFormat.format(_selectedDate),
                        icon: Icons.calendar_month_rounded,
                        onTap: _submitting ? null : _pickDate,
                        fontSize: AppTokens.typography.subtitle.fontSize,
                      ),
                    ),
                    SizedBox(width: AppTokens.spacing.md),
                    Expanded(
                      child: FormFieldTile(
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.error,
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
                  child: SecondaryButton(
                    label: 'Cancel',
                    onPressed: _submitting ? null : widget.onCancel,
                    minHeight: AppTokens.componentSize.buttonMd,
                  ),
                ),
                SizedBox(width: AppTokens.spacing.md),
                Expanded(
                  child: PrimaryButton(
                    label: _submitting
                        ? (editing == null ? 'Saving...' : 'Updating...')
                        : (editing == null
                            ? 'Save reminder'
                            : 'Update reminder'),
                    onPressed: _submitting ? null : _submit,
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

  Widget _buildHeader(
    ThemeData theme,
    String title,
    String helper,
  ) {
    final colors = theme.colorScheme;
    final leading = widget.isSheet
        ? IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: widget.onCancel,
          )
        : PressableScale(
            onTap: widget.onCancel,
            child: Container(
              padding: AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.sm),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: AppOpacity.highlight),
                borderRadius: AppTokens.radius.xl,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: AppTokens.iconSize.sm,
                color: colors.primary,
              ),
            ),
          );

    final trailingGap =
        widget.isSheet ? SizedBox(width: AppTokens.spacing.quad) : SizedBox(width: AppTokens.spacing.md);

    return Column(
      crossAxisAlignment:
          widget.isSheet ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            leading,
            Expanded(
              child: Text(
                title,
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
          helper,
          textAlign: widget.isSheet ? TextAlign.center : TextAlign.left,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDate.isBefore(_roundToNearestDate(now))
        ? _roundToNearestDate(now)
        : _selectedDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _whenError = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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
    if (!form.validate()) return;

    final dueAt = _combine();
    final now = DateTime.now();
    if (dueAt.isBefore(now.add(const Duration(minutes: 1)))) {
      setState(() {
        _whenError = 'Pick a time in the future.';
      });
      return;
    }

    setState(() {
      _whenError = null;
      _submitting = true;
    });
    try {
      FocusScope.of(context).unfocus();
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      if (widget.editing == null) {
        await widget.api.createReminder(
          title: _titleController.text.trim(),
          details: notes,
          dueAt: dueAt,
        );
      } else {
        await widget.api.updateReminder(
          widget.editing!.id,
          title: _titleController.text.trim(),
          details: _notesController.text,
          dueAt: dueAt,
        );
      }
      if (!mounted) return;
      widget.onSaved(true);
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Save failed: $error',
        type: AppSnackBarType.error,
      );
      setState(() => _submitting = false);
    }
  }
}

// _FieldTile removed - using global FormFieldTile from kit.dart
