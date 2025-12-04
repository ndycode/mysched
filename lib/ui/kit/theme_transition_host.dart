import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../services/theme_controller.dart';
import '../theme/tokens.dart';

class ThemeTransitionHost extends StatefulWidget {
  const ThemeTransitionHost({
    super.key,
    required this.child,
    required this.platformBrightness,
  });

  final Widget child;
  final Brightness platformBrightness;

  static ThemeTransitionHostState? of(BuildContext context) {
    return context.findAncestorStateOfType<ThemeTransitionHostState>();
  }

  @override
  State<ThemeTransitionHost> createState() => ThemeTransitionHostState();
}

class ThemeTransitionHostState extends State<ThemeTransitionHost>
    with SingleTickerProviderStateMixin {
  final GlobalKey _boundaryKey = GlobalKey();
  ui.Image? _snapshot;
  late final AnimationController _controller;
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTokens.motion.medium,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _snapshot?.dispose();
    super.dispose();
  }

  Future<void> transitionTo(AppThemeMode mode) async {
    if (_animating) return;
    final boundary = _boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      await ThemeController.instance.setMode(mode);
      return;
    }

    final pixelRatio =
        ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    setState(() {
      _snapshot?.dispose();
      _snapshot = image;
      _animating = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 16));
    await ThemeController.instance.setMode(mode);
    await _controller.forward();
    _controller.reset();
    setState(() {
      _snapshot?.dispose();
      _snapshot = null;
      _animating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = _resolveBrightness(
      ThemeController.instance.currentMode,
      widget.platformBrightness,
    );
    final overlayColor = brightness == Brightness.dark
        ? const Color(0xCC0A1323)
        : const Color(0xC0FFFFFF);

    return RepaintBoundary(
      key: _boundaryKey,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_snapshot != null)
            IgnorePointer(
              ignoring: true,
              child: FadeTransition(
                opacity: ReverseAnimation(_controller),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 0.985)
                      .animate(CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOutCubic,
                  )),
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: overlayColor),
                    child: RawImage(image: _snapshot),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Brightness _resolveBrightness(AppThemeMode mode, Brightness platformBrightness) {
  switch (mode) {
    case AppThemeMode.dark:
    case AppThemeMode.voidMode:
      return Brightness.dark;
    case AppThemeMode.light:
      return Brightness.light;
    case AppThemeMode.system:
      return platformBrightness;
  }
}
