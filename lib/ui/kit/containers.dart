import 'package:flutter/material.dart';

import '../../services/analytics_service.dart';
import '../theme/tokens.dart';

class CardX extends StatelessWidget {
  const CardX({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = backgroundColor ??
        (isDark ? colors.surfaceContainerHigh : colors.surface);
    final surface = baseColor;
    final decoration = BoxDecoration(
      color: surface,
      borderRadius: AppTokens.radius.xl,
      border: Border.all(
        color: borderColor ??
            (isDark
                ? colors.outline.withValues(alpha: 0.24)
                : colors.outlineVariant.withValues(alpha: 0.24)),
      ),
      boxShadow: isDark
          ? const []
          : [
              BoxShadow(
                color: colors.outline.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 12),
              ),
            ],
    );

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                AnalyticsService.instance.logEvent(
                  'ui_tap_cardx',
                  params: {'route': ModalRoute.of(context)?.settings.name},
                );
                onTap?.call();
              },
        borderRadius: AppTokens.radius.xl,
        splashColor: colors.primary.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: Ink(
          decoration: decoration,
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ),
    );

    if (margin == null) return card;
    return Padding(padding: margin!, child: card);
  }
}

class Section extends StatelessWidget {
  const Section({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.children,
    this.spacing,
    this.padding,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final double? spacing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final header = (title == null && subtitle == null && trailing == null)
        ? null
        : Padding(
            padding: AppTokens.spacing.edgeInsetsOnly(
              bottom: AppTokens.spacing.lg,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: theme.textTheme.titleMedium,
                        ),
                      if (subtitle != null)
                        Padding(
                          padding: AppTokens.spacing.edgeInsetsOnly(
                            top: AppTokens.spacing.sm,
                          ),
                          child: Text(
                            subtitle!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          );

    return Padding(
      padding: padding ??
          AppTokens.spacing.edgeInsetsSymmetric(
            vertical: AppTokens.spacing.xl,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) header,
          ..._spaced(children, spacing ?? AppTokens.spacing.md),
        ],
      ),
    );
  }

  List<Widget> _spaced(List<Widget> items, double spacing) {
    if (items.isEmpty) return const [];
    return [
      for (int i = 0; i < items.length; i++) ...[
        items[i],
        if (i != items.length - 1) SizedBox(height: spacing),
      ],
    ];
  }
}

class DividerX extends StatelessWidget {
  const DividerX({super.key, this.inset = 0});

  final double inset;

  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      height: AppTokens.spacing.xl,
      thickness: 1,
      indent: inset,
      endIndent: inset,
    );
    return divider;
  }
}
