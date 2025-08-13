import 'package:flutter/material.dart';

class   FadeContainer extends StatefulWidget {
  final double fatherWidth;
  final double fatherHeight;
  final Color fatherColor;
  final Widget child;
  final Duration duration;
  final bool animation;
  const FadeContainer({
    super.key,
    this.fatherHeight = 200,
    this.fatherWidth = 100,
    this.fatherColor = Colors.transparent,
    this.duration = const Duration(milliseconds: 500),
    required this.animation,
    required this.child,
  });

  @override
  State<FadeContainer> createState() => _FadeContainerState();
}

class _FadeContainerState extends State<FadeContainer> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.fatherHeight,
      width: widget.fatherWidth,
      color: widget.fatherColor,
      child: Center(
        child: AnimatedOpacity(
          curve: Curves.easeOutExpo,
          duration: widget.duration,
          opacity: widget.animation ? 1.0 : 0.0,
          child: widget.child,
        ),
      ),
    );
  }
}
