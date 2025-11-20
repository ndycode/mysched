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
            constraints: const BoxConstraints(maxWidth: 640),
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

class AddReminderSheet extends StatelessWidget {
  const AddReminderSheet({
    super.key,
    required this.api,
    this.editing,
  });

  final RemindersApi api;
  final ReminderEntry? editing;

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
                  mainAxisSize: MainAxisSize.min,
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
                            child: AddReminderForm(
                              api: api,
                              editing: editing,
                              isSheet: true,
                              onCancel: () => Navigator.of(context).pop(false),
                              onSaved: (changed) =>
                                  Navigator.of(context).pop(changed),
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

class AddReminderForm extends StatefulWidget {
  const AddReminderForm({
    super.key,
    required this.api,
    required this.onCancel,
    required this.onSaved,
    required this.isSheet,
    this.editing,
  });

  final RemindersApi api;
  final VoidCallback onCancel;
  final ValueChanged<bool> onSaved;
  final bool isSheet;
  final ReminderEntry? editing;

  @override
  State<AddReminderForm> createState() => _AddReminderFormState();
}

class _AddReminderFormState extends State<AddReminderForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('EEE, MMM d, yyyy');
  final DateFormat _timeFormat = DateFormat('h:mm a');

  DateTime _selectedDate = _roundToNearestDate(DateTime.now());
  TimeOfDay _selectedTime =
      TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 30)));
  bool _submitting = false;
  String? _whenError;

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    if (editing != null) {
      final dueLocal = editing.dueAt.toLocal();
      _selectedDate = DateTime(dueLocal.year, dueLocal.month, dueLocal.day);
      _selectedTime = TimeOfDay.fromDateTime(dueLocal);
      _titleController.text = editing.title;
      _notesController.text = editing.details ?? '';
    } else {
      final now = DateTime.now().add(const Duration(minutes: 45));
      _selectedDate = DateTime(now.year, now.month, now.day);
      _selectedTime = TimeOfDay.fromDateTime(now);
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

    final sectionBackground = Color.alphaBlend(
      colors.primary.withValues(alpha: isDark ? 0.12 : 0.08),
      colors.surface,
    ).withValues(alpha: isDark ? 0.9 : 1.0);
    final sectionBorder =
        colors.primary.withValues(alpha: isDark ? 0.28 : 0.16);
    final fieldFill = isDark
        ? colors.surfaceContainerHighest.withValues(alpha: 0.82)
        : colors.surface;
    final fieldBorder =
        colors.outlineVariant.withValues(alpha: isDark ? 0.45 : 0.24);

    InputDecoration decorationFor(String label, {String? hint}) =>
        InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: fieldFill,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            borderSide: BorderSide(color: colors.primary, width: 2),
          ),
        );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(theme, title, helper),
          const SizedBox(height: 16),
          CardX(
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SectionHeader(
                  title: 'Reminder details',
                  subtitle: 'Shown across the app',
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _titleController,
                  decoration: decorationFor('Title', hint: 'e.g. Submit quiz'),
                  maxLength: 160,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          CardX(
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SectionHeader(
                  title: 'Reminder time',
                  subtitle: 'We will notify you at this time',
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _FieldTile(
                        label: 'Date',
                        value: _dateFormat.format(_selectedDate),
                        icon: Icons.calendar_month_rounded,
                        onTap: _submitting ? null : _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FieldTile(
                        label: 'Time',
                        value: _timeFormat.format(_combine()),
                        icon: Icons.schedule_rounded,
                        onTap: _submitting ? null : _pickTime,
                      ),
                    ),
                  ],
                ),
                if (_whenError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _whenError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _SummaryChip(
                      icon: Icons.today_outlined,
                      label: _friendlyDateSummary(),
                    ),
                    _SummaryChip(
                      icon: Icons.access_time_filled_rounded,
                      label: _friendlyTimeSummary(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTokens.radius.xl,
                    ),
                  ),
                  child: Text(_submitting
                      ? (editing == null ? 'Saving...' : 'Updating...')
                      : (editing == null
                          ? 'Save reminder'
                          : 'Update reminder')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _submitting ? null : widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: colors.primary,
              ),
            ),
          );

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
                title,
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

class _FieldTile extends StatelessWidget {
  const _FieldTile({
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
    final isDark = theme.brightness == Brightness.dark;
    final background = Color.alphaBlend(
      colors.primary.withValues(alpha: isDark ? 0.12 : 0.08),
      colors.surface,
    );
    final border = colors.primary.withValues(alpha: isDark ? 0.28 : 0.16);
    final iconBackground =
        colors.primary.withValues(alpha: isDark ? 0.28 : 0.18);
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurfaceVariant,
      fontSize: 14,
    );
    final valueStyle = theme.textTheme.titleMedium?.copyWith(
      fontFamily: 'SFProRounded',
      fontWeight: FontWeight.w700,
      color: colors.onSurface,
    );

    return InkWell(
      borderRadius: AppTokens.radius.lg,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppTokens.radius.lg,
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: iconBackground,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: colors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: labelStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: valueStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final background = Color.alphaBlend(
      colors.primary.withValues(alpha: isDark ? 0.12 : 0.08),
      colors.surface,
    );
    final border = colors.primary.withValues(alpha: isDark ? 0.26 : 0.16);
    final iconTint = colors.primary;
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: colors.onSurface,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTokens.radius.lg,
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconTint),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}
