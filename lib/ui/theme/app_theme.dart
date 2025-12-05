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

  static ThemeData voidTheme() => _themeFromPalette(
        AppTokens.voidColors,
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
      splashColor: colors.primary.withValues(alpha: AppOpacity.highlight),
      highlightColor: colors.primary.withValues(alpha: AppOpacity.micro),
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
        color: colors.surface.withValues(alpha: AppOpacity.surface),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.radius.lg,
        ),
        shadowColor: colors.outline.withValues(alpha: AppOpacity.borderEmphasis),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outline.withValues(alpha: AppOpacity.soft),
        thickness: AppTokens.componentSize.dividerThin,
        space: AppTokens.spacing.lg,
      ),
      iconTheme: IconThemeData(color: colors.onSurface),
      chipTheme: ChipThemeData(
        labelStyle: AppTokens.typography.caption.copyWith(
          color: colors.onSurface,
        ),
        backgroundColor: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.radius.chip,
        ),
        side: BorderSide(color: colors.outline),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size.fromHeight(AppTokens.componentSize.buttonLg),
          foregroundColor: colors.onPrimary,
          backgroundColor: colors.primary,
          textStyle: AppTokens.typography.label,
          padding: AppTokens.spacing.edgeInsetsSymmetric(
            horizontal: AppTokens.spacing.xl,
            vertical: AppTokens.spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.radius.button,
          ),
          animationDuration: AppTokens.motion.medium,
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(AppTokens.componentSize.buttonLg),
          foregroundColor: colors.onPrimary,
          backgroundColor: colors.primary,
          textStyle: AppTokens.typography.label,
          padding: AppTokens.spacing.edgeInsetsSymmetric(
            horizontal: AppTokens.spacing.xl,
            vertical: AppTokens.spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.radius.button,
          ),
          animationDuration: AppTokens.motion.medium,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size.fromHeight(AppTokens.componentSize.buttonLg),
          foregroundColor: colors.primary,
          textStyle: AppTokens.typography.label,
          padding: AppTokens.spacing.edgeInsetsSymmetric(
            horizontal: AppTokens.spacing.xl,
            vertical: AppTokens.spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.radius.button,
          ),
          side: BorderSide(color: colors.primary.withValues(alpha: AppOpacity.divider)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: Size.fromHeight(AppTokens.componentSize.buttonLg),
          foregroundColor: colors.primary,
          textStyle: AppTokens.typography.label,
          padding: AppTokens.spacing.edgeInsetsSymmetric(
            horizontal: AppTokens.spacing.lg,
            vertical: AppTokens.spacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.radius.button,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerHigh.withValues(alpha: AppOpacity.subtle),
        contentPadding: AppTokens.spacing.edgeInsetsSymmetric(
          horizontal: AppTokens.spacing.xl,
          vertical: AppTokens.spacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppTokens.radius.lg,
          borderSide: BorderSide(
            color: colors.outline.withValues(alpha: AppOpacity.accent),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTokens.radius.lg,
          borderSide: BorderSide(
            color: colors.outline.withValues(alpha: AppOpacity.accent),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTokens.radius.lg,
          borderSide: BorderSide(
            color: colors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppTokens.radius.lg,
          borderSide: BorderSide(
            color: colors.error.withValues(alpha: AppOpacity.subtle),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppTokens.radius.lg,
          borderSide: BorderSide(
            color: colors.error,
            width: 1.5,
          ),
        ),
        labelStyle: AppTokens.typography.bodySecondary.copyWith(
          color: colors.onSurfaceVariant,
        ),
        hintStyle: AppTokens.typography.bodySecondary.copyWith(
          color: colors.onSurfaceVariant.withValues(alpha: AppOpacity.muted),
        ),
        errorStyle: AppTokens.typography.caption.copyWith(
          color: colors.error,
          fontWeight: AppTokens.fontWeight.medium,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.outline,
        ),
        checkColor: WidgetStateProperty.all(colors.onPrimary),
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.xs),
      ),
      snackBarTheme: _buildSnackBarTheme(scheme),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radius.sheet.topLeft.x)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.radius.sheet,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.radius.popup,
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: AppTokens.spacing.edgeInsetsSymmetric(
          horizontal: AppTokens.spacing.lg,
          vertical: AppTokens.spacing.sm,
        ),
        textColor: colors.onSurface,
        iconColor: colors.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.radius.popup,
        ),
      ),
    );
  }

  static SnackBarThemeData _buildSnackBarTheme(ColorScheme scheme) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: AppTokens.radius.sheet,
        side: BorderSide(
          color: scheme.outline.withValues(alpha: AppOpacity.overlay),
          width: 0.5,
        ),
      ),
      elevation: 0,
      insetPadding: AppTokens.spacing.edgeInsetsSymmetric(
        horizontal: AppTokens.spacing.xxl,
        vertical: AppTokens.spacing.md,
      ),
      contentTextStyle: AppTokens.typography.body.copyWith(
        color: scheme.onSurface,
        fontWeight: AppTokens.fontWeight.semiBold,
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
      errorContainer: palette.danger.withValues(alpha: AppOpacity.medium),
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
      outlineVariant: palette.outline.withValues(alpha: AppOpacity.soft),
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: palette.onSurface,
      onInverseSurface: palette.surface,
      inversePrimary: palette.primaryContainer,
      surfaceTint: palette.primary,
    );
  }
}
