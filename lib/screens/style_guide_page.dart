import 'package:flutter/material.dart';

import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';

class StyleGuidePage extends StatelessWidget {
  const StyleGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    final hero = ScreenHeroCard(
      title: 'Style guide',
      subtitle: 'Quick glance at shared components and tokens.',
    );

    final sections = <Widget>[
      ScreenSection(
        title: 'Buttons',
        subtitle: 'Use kit buttons for primary and secondary actions.',
        decorated: false,
        child: Wrap(
          spacing: spacing.md,
          runSpacing: spacing.md,
          children: const [
            PrimaryButton(label: 'Primary'),
            SecondaryButton(label: 'Secondary'),
            TertiaryButton(
              label: 'Tertiary',
              onPressed: null,
            ),
          ],
        ),
      ),
      ScreenSection(
        title: 'Cards',
        subtitle: 'Standard surface with padding and shadow.',
        decorated: false,
        child: CardX(
          padding: spacing.edgeInsetsAll(spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CardX title',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: AppTokens.fontWeight.bold,
                    ),
              ),
              SizedBox(height: spacing.sm),
              Text(
                'Use CardX for grouped content. Combine with ScreenSection for consistent spacing.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.muted,
                    ),
              ),
            ],
          ),
        ),
      ),
      ScreenSection(
        title: 'States',
        subtitle: 'Empty and error displays.',
        decorated: false,
        child: Column(
          children: [
            const StateDisplay(
              variant: StateVariant.empty,
              title: 'Nothing here yet',
              message: 'Use StateDisplay for empty or loading states.',
              compact: true,
            ),
            SizedBox(height: AppTokens.spacing.lg),
            const StateDisplay(
              variant: StateVariant.error,
              title: 'Something went wrong',
              message: 'Actionable error messaging goes here.',
              compact: true,
            ),
          ],
        ),
      ),
      ScreenSection(
        title: 'Spacing & tokens',
        subtitle: 'Example of spacing and text styles from tokens.',
        decorated: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AppTokens.spacing',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: AppTokens.fontWeight.bold,
                  ),
            ),
            SizedBox(height: spacing.sm),
            Wrap(
              spacing: spacing.md,
              runSpacing: spacing.sm,
              children: [
                _SpacingChip(label: 'xs', value: spacing.xs),
                _SpacingChip(label: 'sm', value: spacing.sm),
                _SpacingChip(label: 'md', value: spacing.md),
                _SpacingChip(label: 'lg', value: spacing.lg),
                _SpacingChip(label: 'xl', value: spacing.xl),
                _SpacingChip(label: 'xxl', value: spacing.xxl),
              ],
            ),
          ],
        ),
      ),
    ];

    return ScreenShell(
      screenName: 'style_guide',
      hero: hero,
      sections: sections,
      padding: EdgeInsets.fromLTRB(
        spacing.xl,
        MediaQuery.of(context).padding.top + spacing.xxxl,
        spacing.xl,
        spacing.quad,
      ),
      safeArea: false,
    );
  }
}

class _SpacingChip extends StatelessWidget {
  const _SpacingChip({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Chip(
      label: Text('$label = ${value.toStringAsFixed(0)}'),
      backgroundColor: colors.surfaceContainerHigh,
    );
  }
}
