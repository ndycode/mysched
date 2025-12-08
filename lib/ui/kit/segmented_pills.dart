import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// A unified segmented control (pills) used for filters and scopes.
/// Styled to match dashboard SegmentedButton design with proper borders,
/// backgrounds, and typography from global tokens.
class SegmentedPills<T> extends StatelessWidget {
  const SegmentedPills({
    super.key,
    required this.value,
    required this.onChanged,
    required this.options,
    required this.labelBuilder,
  });

  /// The currently selected value.
  final T value;

  /// Callback when a segment is selected.
  final ValueChanged<T> onChanged;

  /// List of available options.
  final List<T> options;

  /// Function to get the display label for an option.
  final String Function(T) labelBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<T>(
        showSelectedIcon: false,
        expandedInsets: EdgeInsets.zero,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            spacing.edgeInsetsSymmetric(
              horizontal: spacing.md,
              vertical: spacing.md,
            ),
          ),
          side: WidgetStateProperty.all(BorderSide.none),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? colors.primary.withValues(alpha: AppOpacity.statusBg)
                : colors.surfaceContainerHighest
                    .withValues(alpha: AppOpacity.barrier),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? colors.primary
                : palette.muted.withValues(alpha: AppOpacity.prominent),
          ),
          textStyle: WidgetStateProperty.all(
            AppTokens.typography.label.copyWith(
              fontWeight: AppTokens.fontWeight.semiBold,
            ),
          ),
        ),
        segments: options.map((option) {
          return ButtonSegment<T>(
            value: option,
            label: Text(
              labelBuilder(option),
              softWrap: false,
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
        selected: <T>{value},
        onSelectionChanged: (newValues) {
          if (newValues.isNotEmpty) {
            onChanged(newValues.first);
          }
        },
      ),
    );
  }
}
