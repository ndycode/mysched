import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'buttons.dart';
import 'pressable_scale.dart';
import 'responsive_provider.dart';

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

    // Get responsive scale factors (1.0 on standard ~390dp screens)
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: spacing.edgeInsetsAll(spacing.xl * spacingScale),
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
                  AppTokens.shadow.modal(
                    colors.shadow.withValues(alpha: AppOpacity.border),
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
                padding: spacing.edgeInsetsAll(spacing.xl * spacingScale),
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
                      padding: spacing.edgeInsetsAll(spacing.sm * spacingScale),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: AppOpacity.overlay),
                        borderRadius: AppTokens.radius.sm,
                      ),
                      child: Icon(
                        Icons.schedule_rounded,
                        color: colors.primary,
                        size: AppTokens.iconSize.md * scale,
                      ),
                    ),
                    SizedBox(width: spacing.md * spacingScale),
                    Text(
                      widget.helpText ?? 'Select time',
                      style: AppTokens.typography.subtitleScaled(scale).copyWith(
                        fontWeight: AppTokens.fontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
              // Time wheels
              Padding(
                padding: spacing.edgeInsetsSymmetric(
                  horizontal: spacing.xxl * spacingScale,
                  vertical: spacing.xl * spacingScale,
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
                      width: 70 * scale,
                      scale: scale,
                    ),
                    // Separator
                    Padding(
                      padding: spacing.edgeInsetsSymmetric(horizontal: spacing.sm * spacingScale),
                      child: Text(
                        ':',
                        style: AppTokens.typography.displayScaled(scale).copyWith(
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
                      width: 70 * scale,
                      scale: scale,
                    ),
                    SizedBox(width: spacing.lg * spacingScale),
                    // AM/PM toggle
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AmPmButton(
                          label: 'AM',
                          isSelected: _isAm,
                          onTap: () => setState(() => _isAm = true),
                          scale: scale,
                        ),
                        SizedBox(height: spacing.xs * spacingScale),
                        _AmPmButton(
                          label: 'PM',
                          isSelected: !_isAm,
                          onTap: () => setState(() => _isAm = false),
                          scale: scale,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Footer with buttons (OK first, Cancel second)
              Container(
                padding: spacing.edgeInsetsAll(spacing.lg * spacingScale),
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
    required this.scale,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int index) itemBuilder;
  final ValueChanged<int> onChanged;
  final double width;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final itemExtent = 50.0 * scale;
    final fadeHeight = 60.0 * scale;
    final wheelHeight = 180.0 * scale;

    return SizedBox(
      width: width,
      height: wheelHeight,
      child: Stack(
        children: [
          // Selection highlight
          Positioned.fill(
            child: Center(
              child: Container(
                height: itemExtent,
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
            itemExtent: itemExtent,
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
                    style: AppTokens.typography.displayScaled(scale).copyWith(
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
            height: fadeHeight,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isDark ? colors.surfaceContainerHigh : colors.surface,
                      (isDark ? colors.surfaceContainerHigh : colors.surface)
                          .withValues(alpha: 0),
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
            height: fadeHeight,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      isDark ? colors.surfaceContainerHigh : colors.surface,
                      (isDark ? colors.surfaceContainerHigh : colors.surface)
                          .withValues(alpha: 0),
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
    required this.scale,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 50 * scale,
        height: 40 * scale,
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
          style: AppTokens.typography.bodyScaled(scale).copyWith(
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
