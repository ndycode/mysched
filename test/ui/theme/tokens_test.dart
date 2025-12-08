import 'package:flutter_test/flutter_test.dart';

import 'package:mysched/ui/theme/tokens.dart';

void main() {
  group('ColorPalette consistency', () {
    test('lightColors has all required properties', () {
      final light = AppTokens.lightColors;
      expect(light.primary, isNotNull);
      expect(light.onPrimary, isNotNull);
      expect(light.surface, isNotNull);
      expect(light.onSurface, isNotNull);
      expect(light.background, isNotNull);
      expect(light.outline, isNotNull);
      expect(light.positive, isNotNull);
      expect(light.warning, isNotNull);
      expect(light.danger, isNotNull);
      expect(light.info, isNotNull);
      expect(light.muted, isNotNull);
      expect(light.brand, isNotNull);
    });

    test('darkColors has all required properties', () {
      final dark = AppTokens.darkColors;
      expect(dark.primary, isNotNull);
      expect(dark.onPrimary, isNotNull);
      expect(dark.surface, isNotNull);
      expect(dark.onSurface, isNotNull);
      expect(dark.background, isNotNull);
      expect(dark.outline, isNotNull);
      expect(dark.positive, isNotNull);
      expect(dark.warning, isNotNull);
      expect(dark.danger, isNotNull);
      expect(dark.info, isNotNull);
      expect(dark.muted, isNotNull);
      expect(dark.brand, isNotNull);
    });

    test('voidColors has all required properties', () {
      final void_ = AppTokens.voidColors;
      expect(void_.primary, isNotNull);
      expect(void_.onPrimary, isNotNull);
      expect(void_.surface, isNotNull);
      expect(void_.onSurface, isNotNull);
      expect(void_.background, isNotNull);
      expect(void_.outline, isNotNull);
      expect(void_.positive, isNotNull);
      expect(void_.warning, isNotNull);
      expect(void_.danger, isNotNull);
      expect(void_.info, isNotNull);
      expect(void_.muted, isNotNull);
      expect(void_.brand, isNotNull);
    });

    test('all palettes share same primary color', () {
      expect(AppTokens.lightColors.primary, equals(AppTokens.darkColors.primary));
      expect(AppTokens.darkColors.primary, equals(AppTokens.voidColors.primary));
    });
  });

  group('Spacing tokens', () {
    test('spacing values are positive', () {
      final spacing = AppTokens.spacing;
      expect(spacing.xs, greaterThan(0));
      expect(spacing.sm, greaterThan(0));
      expect(spacing.md, greaterThan(0));
      expect(spacing.lg, greaterThan(0));
      expect(spacing.xl, greaterThan(0));
      expect(spacing.xxl, greaterThan(0));
    });

    test('spacing follows progressive scale', () {
      final spacing = AppTokens.spacing;
      expect(spacing.sm, greaterThan(spacing.xs));
      expect(spacing.md, greaterThan(spacing.sm));
      expect(spacing.lg, greaterThan(spacing.md));
      expect(spacing.xl, greaterThan(spacing.lg));
      expect(spacing.xxl, greaterThan(spacing.xl));
    });
  });

  group('Typography tokens', () {
    test('typography uses SFProRounded font family', () {
      expect(AppTypography.primaryFont, 'SFProRounded');
    });

    test('typography styles have font sizes', () {
      final typography = AppTokens.typography;
      expect(typography.display.fontSize, greaterThan(0));
      expect(typography.headline.fontSize, greaterThan(0));
      expect(typography.title.fontSize, greaterThan(0));
      expect(typography.subtitle.fontSize, greaterThan(0));
      expect(typography.body.fontSize, greaterThan(0));
      expect(typography.caption.fontSize, greaterThan(0));
      expect(typography.label.fontSize, greaterThan(0));
    });

    test('font sizes follow hierarchy', () {
      final typography = AppTokens.typography;
      expect(typography.display.fontSize, greaterThan(typography.headline.fontSize!));
      expect(typography.headline.fontSize, greaterThan(typography.title.fontSize!));
      expect(typography.title.fontSize, greaterThan(typography.body.fontSize!));
      expect(typography.body.fontSize, greaterThanOrEqualTo(typography.caption.fontSize!));
    });
  });

  group('Opacity tokens', () {
    test('opacity values are within valid range', () {
      expect(AppOpacity.full, inInclusiveRange(0.0, 1.0));
      expect(AppOpacity.soft, inInclusiveRange(0.0, 1.0));
      expect(AppOpacity.subtle, inInclusiveRange(0.0, 1.0));
      expect(AppOpacity.faint, inInclusiveRange(0.0, 1.0));
      expect(AppOpacity.barrier, inInclusiveRange(0.0, 1.0));
      expect(AppOpacity.overlay, inInclusiveRange(0.0, 1.0));
    });
  });

  group('Radius tokens', () {
    test('radius values are positive', () {
      final radius = AppTokens.radius;
      expect(radius.sm.topLeft.x, greaterThan(0));
      expect(radius.md.topLeft.x, greaterThan(0));
      expect(radius.lg.topLeft.x, greaterThan(0));
      expect(radius.xl.topLeft.x, greaterThan(0));
    });
  });

  group('Motion tokens', () {
    test('motion durations are positive', () {
      final motion = AppTokens.motion;
      expect(motion.fast.inMilliseconds, greaterThan(0));
      expect(motion.medium.inMilliseconds, greaterThan(0));
      expect(motion.slow.inMilliseconds, greaterThan(0));
    });

    test('motion durations follow progressive scale', () {
      final motion = AppTokens.motion;
      expect(motion.medium.inMilliseconds, greaterThan(motion.fast.inMilliseconds));
      expect(motion.slow.inMilliseconds, greaterThan(motion.medium.inMilliseconds));
    });
  });
}
