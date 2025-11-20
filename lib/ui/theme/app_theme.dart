import 'package:flutter/material.dart';

import 'motion.dart';
import 'tokens.dart';

/// Builds the Material theme used across MySched.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _themeFromPalette(
        AppTokens.lightColors,
        Brightness.light,
      );

  static ThemeData dark() => _themeFromPalette(
        AppTokens.darkColors,
        Brightness.dark,
      );

  static ThemeData _themeFromPalette(
    ColorPalette colors,
    Brightness brightness,
  ) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: _colorScheme(colors, brightness),
      visualDensity: VisualDensity.standard,
      fontFamily: AppTypography.primaryFont,
    );

    final scheme = base.colorScheme;

    return base.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppFadeThroughPageTransitionsBuilder(),
          TargetPlatform.iOS: AppFadeThroughPageTransitionsBuilder(),
          TargetPlatform.macOS: AppFadeThroughPageTransitionsBuilder(),
          TargetPlatform.linux: AppFadeThroughPageTransitionsBuilder(),
          TargetPlatform.windows: AppFadeThroughPageTransitionsBuilder(),
          TargetPlatform.fuchsia: AppFadeThroughPageTransitionsBuilder(),
        },
      ),
      scaffoldBackgroundColor: Colors.transparent,
      splashColor: colors.primary.withValues(alpha: 0.08),
      highlightColor: colors.primary.withValues(alpha: 0.04),
      textTheme: _buildTextTheme(base.textTheme, colors),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTokens.typography.title.copyWith(
          color: colors.onSurface,
        ),
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colors.onSurface),
      ),
      cardTheme: CardThemeData(
        color: colors.surface.withValues(alpha: 0.92),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xl),
        shadowColor: colors.outline.withValues(alpha: 0.25),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outline.withValues(alpha: 0.6),
        thickness: 1,
        space: AppTokens.spacing.lg,
      ),
      iconTheme: IconThemeData(color: colors.onSurface),
      chipTheme: ChipThemeData(
        labelStyle: AppTokens.typography.caption.copyWith(
          color: colors.onSurface,
        ),
        backgroundColor: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.md),
        side: BorderSide(color: colors.outline),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: colors.onPrimary,
          backgroundColor: colors.primary,
          textStyle: AppTokens.typography.label,
          padding: AppTokens.spacing.edgeInsetsSymmetric(
            horizontal: AppTokens.spacing.xl,
            vertical: AppTokens.spacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xl),
          animationDuration: AppTokens.motion.medium,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: colors.primary,
          textStyle: AppTokens.typography.label,
          padding: AppTokens.spacing.edgeInsetsSymmetric(
            horizontal: AppTokens.spacing.xl,
            vertical: AppTokens.spacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xl),
          side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: AppTokens.typography.label,
          padding: AppTokens.spacing.edgeInsetsSymmetric(
            horizontal: AppTokens.spacing.lg,
            vertical: AppTokens.spacing.sm,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface.withValues(alpha: 0.86),
        contentPadding: AppTokens.spacing.edgeInsetsSymmetric(
          horizontal: AppTokens.spacing.xl,
          vertical: AppTokens.spacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppTokens.radius.xl,
          borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTokens.radius.xl,
          borderSide: BorderSide(
              color: colors.primary.withValues(alpha: 0.9), width: 1.6),
        ),
        labelStyle: AppTokens.typography.bodySecondary.copyWith(
          color: colors.onSurfaceVariant,
        ),
        hintStyle: AppTokens.typography.bodySecondary.copyWith(
          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.outline,
        ),
        checkColor: WidgetStateProperty.all(colors.onPrimary),
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sm),
      ),
      snackBarTheme: _buildSnackBarTheme(scheme),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: AppTokens.radius.xl.topLeft),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: AppTokens.spacing.edgeInsetsSymmetric(
          horizontal: AppTokens.spacing.lg,
          vertical: AppTokens.spacing.sm,
        ),
        textColor: colors.onSurface,
        iconColor: colors.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.md),
      ),
    );
  }

  static SnackBarThemeData _buildSnackBarTheme(ColorScheme scheme) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.lg),
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      contentTextStyle: AppTokens.typography.body.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, ColorPalette colors) {
    return base.copyWith(
      displayLarge: AppTokens.typography.display.copyWith(
        color: colors.onBackground,
      ),
      headlineLarge: AppTokens.typography.headline.copyWith(
        color: colors.onBackground,
      ),
      titleLarge: AppTokens.typography.title.copyWith(
        color: colors.onSurface,
      ),
      titleMedium: AppTokens.typography.subtitle.copyWith(
        color: colors.onSurface,
      ),
      bodyLarge: AppTokens.typography.body.copyWith(
        color: colors.onSurface,
      ),
      bodyMedium: AppTokens.typography.bodySecondary.copyWith(
        color: colors.onSurfaceVariant,
      ),
      bodySmall: AppTokens.typography.caption.copyWith(
        color: colors.onSurfaceVariant,
      ),
      labelLarge: AppTokens.typography.label.copyWith(
        color: colors.onSurface,
      ),
      labelSmall: AppTokens.typography.caption.copyWith(
        color: colors.onSurfaceVariant,
      ),
    );
  }

  static ColorScheme _colorScheme(
    ColorPalette palette,
    Brightness brightness,
  ) {
    return ColorScheme(
      brightness: brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.primaryContainer,
      onPrimaryContainer: palette.onPrimaryContainer,
      secondary: palette.info,
      onSecondary: palette.onPrimary,
      secondaryContainer: palette.primaryContainer,
      onSecondaryContainer: palette.onPrimaryContainer,
      tertiary: palette.positive,
      onTertiary: palette.onPrimary,
      tertiaryContainer: palette.surfaceVariant,
      onTertiaryContainer: palette.onSurfaceVariant,
      error: palette.danger,
      onError: Colors.white,
      errorContainer: palette.danger.withValues(alpha: 0.15),
      onErrorContainer: palette.danger,
      surface: palette.surface,
      onSurface: palette.onSurface,
      surfaceDim: palette.surface,
      surfaceBright: palette.surface,
      surfaceContainerLowest: palette.surface,
      surfaceContainerLow: palette.surface,
      surfaceContainer: palette.surface,
      surfaceContainerHigh: palette.surfaceVariant,
      surfaceContainerHighest: palette.surfaceVariant,
      onSurfaceVariant: palette.onSurfaceVariant,
      outline: palette.outline,
      outlineVariant: palette.outline.withValues(alpha: 0.6),
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: palette.onSurface,
      onInverseSurface: palette.surface,
      inversePrimary: palette.primaryContainer,
      surfaceTint: palette.primary,
    );
  }
}
