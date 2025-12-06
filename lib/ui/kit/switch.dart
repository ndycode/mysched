import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A themed switch with consistent styling across the app.
/// 
/// When enabled (value=true): primary color
/// When disabled (value=false): danger color with red tint
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.showDangerWhenOff = false,
  });

  /// Current switch state
  final bool value;

  /// Callback when switch is toggled. Pass null to disable.
  final ValueChanged<bool>? onChanged;

  /// If true, shows red/danger color when switch is off.
  /// Useful for "hidden" or "disabled" states that should look concerning.
  final bool showDangerWhenOff;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    if (showDangerWhenOff) {
      return Switch.adaptive(
        value: value,
        onChanged: onChanged,
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.primary;
          return palette.danger;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary.withValues(alpha: AppOpacity.track);
          }
          return palette.danger.withValues(alpha: AppOpacity.dim);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return palette.danger.withValues(alpha: AppOpacity.medium);
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }

    // Standard primary-colored switch
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? colors.primary : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.primary.withValues(alpha: AppOpacity.track)
            : null,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
