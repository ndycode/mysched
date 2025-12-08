import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mysched/ui/theme/app_theme.dart';
import 'package:mysched/ui/theme/tokens.dart';

void main() {
  group('AppTheme.light()', () {
    test('returns light brightness theme', () {
      final theme = AppTheme.light();
      expect(theme.brightness, Brightness.light);
    });

    test('uses SFProRounded font family', () {
      final theme = AppTheme.light();
      expect(theme.textTheme.bodyLarge?.fontFamily, AppTypography.primaryFont);
    });

    test('has correct primary color', () {
      final theme = AppTheme.light();
      expect(theme.colorScheme.primary, AppTokens.lightColors.primary);
    });

    test('scaffold background is transparent', () {
      final theme = AppTheme.light();
      expect(theme.scaffoldBackgroundColor, Colors.transparent);
    });
  });

  group('AppTheme.dark()', () {
    test('returns dark brightness theme', () {
      final theme = AppTheme.dark();
      expect(theme.brightness, Brightness.dark);
    });

    test('uses SFProRounded font family', () {
      final theme = AppTheme.dark();
      expect(theme.textTheme.bodyLarge?.fontFamily, AppTypography.primaryFont);
    });

    test('has correct primary color', () {
      final theme = AppTheme.dark();
      expect(theme.colorScheme.primary, AppTokens.darkColors.primary);
    });

    test('has correct surface color', () {
      final theme = AppTheme.dark();
      expect(theme.colorScheme.surface, AppTokens.darkColors.surface);
    });
  });

  group('AppTheme.voidTheme()', () {
    test('returns dark brightness theme', () {
      final theme = AppTheme.voidTheme();
      expect(theme.brightness, Brightness.dark);
    });

    test('uses SFProRounded font family', () {
      final theme = AppTheme.voidTheme();
      expect(theme.textTheme.bodyLarge?.fontFamily, AppTypography.primaryFont);
    });

    test('has correct primary color', () {
      final theme = AppTheme.voidTheme();
      expect(theme.colorScheme.primary, AppTokens.voidColors.primary);
    });

    test('has correct surface color', () {
      final theme = AppTheme.voidTheme();
      expect(theme.colorScheme.surface, AppTokens.voidColors.surface);
    });

    test('surface is darker than dark theme', () {
      final darkTheme = AppTheme.dark();
      final voidTheme = AppTheme.voidTheme();
      
      final darkSurfaceLuminance = darkTheme.colorScheme.surface.computeLuminance();
      final voidSurfaceLuminance = voidTheme.colorScheme.surface.computeLuminance();
      
      expect(voidSurfaceLuminance, lessThanOrEqualTo(darkSurfaceLuminance));
    });
  });

  group('Theme consistency', () {
    test('all themes use global spacing tokens for list tile padding', () {
      final light = AppTheme.light();
      final dark = AppTheme.dark();
      final void_ = AppTheme.voidTheme();

      final lightPadding = light.listTileTheme.contentPadding;
      final darkPadding = dark.listTileTheme.contentPadding;
      final voidPadding = void_.listTileTheme.contentPadding;

      expect(lightPadding, equals(darkPadding));
      expect(darkPadding, equals(voidPadding));
    });

    test('all themes use global radius tokens for cards', () {
      final light = AppTheme.light();
      final dark = AppTheme.dark();
      final void_ = AppTheme.voidTheme();

      expect(light.cardTheme.shape, equals(dark.cardTheme.shape));
      expect(dark.cardTheme.shape, equals(void_.cardTheme.shape));
    });

    test('all themes have zero card elevation', () {
      expect(AppTheme.light().cardTheme.elevation, 0);
      expect(AppTheme.dark().cardTheme.elevation, 0);
      expect(AppTheme.voidTheme().cardTheme.elevation, 0);
    });
  });
}
