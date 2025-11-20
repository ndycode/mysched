import 'package:flutter/material.dart';

class OverlaySheetRoute<T> extends PageRoute<T> {
  OverlaySheetRoute({
    required this.builder,
    bool barrierDismissible = false,
    Color barrierTint = const Color(0x4D000000),
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    Alignment alignment = Alignment.bottomCenter,
    this.transitionDuration = const Duration(milliseconds: 260),
    this.reverseTransitionDuration = const Duration(milliseconds: 200),
  })  : _barrierDismissible = barrierDismissible,
        _barrierTint = barrierTint,
        _padding = padding,
        _alignment = alignment;

  final WidgetBuilder builder;
  final bool _barrierDismissible;
  final Color _barrierTint;
  final EdgeInsets _padding;
  final Alignment _alignment;
  @override
  final Duration transitionDuration;
  @override
  final Duration reverseTransitionDuration;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => _barrierDismissible;

  @override
  Color? get barrierColor => _barrierTint;

  @override
  String? get barrierLabel => 'overlay-sheet';

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Align(
      alignment: _alignment,
      child: Padding(
        padding: _padding,
        child: builder(context),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

Future<T?> showOverlaySheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = false,
  Color barrierTint = const Color(0x4D000000),
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
  Alignment alignment = Alignment.bottomCenter,
  bool dimBackground = false,
}) {
  final effectiveTint =
      (barrierDismissible || dimBackground) ? barrierTint : Colors.transparent;
  return Navigator.of(context).push<T>(
    OverlaySheetRoute<T>(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Builder(builder: builder),
      ),
      barrierDismissible: barrierDismissible,
      barrierTint: effectiveTint,
      padding: padding,
      alignment: alignment,
    ),
  );
}
