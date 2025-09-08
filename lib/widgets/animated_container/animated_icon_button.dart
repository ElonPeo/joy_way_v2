import 'package:flutter/material.dart';

class AnimatedIconButton extends StatefulWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final Color color;
  final Color shadowColor;
  final double pressedScale;
  final Duration duration;
  final Widget child;
  final VoidCallback? onTap;

  const AnimatedIconButton({
    super.key,
    required this.height,
    required this.width,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(50)),
    this.color = const Color.fromRGBO(40, 67, 43, 1),
    this.shadowColor = const Color.fromRGBO(52, 147, 100, 0.15),
    this.pressedScale = 0.8,
    this.duration = const Duration(milliseconds: 150),
    this.onTap,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> {
  bool _isTapDown = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        _safeSetState(() => _isTapDown = true);
      },
      onTapUp: (_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        _safeSetState(() => _isTapDown = false);
        widget.onTap?.call();
      },
      onTapCancel: () {
        _safeSetState(() => _isTapDown = false);
      },
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: Stack(
          children: [
            AnimatedScale(
              scale: _isTapDown ? widget.pressedScale : 1,
              duration: const Duration(milliseconds: 150),
              child: Container(
                height: widget.height,
                width: widget.width,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: widget.borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: widget.shadowColor,
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset:
                          _isTapDown ? const Offset(0, 0) : const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
