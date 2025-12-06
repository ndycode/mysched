import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'buttons.dart';

/// Premium date picker with scroll wheel selection.
///
/// Features:
/// - Vertical scroll wheels for month, day, year
/// - Premium styling with AppTokens
/// - OK button first, Cancel button second
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? helpText,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (context) => _AppDatePicker(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
    ),
  );
}

class _AppDatePicker extends StatefulWidget {
  const _AppDatePicker({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.helpText,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? helpText;

  @override
  State<_AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<_AppDatePicker> {
  late int _selectedMonth;
  late int _selectedDay;
  late int _selectedYear;

  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _yearController;

  late List<int> _years;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;
    _selectedYear = widget.initialDate.year;

    _years = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (i) => widget.firstDate.year + i,
    );

    _monthController = FixedExtentScrollController(initialItem: _selectedMonth - 1);
    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
    _yearController = FixedExtentScrollController(
      initialItem: _years.indexOf(_selectedYear),
    );
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  DateTime _buildDate() {
    final maxDay = _daysInMonth(_selectedYear, _selectedMonth);
    final day = _selectedDay > maxDay ? maxDay : _selectedDay;
    return DateTime(_selectedYear, _selectedMonth, day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    final daysInCurrentMonth = _daysInMonth(_selectedYear, _selectedMonth);

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
                        Icons.calendar_month_rounded,
                        color: colors.primary,
                        size: AppTokens.iconSize.md,
                      ),
                    ),
                    SizedBox(width: spacing.md),
                    Text(
                      widget.helpText ?? 'Select date',
                      style: AppTokens.typography.subtitle.copyWith(
                        fontWeight: AppTokens.fontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
              // Date wheels
              Padding(
                padding: spacing.edgeInsetsSymmetric(
                  horizontal: spacing.lg,
                  vertical: spacing.xl,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Month wheel
                    _ScrollWheel(
                      controller: _monthController,
                      itemCount: 12,
                      itemBuilder: (index) => _months[index],
                      onChanged: (index) => setState(() => _selectedMonth = index + 1),
                      width: 70,
                      isDark: isDark,
                      colors: colors,
                    ),
                    SizedBox(width: spacing.sm),
                    // Day wheel
                    _ScrollWheel(
                      controller: _dayController,
                      itemCount: daysInCurrentMonth,
                      itemBuilder: (index) => '${index + 1}',
                      onChanged: (index) => setState(() => _selectedDay = index + 1),
                      width: 50,
                      isDark: isDark,
                      colors: colors,
                    ),
                    SizedBox(width: spacing.sm),
                    // Year wheel
                    _ScrollWheel(
                      controller: _yearController,
                      itemCount: _years.length,
                      itemBuilder: (index) => '${_years[index]}',
                      onChanged: (index) => setState(() => _selectedYear = _years[index]),
                      width: 80,
                      isDark: isDark,
                      colors: colors,
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
                        onPressed: () => Navigator.of(context).pop(_buildDate()),
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
    required this.isDark,
    required this.colors,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int index) itemBuilder;
  final ValueChanged<int> onChanged;
  final double width;
  final bool isDark;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
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
                    style: AppTokens.typography.headline.copyWith(
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
            height: 60,
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
