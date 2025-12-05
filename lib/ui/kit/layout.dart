import 'package:flutter/material.dart';

import '../../services/analytics_service.dart';
import '../theme/tokens.dart';

/// Shared scaffold that wires analytics and motion defaults for screens.
class AppScaffold extends StatefulWidget {
  const AppScaffold({
    super.key,
    required this.screenName,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.safeArea = true,
    this.backgroundColor,
    this.semanticLabel,
  });

  final String screenName;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool safeArea;
  final Color? backgroundColor;
  final String? semanticLabel;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _logged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_logged) {
      _logged = true;
      AnalyticsService.instance.logEvent(
        'ui_screen_impression',
        params: {'screen': widget.screenName},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? body = widget.body;
    if (body != null && widget.safeArea) {
      body = SafeArea(child: body);
    }

    final semanticsLabel =
        widget.semanticLabel ?? 'Screen: ${widget.screenName}';

    final scaffoldBody = body == null
        ? null
        : Semantics(
            label: semanticsLabel,
            child: AnimatedSwitcher(
              duration: AppTokens.motion.medium,
              switchInCurve: AppTokens.motion.ease,
              switchOutCurve: AppTokens.motion.ease,
              child: body,
            ),
          );

    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: widget.appBar,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: scaffoldBody,
    );
  }
}

class AppBarX extends StatelessWidget implements PreferredSizeWidget {
  const AppBarX({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.elevation = 0,
  });

  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;

  @override
  Size get preferredSize => Size.fromHeight(AppTokens.componentSize.listItemMd);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title == null ? null : Text(title!),
      centerTitle: centerTitle,
      actions: actions,
      leading: leading,
      elevation: elevation,
    );
  }
}

/// Gradient background used across primary screens.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final Color background = colors.surface;
    return Container(
      color: background,
      child: child,
    );
  }
}

/// Default padded container that keeps content centered and scrollable.
class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth = 600,
    this.scrollable = true,
    this.centerContent = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double maxWidth;
  final bool scrollable;
  final bool centerContent;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        AppTokens.spacing.edgeInsetsSymmetric(
          horizontal: AppTokens.spacing.xxl,
          vertical: AppTokens.spacing.xxl,
        );

    Widget buildAligned(Alignment alignment) {
      final colors = Theme.of(context).colorScheme;
      final decoration = BoxDecoration(
        color: colors.surface.withValues(alpha: AppOpacity.frosted),
        borderRadius: AppTokens.radius.xl,
        border: Border.all(color: colors.outline.withValues(alpha: AppOpacity.ghost)),
        boxShadow: [
          BoxShadow(
            color: colors.outline.withValues(alpha: AppOpacity.border),
            blurRadius: AppTokens.shadow.xxl,
            offset: AppShadowOffset.layout,
          ),
        ],
      );

      return Padding(
        padding: effectivePadding,
        child: Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: DecoratedBox(
              decoration: decoration,
              child: Padding(
                padding: AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.xl),
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    if (!centerContent) {
      final alignedContent = buildAligned(Alignment.topCenter);
      if (!scrollable) {
        return alignedContent;
      }
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: alignedContent,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final centeredContent = buildAligned(Alignment.center);
        if (!scrollable) {
          return centeredContent;
        }

        final hasBoundedHeight = constraints.maxHeight.isFinite;
        final scrollChild = hasBoundedHeight
            ? ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: centeredContent,
              )
            : centeredContent;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: scrollChild,
        );
      },
    );
  }
}
