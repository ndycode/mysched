import 'package:flutter/material.dart';

/// Simple tap interaction that scales content while pressed.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.scale = 0.96,
    this.duration = const Duration(milliseconds: 140),
  });
  
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final double scale;
  final Duration duration;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final animated = AnimatedScale(
      scale: _pressed ? widget.scale : 1,
      duration: widget.duration,
      curve: Curves.easeOut,
      child: widget.child,
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: animated,
    );
  }
}
