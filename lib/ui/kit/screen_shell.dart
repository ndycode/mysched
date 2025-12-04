import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'containers.dart';
import 'layout.dart';

/// Contract for widgets that can provide custom sliver output when the shell
/// renders in sliver mode.
abstract class ScreenShellSliver {
  List<Widget> buildSlivers(
    BuildContext context,
    double maxWidth,
    EdgeInsetsGeometry horizontalPadding,
  );
}

/// Shared shell that mirrors the dashboard layout: centered content, hero card,
/// and stacked section cards.
class ScreenShell extends StatelessWidget {
  const ScreenShell({
    super.key,
    required this.screenName,
    this.appBar,
    this.hero,
    required this.sections,
    this.floatingActionButton,
    this.padding,
    this.onRefresh,
    this.refreshColor,
    this.safeArea = true,
    this.cacheExtent,
    this.useSlivers = false,
  });

  final String screenName;
  final PreferredSizeWidget? appBar;
  final Widget? hero;
  final List<Widget> sections;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry? padding;
  final Future<void> Function()? onRefresh;
  final Color? refreshColor;
  final bool safeArea;
  final double? cacheExtent;
  final bool useSlivers;

  @override
  Widget build(BuildContext context) {
    final contentPadding = padding ??
        EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + AppTokens.spacing.xxxl,
          20,
          AppTokens.spacing.quad,
        );

    return AppScaffold(
      screenName: screenName,
      safeArea: safeArea,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: AppBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth >= 840 ? 720.0 : 640.0;
            final children = [
              if (hero != null) hero!,
              if (hero != null) SizedBox(height: AppTokens.spacing.xl),
              ..._withSpacing(sections, AppTokens.spacing.lg),
            ];

            Widget scrollable;
            final physics = Theme.of(context).platform == TargetPlatform.iOS
                ? const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  )
                : const ClampingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  );

            if (useSlivers) {
              final resolvedPadding =
                  contentPadding.resolve(Directionality.of(context));
              final horizontalPadding = EdgeInsets.only(
                left: resolvedPadding.left,
                right: resolvedPadding.right,
              );

              final slivers = <Widget>[];

              if (resolvedPadding.top > 0) {
                slivers.add(
                  SliverPadding(
                    padding: EdgeInsets.only(top: resolvedPadding.top),
                    sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
                  ),
                );
              }

              for (final entry in children) {
                if (entry is ScreenShellSliver) {
                  final sliverEntry = entry as ScreenShellSliver;
                  slivers.addAll(
                    sliverEntry.buildSlivers(
                      context,
                      maxWidth,
                      horizontalPadding,
                    ),
                  );
                } else {
                  slivers.add(
                    SliverPadding(
                      padding: horizontalPadding,
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: entry,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }

              if (resolvedPadding.bottom > 0) {
                slivers.add(
                  SliverPadding(
                    padding: EdgeInsets.only(bottom: resolvedPadding.bottom),
                    sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
                  ),
                );
              }

              scrollable = CustomScrollView(
                cacheExtent: cacheExtent,
                physics: physics,
                slivers: slivers,
              );
            } else {
              scrollable = ListView(
                padding: contentPadding,
                cacheExtent: cacheExtent,
                physics: physics,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      ),
                    ),
                  ),
                ],
              );
            }

            if (onRefresh != null) {
              final colors = Theme.of(context).colorScheme;
              scrollable = RefreshIndicator(
                color: refreshColor ?? colors.primary,
                backgroundColor: Colors.transparent,
                displacement: 24,
                onRefresh: onRefresh!,
                child: scrollable,
              );
            }

            return scrollable;
          },
        ),
      ),
    );
  }

  static List<Widget> _withSpacing(List<Widget> widgets, double spacing) {
    if (widgets.isEmpty) return const [];
    return [
      for (int i = 0; i < widgets.length; i++) ...[
        widgets[i],
        if (i != widgets.length - 1) SizedBox(height: spacing),
      ],
    ];
  }
}

/// Dashboard-style hero card used for greetings or summaries.
class ScreenHeroCard extends StatelessWidget {
  const ScreenHeroCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.body,
    this.chips = const <Widget>[],
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? body;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = AppTokens.spacing;
    final children = <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                    title,
                    style: AppTokens.typography.headline.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: theme.brightness == Brightness.dark
                          ? theme.colorScheme.onSurface
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                if (subtitle != null) ...[
                  SizedBox(height: spacing.xs),
                  Text(
                    subtitle!,
                    style: AppTokens.typography.bodySecondary.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: spacing.md),
            trailing!,
          ],
        ],
      ),
      if (chips.isNotEmpty) ...[
        SizedBox(height: spacing.lg),
        Wrap(
          spacing: spacing.md,
          runSpacing: spacing.sm,
          children: chips,
        ),
      ],
      if (body != null) ...[
        SizedBox(height: spacing.lg),
        body!,
      ],
    ];

    return CardX(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(height: spacing.md),
          ],
          ...children,
        ],
      ),
    );
  }
}

/// Dashboard-style section card for grouping related fields or controls.
class ScreenSection extends StatelessWidget {
  const ScreenSection({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.padding,
    this.decorated = true,
  });

  final String? title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final bool decorated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = AppTokens.spacing;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null || subtitle != null || trailing != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: AppTokens.typography.subtitle.fontSize,
                          letterSpacing: -0.3,
                          color: theme.brightness == Brightness.dark
                              ? theme.colorScheme.onSurface
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                    if (subtitle != null) ...[
                      SizedBox(height: spacing.xs),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: spacing.sm),
                trailing!,
              ],
            ],
          ),
          SizedBox(height: spacing.lg),
        ],
        child,
      ],
    );

    if (!decorated) {
      final plainPadding = padding ?? EdgeInsets.zero;
      return RepaintBoundary(
        child: Padding(
          padding: plainPadding,
          child: content,
        ),
      );
    }

    return RepaintBoundary(
      child: CardX(
        padding: padding ?? spacing.edgeInsetsAll(spacing.lg),
        child: content,
      ),
    );
  }
}

/// Sticky header + body pair rendered as pinned slivers when supported.
class ScreenStickyGroup extends StatelessWidget implements ScreenShellSliver {
  const ScreenStickyGroup({
    super.key,
    required this.header,
    required this.child,
    this.headerHeight = 56,
  });

  final Widget header;
  final Widget child;
  final double headerHeight;

  @override
  List<Widget> buildSlivers(
    BuildContext context,
    double maxWidth,
    EdgeInsetsGeometry horizontalPadding,
  ) {
    return [
      SliverPadding(
        padding: horizontalPadding,
        sliver: SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderDelegate(
            minExtent: headerHeight,
            maxExtent: headerHeight,
            builder: (context, shrinkOffset, overlaps) {
              final colors = Theme.of(context).colorScheme;
              return RepaintBoundary(
                child: Container(
                  color: colors.surface,
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: header,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      SliverPadding(
        padding: horizontalPadding,
        sliver: SliverToBoxAdapter(
          child: RepaintBoundary(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RepaintBoundary(child: header),
        RepaintBoundary(child: child),
      ],
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StickyHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.builder,
  });

  @override
  final double minExtent;

  @override
  final double maxExtent;

  final Widget Function(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) builder;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return builder(context, shrinkOffset, overlapsContent);
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return minExtent != oldDelegate.minExtent ||
        maxExtent != oldDelegate.maxExtent;
  }
}
