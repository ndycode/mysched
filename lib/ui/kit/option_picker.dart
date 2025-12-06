import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'buttons.dart';

/// Premium option picker with scroll wheel selection.
///
/// Features:
/// - Vertical scroll wheel for options
/// - Premium styling with AppTokens
/// - OK button first, Cancel button second
Future<T?> showAppOptionPicker<T>({
  required BuildContext context,
  required List<T> options,
  required T selectedValue,
  required String Function(T) labelBuilder,
  required String title,
  IconData? icon,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) => _AppOptionPicker<T>(
      options: options,
      selectedValue: selectedValue,
      labelBuilder: labelBuilder,
      title: title,
      icon: icon,
    ),
  );
}

class _AppOptionPicker<T> extends StatefulWidget {
  const _AppOptionPicker({
    required this.options,
    required this.selectedValue,
    required this.labelBuilder,
    required this.title,
    this.icon,
  });

  final List<T> options;
  final T selectedValue;
  final String Function(T) labelBuilder;
  final String title;
  final IconData? icon;

  @override
  State<_AppOptionPicker<T>> createState() => _AppOptionPickerState<T>();
}

class _AppOptionPickerState<T> extends State<_AppOptionPicker<T>> {
  late FixedExtentScrollController _controller;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.options.indexOf(widget.selectedValue);
    if (_selectedIndex < 0) _selectedIndex = 0;
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                    if (widget.icon != null) ...[
                      Container(
                        padding: spacing.edgeInsetsAll(spacing.sm),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: AppOpacity.overlay),
                          borderRadius: AppTokens.radius.sm,
                        ),
                        child: Icon(
                          widget.icon,
                          color: colors.primary,
                          size: AppTokens.iconSize.md,
                        ),
                      ),
                      SizedBox(width: spacing.md),
                    ],
                    Text(
                      widget.title,
                      style: AppTokens.typography.subtitle.copyWith(
                        fontWeight: AppTokens.fontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
              // Scroll wheel
              Padding(
                padding: spacing.edgeInsetsSymmetric(
                  horizontal: spacing.xxl,
                  vertical: spacing.xl,
                ),
                child: SizedBox(
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
                        controller: _controller,
                        itemExtent: 50,
                        perspective: 0.003,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() => _selectedIndex = index);
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: widget.options.length,
                          builder: (context, index) {
                            return Center(
                              child: Text(
                                widget.labelBuilder(widget.options[index]),
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
                        onPressed: () => Navigator.of(context).pop(widget.options[_selectedIndex]),
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
