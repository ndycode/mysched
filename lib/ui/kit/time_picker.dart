import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'buttons.dart';
import 'pressable_scale.dart';

/// Premium time picker with scroll wheel selection.
///
/// Features:
/// - Vertical scroll wheels for hours, minutes, and AM/PM
/// - Premium styling with AppTokens
/// - OK button first, Cancel button second
Future<TimeOfDay?> showAppTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  String? helpText,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    builder: (context) => _AppTimePicker(
      initialTime: initialTime,
      helpText: helpText,
    ),
  );
}

class _AppTimePicker extends StatefulWidget {
  const _AppTimePicker({
    required this.initialTime,
    this.helpText,
  });

  final TimeOfDay initialTime;
  final String? helpText;

  @override
  State<_AppTimePicker> createState() => _AppTimePickerState();
}

class _AppTimePickerState extends State<_AppTimePicker> {
  late int _hour; // 1-12
  late int _minute; // 0-59
  late bool _isAm; // true = AM, false = PM

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    final hour24 = widget.initialTime.hour;
    _isAm = hour24 < 12;
    _hour = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    _minute = widget.initialTime.minute;

    _hourController = FixedExtentScrollController(initialItem: _hour - 1);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  TimeOfDay _buildTimeOfDay() {
    int hour24;
    if (_isAm) {
      hour24 = _hour == 12 ? 0 : _hour;
    } else {
      hour24 = _hour == 12 ? 12 : _hour + 12;
    }
    return TimeOfDay(hour: hour24, minute: _minute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: spacing.edgeInsetsAll(spacing.xl),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? colors.surfaceContainerHigh : colors.surface,
          borderRadius: AppTokens.radius.xl,
          border: Border.all(
            color: isDark
                ? colors.outline.withValues(alpha: AppOpacity.overlay)
                : colors.outline.withValues(alpha: AppOpacity.faint),
            width: AppTokens.componentSize.dividerThin,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: AppOpacity.veryFaint),
                    blurRadius: AppTokens.shadow.xl,
                    offset: AppShadowOffset.md,
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: AppTokens.radius.xl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: spacing.edgeInsetsAll(spacing.xl),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colors.outline.withValues(alpha: AppOpacity.faint),
                      width: AppTokens.componentSize.dividerThin,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: spacing.edgeInsetsAll(spacing.sm),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: AppOpacity.overlay),
                        borderRadius: AppTokens.radius.sm,
                      ),
                      child: Icon(
                        Icons.schedule_rounded,
                        color: colors.primary,
                        size: AppTokens.iconSize.md,
                      ),
                    ),
                    SizedBox(width: spacing.md),
                    Text(
                      widget.helpText ?? 'Select time',
                      style: AppTokens.typography.subtitle.copyWith(
                        fontWeight: AppTokens.fontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
              // Time wheels
              Padding(
                padding: spacing.edgeInsetsSymmetric(
                  horizontal: spacing.xxl,
                  vertical: spacing.xl,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hours wheel
                    _ScrollWheel(
                      controller: _hourController,
                      itemCount: 12,
                      itemBuilder: (index) => '${index + 1}'.padLeft(2, '0'),
                      onChanged: (index) => setState(() => _hour = index + 1),
                      width: 70,
                    ),
                    // Separator
                    Padding(
                      padding: spacing.edgeInsetsSymmetric(horizontal: spacing.sm),
                      child: Text(
                        ':',
                        style: AppTokens.typography.display.copyWith(
                          fontWeight: AppTokens.fontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    // Minutes wheel
                    _ScrollWheel(
                      controller: _minuteController,
                      itemCount: 60,
                      itemBuilder: (index) => '$index'.padLeft(2, '0'),
                      onChanged: (index) => setState(() => _minute = index),
                      width: 70,
                    ),
                    SizedBox(width: spacing.lg),
                    // AM/PM toggle
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AmPmButton(
                          label: 'AM',
                          isSelected: _isAm,
                          onTap: () => setState(() => _isAm = true),
                        ),
                        SizedBox(height: spacing.xs),
                        _AmPmButton(
                          label: 'PM',
                          isSelected: !_isAm,
                          onTap: () => setState(() => _isAm = false),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Footer with buttons (OK first, Cancel second)
              Container(
                padding: spacing.edgeInsetsAll(spacing.lg),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colors.outline.withValues(alpha: AppOpacity.faint),
                      width: AppTokens.componentSize.dividerThin,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'OK',
                        onPressed: () => Navigator.of(context).pop(_buildTimeOfDay()),
                        minHeight: AppTokens.componentSize.buttonSm,
                      ),
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: SecondaryButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                        minHeight: AppTokens.componentSize.buttonSm,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScrollWheel extends StatelessWidget {
  const _ScrollWheel({
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    required this.onChanged,
    required this.width,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int index) itemBuilder;
  final ValueChanged<int> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: width,
      height: 180,
      child: Stack(
        children: [
          // Selection highlight
          Positioned.fill(
            child: Center(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: AppOpacity.overlay),
                  borderRadius: AppTokens.radius.md,
                ),
              ),
            ),
          ),
          // Scroll wheel
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 50,
            perspective: 0.003,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: itemCount,
              builder: (context, index) {
                return Center(
                  child: Text(
                    itemBuilder(index),
                    style: AppTokens.typography.display.copyWith(
                      fontWeight: AppTokens.fontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                );
              },
            ),
          ),
          // Fade overlays
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 60,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.surface,
                      colors.surface.withValues(alpha: 0),
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
            height: 60,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      colors.surface,
                      colors.surface.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmPmButton extends StatelessWidget {
  const _AmPmButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: AppOpacity.overlay)
              : Colors.transparent,
          borderRadius: AppTokens.radius.md,
          border: Border.all(
            color: isSelected ? colors.primary : colors.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTokens.typography.body.copyWith(
            fontWeight: isSelected
                ? AppTokens.fontWeight.semiBold
                : AppTokens.fontWeight.regular,
            color: isSelected ? colors.primary : palette.muted,
          ),
        ),
      ),
    );
  }
}
