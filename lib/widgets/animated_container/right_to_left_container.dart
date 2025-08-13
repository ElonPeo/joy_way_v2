import 'package:flutter/material.dart';

class RightToLeftContainer extends StatefulWidget {
  final double fatherWidth;
  final double fatherHeight;
  final double distance_traveled;
  final Widget child;
  final Duration duration;
  final bool animation;

  const RightToLeftContainer({
    super.key,
    this.fatherWidth = 200,
    this.fatherHeight = 100,
    this.distance_traveled = 100,
    required this.animation,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<RightToLeftContainer> createState() => _RightToLeftContainerState();
}

class _RightToLeftContainerState extends State<RightToLeftContainer> {



  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.fatherHeight,
      width: widget.fatherWidth,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: widget.duration,
            curve: Curves.easeInOut,
            top: 0,
            left: widget.animation ? 0 : widget.distance_traveled,
            child: AnimatedOpacity(
              duration: widget.duration,
              opacity: widget.animation ? 1.0 : 0.0,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}