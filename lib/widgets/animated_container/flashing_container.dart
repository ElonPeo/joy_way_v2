import 'package:flutter/material.dart';

class FlashingContainer extends StatefulWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final EdgeInsets margin;
  final Color color;
  final Color flashingColor;
  final double pressedScale;
  final Duration duration;
  final Widget child;
  final VoidCallback? onTap;

  const FlashingContainer({
    super.key,
    required this.height,
    required this.width,
    required this.flashingColor,
    required this.child,
    this.margin = const EdgeInsets.all(0),
    this.borderRadius = const BorderRadius.all(Radius.circular(0)),
    this.color = const Color.fromRGBO(40, 67, 43, 1),
    this.duration = const Duration(milliseconds: 150),
    this.onTap,
    this.pressedScale = 0.88,
  });

  @override
  State<FlashingContainer> createState() => _FlashingContainerState();
}

class _FlashingContainerState extends State<FlashingContainer> {
  bool _isTapDown = false;
  bool _shouldCallTap = false;

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
      onTapUp: (details) {
        _safeSetState(() {
          _isTapDown = false;
          _shouldCallTap = true;
        });
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
              duration: widget.duration,
              child: AnimatedContainer(
                onEnd: () {
                  if (!_isTapDown && _shouldCallTap) {
                    _shouldCallTap = false;
                    widget.onTap?.call();
                  }
                },
                margin: widget.margin,
                duration: widget.duration,
                height: widget.height,
                width: widget.width,
                decoration: BoxDecoration(
                  color: _isTapDown ? widget.flashingColor : widget.color,
                  borderRadius: widget.borderRadius,
                ),
                child: widget.child,
              ),
            )
          ],
        ),
      ),
    );
  }
}
