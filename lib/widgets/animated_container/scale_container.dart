import 'package:flutter/material.dart';

class ScaleContainer extends StatefulWidget {
  final double fatherWidth;
  final double fatherHeight;
  final Widget child;
  final Duration duration;
  final bool animation;
  final Curve curve;

  const ScaleContainer({
    super.key,
    required this.fatherHeight,
    required this.fatherWidth,
    required this.animation,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutExpo,
  });

  @override
  State<ScaleContainer> createState() => _ScaleContainerState();
}

class _ScaleContainerState extends State<ScaleContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.fatherHeight,
      width: widget.fatherHeight,
      child: Center(
        child: Stack(
          children: [
            AnimatedScale(
              scale: widget.animation ? 1 : 0.8,
              duration: widget.duration,
              curve: widget.curve,
              child: AnimatedOpacity(
                opacity: widget.animation ? 1 : 0,
                duration: widget.duration,
                curve: widget.curve,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
